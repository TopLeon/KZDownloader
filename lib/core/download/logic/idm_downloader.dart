import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:kzdownloader/src/rust/api/download.dart';
import 'package:kzdownloader/src/rust/frb_generated.dart';
import 'package:flutter/foundation.dart';

// IDM-like downloader with resume support, multi-threading, dynamic splitting, and state persistence.
class IDMDownloader {
  final int maxWorkers;
  final int minChunkSize;
  String _currentUrl = "";
  bool _isSaving = false;

  final List<_WorkerState> _workers = [];
  final Completer<void> _taskCompleter = Completer<void>();
  Timer? _monitorTimer;

  // Writer Isolate
  // ignore: unused_field
  Isolate? _writerIsolate;
  SendPort? _writerSendPort;
  final Completer<SendPort> _writerPortCompleter = Completer<SendPort>();

  int _totalFileSize = 0;
  int _totalDownloaded = 0;
  int _lastTotalDownloaded = 0;

  // Session-average speed blended with short-window EMA for display.
  double _sessionAvgSpeed = 0.0;
  double _emaSpeed = 0.0;
  static const double _emaAlpha = 0.12;
  int _sessionDownloaded = 0;
  late DateTime _sessionStartTime;
  DateTime _lastStateSave = DateTime.now();
  static const Duration _stateSaveInterval = Duration(seconds: 5);
  int _supervisorTick = 0;
  // ignore: unused_field
  bool _isResuming = false;

  late String _savePath;
  late String _metaPath;
  final String? metaDir;

  final StreamController<Map<String, dynamic>> _statusController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  IDMDownloader({
    this.maxWorkers = 8,
    this.minChunkSize = 5 * 1024 * 1024,
    this.metaDir,
  });

  // Starts the download process.
  Future<void> download(
    String url,
    String savePath, {
    Map<String, String>? headers,
    int? knownFileSize,
    bool? knownAcceptRanges,
  }) async {
    _savePath = savePath;
    _currentUrl = url;

    if (metaDir != null) {
      final fileName = savePath.split(Platform.pathSeparator).last;
      _metaPath = "$metaDir${Platform.pathSeparator}$fileName.meta";
    } else {
      _metaPath = "$savePath.meta";
    }

    try {
      await _spawnWriter();
      final writerPort = await _writerPortCompleter.future;

      bool resumed = await _tryRecoverState(url);
      _isResuming = resumed;

      Map<String, String> currentHeaders = headers ?? {};

      if (!resumed) {
        bool acceptRanges;

        if (knownFileSize != null && knownFileSize > 0) {
          _totalFileSize = knownFileSize;
          acceptRanges = knownAcceptRanges ?? false;
        } else {
          Map<String, String> headRes;
          try {
            headRes = await getHeadInfoRust(url: url, headers: currentHeaders);
          } catch (e) {
            throw Exception("Unable to start download: $e");
          }
          _totalFileSize = int.tryParse(headRes['content-length'] ?? '0') ?? 0;
          String? acceptRangesHeader = headRes['accept-ranges'];
          acceptRanges = acceptRangesHeader != null &&
              acceptRangesHeader.toLowerCase().contains('bytes');
        }

        _writerSendPort!.send({
          'cmd': 'initFile',
          'path': _savePath,
          'size': _totalFileSize,
        });

        if (_totalFileSize == 0) {
          throw Exception("Unknown file size.");
        }

        if (!acceptRanges) {
          _workers.add(
            _WorkerState(
              id: 0,
              startPos: 0,
              currentPos: 0,
              endPos: _totalFileSize - 1,
              isDone: false,
            ),
          );
        } else {
          int effectiveWorkers = min(
            maxWorkers,
            _totalFileSize ~/ minChunkSize,
          );
          if (effectiveWorkers < 1) effectiveWorkers = 1;

          int chunkSize =
              (_totalFileSize + effectiveWorkers - 1) ~/ effectiveWorkers;
          int start = 0;

          for (int i = 0; i < effectiveWorkers; i++) {
            int end = start + chunkSize - 1;
            if (i == effectiveWorkers - 1) end = _totalFileSize - 1;

            _workers.add(
              _WorkerState(
                id: i,
                startPos: start,
                currentPos: start,
                endPos: end,
                isDone: false,
              ),
            );
            start = end + 1;
          }
        }
      } else {
        debugPrint("Resuming download from state file...");
        _writerSendPort!.send({
          'cmd': 'initFile',
          'path': _savePath,
          'size': _totalFileSize,
          'resume': true,
        });
      }

      for (var w in _workers) {
        if (!w.isDone) {
          _spawnWorker(w, url, currentHeaders, writerPort);
        }
      }

      _startSupervisor(url, currentHeaders, writerPort);
      await _taskCompleter.future;

      if (File(_metaPath).existsSync()) {
        File(_metaPath).deleteSync();
      }
    } catch (e) {
      _statusController.add({'status': 'error', 'error': e.toString()});
      if (!_taskCompleter.isCompleted) _taskCompleter.completeError(e);
      rethrow;
    } finally {
      await _cleanup();
    }
  }

  // Attempts to recover download state from the meta file.
  Future<bool> _tryRecoverState(String url) async {
    final metaFile = File(_metaPath);
    final dataFile = File(_savePath);

    if (await metaFile.exists() && await dataFile.exists()) {
      try {
        String jsonString = await metaFile.readAsString();
        Map<String, dynamic> state = jsonDecode(jsonString);

        if (state['url'] != url) return false;

        _totalFileSize = state['totalSize'];
        _totalDownloaded = 0;

        List<dynamic> workerList = state['workers'];
        _workers.clear();

        for (var wData in workerList) {
          var w = _WorkerState(
            id: wData['id'],
            startPos: wData['startPos'],
            currentPos: wData['currentPos'],
            endPos: wData['endPos'],
            isDone: wData['isDone'],
          );
          _workers.add(w);
          _totalDownloaded += (w.currentPos - w.startPos);
        }

        if (_workers.isEmpty) return false;

        return true;
      } catch (e) {
        debugPrint("Error reading state file: $e");
        return false;
      }
    }
    return false;
  }

  Future<void> _saveState() async {
    if (_isSaving || _totalFileSize == 0) return;

    _isSaving = true;

    try {
      final state = {
        'url': _currentUrl.isNotEmpty ? _currentUrl : 'UNKNOWN',
        'totalSize': _totalFileSize,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'workers': _workers
            .map(
              (w) => {
                'id': w.id,
                'startPos': w.startPos,
                'currentPos': w.currentPos,
                'endPos': w.endPos,
                'isDone': w.isDone,
              },
            )
            .toList(),
      };

      final File metaFile = File(_metaPath);
      if (!await metaFile.parent.exists()) {
        await metaFile.parent.create(recursive: true);
      }

      final tempFile = File("$_metaPath.tmp");
      await tempFile.writeAsString(jsonEncode(state));

      if (await tempFile.exists()) {
        await tempFile.rename(_metaPath);
      }
    } catch (e) {
      debugPrint("Non-fatal error saving state: $e");
    } finally {
      _isSaving = false;
    }
  }

  // Spawns a new download worker.
  void _spawnWorker(
    _WorkerState w,
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) async {
    ReceivePort workerRp = ReceivePort();

    final params = {
      'url': url,
      'headers': headers,
      'start': w.currentPos,
      'end': w.endPos,
      'workerId': w.id,
      'sendPort': workerRp.sendPort,
      'writerPort': writerPort,
      'acceptRanges': _workers.length > 1,
    };

    w.isolate = await Isolate.spawn(_isolateEntryPoint, params);

    workerRp.listen((message) {
      if (message is Map) {
        String type = message['type'];
        switch (type) {
          case 'init':
            w.controlPort = message['port'];
            break;
          case 'progress':
            int bytesWritten = message['bytes'];
            w.currentPos += bytesWritten;
            _totalDownloaded += bytesWritten;
            break;
          case 'done':
            w.isDone = true;
            w.currentPos = message['finalPos'];
            workerRp.close();
            _checkAllDone();
            break;
          case 'error':
            _statusController.add({'status': 'error', 'error': message['msg']});
            workerRp.close();
            break;
        }
      }
    });
  }

  // Entry point for worker isolates.
  static void _isolateEntryPoint(Map<String, dynamic> params) async {
    await RustLib.init();

    final SendPort mainPort = params['sendPort'];
    final SendPort writerPort = params['writerPort'];
    final ReceivePort workerRp = ReceivePort();

    mainPort.send({'type': 'init', 'port': workerRp.sendPort});

    String url = params['url'];
    int start = params['start'];
    int end = params['end'];
    int workerId = params['workerId'];
    bool acceptRanges = params['acceptRanges'];
    Map<String, String> headers = Map<String, String>.from(
      params['headers'] ?? {},
    );

    int currentPos = start;
    int dynamicEnd = end;

    workerRp.listen((msg) {
      if (msg is Map && msg['cmd'] == 'updateEnd') {
        dynamicEnd = msg['val'];
      }
    });

    int retryCount = 0;
    const int maxRetries = 20;

    final random = Random();

    bool isUnknownSize = (dynamicEnd == -1);

    while (isUnknownSize || currentPos <= dynamicEnd) {
      try {
        if (acceptRanges && !isUnknownSize) {
          headers['Range'] = 'bytes=$currentPos-$dynamicEnd';
        }

        if (isUnknownSize && currentPos > 0) {
          headers['Range'] = 'bytes=$currentPos-';
        }

        final rustStream = downloadChunkRust(
          url: url,
          start: BigInt.from(currentPos),
          end: isUnknownSize ? BigInt.from(-1) : BigInt.from(dynamicEnd),
          headers: headers,
        );

        final buffer = BytesBuilder(copy: false);
        int bufferStartPos = currentPos;
        // 2MB batch size for efficient I/O throughput
        const int batchSize = 2 * 1024 * 1024;
        int bytesSinceLastReport = 0;
        // 512KB progress report threshold — frequent enough for accurate speed EMA
        const int reportThreshold = 512 * 1024;

        await for (final chunk in rustStream) {
          if (retryCount > 0) retryCount = 0;

          if (!isUnknownSize && currentPos > dynamicEnd) break;

          Uint8List dataToProcess = chunk;
          if (!isUnknownSize) {
            final bytesLimit = dynamicEnd - currentPos + 1;
            if (chunk.length > bytesLimit) {
              dataToProcess = chunk.sublist(0, bytesLimit);
            }
          }

          if (dataToProcess.isNotEmpty) {
            buffer.add(dataToProcess);
            currentPos += dataToProcess.length;

            if (buffer.length >= batchSize) {
              final flushed = buffer.takeBytes();
              _flushBufferToWriter(writerPort, flushed, bufferStartPos);

              bytesSinceLastReport += flushed.length;

              if (bytesSinceLastReport >= reportThreshold) {
                mainPort.send({
                  'type': 'progress',
                  'workerId': workerId,
                  'bytes': bytesSinceLastReport,
                });
                bytesSinceLastReport = 0;
              }

              bufferStartPos = currentPos;
            }
          }
        }

        if (buffer.length > 0) {
          final remaining = buffer.takeBytes();
          bytesSinceLastReport += remaining.length;
          _flushBufferToWriter(writerPort, remaining, bufferStartPos);
          mainPort.send({
            'type': 'progress',
            'workerId': workerId,
            'bytes': bytesSinceLastReport,
          });
        }

        if (!isUnknownSize) {
          if (currentPos >= dynamicEnd) {
            break;
          } else {
            throw Exception(
              "Stream ended prematurely (Server closed connection)",
            );
          }
        } else {
          break;
        }
      } catch (e) {
        String errorStr = e.toString();
        bool is429 =
            errorStr.contains("429") || errorStr.contains("Too Many Requests");
        bool is403 = errorStr.contains("403") || errorStr.contains("Forbidden");

        if (is403) {
          mainPort.send({'type': 'error', 'msg': "Link Expired (403): $e"});
          return;
        }

        retryCount++;
        if (retryCount > maxRetries) {
          mainPort.send({'type': 'error', 'msg': "Max retries exceeded: $e"});
          return;
        }

        int waitSeconds = is429
            ? 10 + random.nextInt(10)
            : min(30, pow(2, retryCount).toInt()) + random.nextInt(3);

        sleep(Duration(seconds: waitSeconds));
      }
    }

    mainPort.send({
      'type': 'done',
      'workerId': workerId,
      'finalPos': currentPos,
    });
    workerRp.close();
  }

  // Sends buffer to writer isolate using zero-copy TransferableTypedData.
  static void _flushBufferToWriter(
    SendPort writerPort,
    Uint8List buffer,
    int offset,
  ) {
    final transferable = TransferableTypedData.fromList([buffer]);
    writerPort.send({'cmd': 'write', 'offset': offset, 'data': transferable});
  }

  Future<void> _spawnWriter() async {
    ReceivePort rp = ReceivePort();
    _writerIsolate = await Isolate.spawn(_writerEntryPoint, rp.sendPort);
    _writerSendPort = await rp.first as SendPort;
    _writerPortCompleter.complete(_writerSendPort);
  }

  static void _writerEntryPoint(SendPort mainSendPort) async {
    ReceivePort rp = ReceivePort();
    mainSendPort.send(rp.sendPort);

    RandomAccessFile? raf;

    await for (final msg in rp) {
      if (msg is Map) {
        String cmd = msg['cmd'];

        if (cmd == 'initFile') {
          String path = msg['path'];
          int size = msg['size'];
          bool resume = msg['resume'] ?? false;

          final f = File(path);
          if (!resume && await f.exists()) await f.delete();

          raf = await f.open(mode: FileMode.write);
          if (!resume && size > 0) {
            try {
              await raf.truncate(size);
            } catch (e) {
              await raf.setPosition(size - 1);
              await raf.writeByte(0);
            }
          }
        } else if (cmd == 'write') {
          int offset = msg['offset'];
          TransferableTypedData data = msg['data'];

          if (raf != null) {
            await raf.setPosition(offset);
            await raf.writeFrom(data.materialize().asUint8List());
          }
        } else if (cmd == 'close') {
          await raf?.close();
          raf = null;
          Isolate.exit();
        }
      }
    }
  }

  void _startSupervisor(
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) {
    _sessionStartTime = DateTime.now();
    _sessionDownloaded = 0;
    _monitorTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      _supervisorTick++;
      final now = DateTime.now();
      final diff = _totalDownloaded - _lastTotalDownloaded;
      _lastTotalDownloaded = _totalDownloaded;
      _sessionDownloaded += diff;

      // Session-average speed: total session bytes / total session time.
      // Inherently stable — no spikes possible.
      final sessionElapsed =
          now.difference(_sessionStartTime).inMicroseconds / 1000000.0;
      if (sessionElapsed > 0.5 && _sessionDownloaded > 0) {
        _sessionAvgSpeed = _sessionDownloaded / sessionElapsed;
      }

      // Short-window EMA for responsiveness to speed changes.
      if (diff > 0) {
        // Approximate instant speed from this tick (250ms nominal)
        final instantSpeed = diff * 4.0;
        _emaSpeed = _emaSpeed == 0
            ? instantSpeed
            : _emaAlpha * instantSpeed + (1 - _emaAlpha) * _emaSpeed;
      }

      // Blend: 70% session-average (stable) + 30% EMA (reactive)
      final displaySpeed = _sessionAvgSpeed > 0
          ? _sessionAvgSpeed * 0.7 + _emaSpeed * 0.3
          : _emaSpeed;

      // ETA from session-average speed — converges monotonically.
      final remaining = _totalFileSize - _totalDownloaded;
      String? eta;
      if (_sessionAvgSpeed > 0 && remaining > 0) {
        eta = _formatEta(remaining / _sessionAvgSpeed);
      }

      // Throttle state persistence to reduce disk I/O
      if (now.difference(_lastStateSave) >= _stateSaveInterval) {
        _lastStateSave = now;
        _saveState();
      }

      if (!_statusController.isClosed) {
        // Collect worker info
        final workersInfo = _workers.map((w) {
          final workerProgress = w.endPos - w.startPos > 0
              ? (w.currentPos - w.startPos) / (w.endPos - w.startPos)
              : 0.0;
          return {
            'id': w.id,
            'progress': workerProgress,
            'isDone': w.isDone,
            'startPos': w.startPos,
            'currentPos': w.currentPos,
            'endPos': w.endPos,
          };
        }).toList();

        _statusController.add({
          'status': 'running',
          'progress':
              _totalFileSize > 0 ? _totalDownloaded / _totalFileSize : 0.0,
          'speed': displaySpeed,
          'eta': eta,
          'downloaded': _totalDownloaded,
          'totalSize': _totalFileSize,
          'activeWorkers': _workers.where((w) => !w.isDone).length,
          'totalWorkers': _workers.length,
          'workers': workersInfo,
        });
      }

      // Only check dynamic splitting every ~1s (4 ticks × 250ms)
      if (_supervisorTick % 4 == 0) {
        _checkAndSplit(url, headers, writerPort);
      }
    });
  }

  void _checkAndSplit(
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) {
    int activeWorkers = _workers.where((w) => !w.isDone).length;

    if (activeWorkers >= maxWorkers) return;

    _WorkerState? slowestWorker;
    int maxRemnant = 0;
    for (var w in _workers) {
      if (w.isDone) continue;
      int remaining = w.endPos - w.currentPos;
      if (remaining > maxRemnant) {
        maxRemnant = remaining;
        slowestWorker = w;
      }
    }

    if (slowestWorker != null &&
        maxRemnant > minChunkSize * 2 &&
        _workers.length < maxWorkers * 2) {
      int newEnd = slowestWorker.currentPos + (maxRemnant ~/ 2);
      if (slowestWorker.controlPort != null) {
        slowestWorker.controlPort!.send({'cmd': 'updateEnd', 'val': newEnd});
        final oldEnd = slowestWorker.endPos;
        slowestWorker.endPos = newEnd;

        int newId = _workers.length;
        var newWorker = _WorkerState(
          id: newId,
          startPos: newEnd + 1,
          currentPos: newEnd + 1,
          endPos: oldEnd,
          isDone: false,
        );
        _workers.add(newWorker);
        _spawnWorker(newWorker, url, headers, writerPort);
      }
    }
  }

  // Formats ETA seconds into a human-readable string.
  static String _formatEta(double etaSeconds) {
    if (etaSeconds.isNaN || etaSeconds.isInfinite || etaSeconds < 0) {
      return '...';
    }
    if (etaSeconds < 60) return '${etaSeconds.toInt()}s';
    if (etaSeconds < 3600) {
      final m = (etaSeconds / 60).toInt();
      final s = (etaSeconds % 60).toInt();
      return '${m}m ${s}s';
    }
    final h = (etaSeconds / 3600).toInt();
    final m = ((etaSeconds % 3600) / 60).toInt();
    return '${h}h ${m}m';
  }

  void _checkAllDone() {
    if (_workers.every((w) => w.isDone)) {
      if (!_taskCompleter.isCompleted) _taskCompleter.complete();
    }
  }

  // Pauses the download.
  Future<void> pause() async {
    _monitorTimer?.cancel();

    await _saveState();

    for (var w in _workers) {
      w.isolate?.kill(priority: Isolate.immediate);
    }

    if (_writerSendPort != null) {
      _writerSendPort!.send({'cmd': 'close'});
    }

    if (!_statusController.isClosed) {
      _statusController.add({'status': 'paused'});
      await _statusController.close();
    }

    if (!_taskCompleter.isCompleted) {
      _taskCompleter.completeError(Exception('Download Paused'));
    }
  }

  Future<void> _cleanup() async {
    _monitorTimer?.cancel();
    for (var w in _workers) {
      w.isolate?.kill(priority: Isolate.immediate);
    }
    if (_writerSendPort != null) {
      try {
        _writerSendPort!.send({'cmd': 'close'});
      } catch (e) {
        //
      }
    }
    if (!_statusController.isClosed) {
      await _statusController.close();
    }
  }
}

class _WorkerState {
  final int id;
  int startPos;
  int currentPos;
  int endPos;
  Isolate? isolate;
  SendPort? controlPort;
  bool isDone;

  _WorkerState({
    required this.id,
    required this.startPos,
    required this.currentPos,
    required this.endPos,
    required this.isDone,
  });
}
