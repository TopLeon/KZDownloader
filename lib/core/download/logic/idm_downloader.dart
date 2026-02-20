import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:kzdownloader/core/services/download_service.dart';
import 'package:kzdownloader/core/download/logic/speed_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:rhttp_plus/rhttp_plus.dart';
import 'package:ffi/ffi.dart';

// IDM-like multi-threaded downloader with resume, dynamic splitting, and state persistence.
// Workers run as real Dart isolates for multi-core parallelism.
// File I/O is serialized through a dedicated writer isolate.
class IDMDownloader {
  final int maxWorkers;
  final int minChunkSize;
  String _currentUrl = "";
  bool _isSaving = false;

  final List<_WorkerState> _workers = [];
  final Completer<void> _taskCompleter = Completer<void>();
  Timer? _monitorTimer;

  // ignore: unused_field
  Isolate? _writerIsolate; // retained for future explicit termination
  SendPort? _writerSendPort;
  final Completer<SendPort> _writerPortCompleter = Completer<SendPort>();

  int _totalFileSize = 0;
  int _totalDownloaded = 0;
  // ignore: unused_field
  int _lastTotalDownloaded = 0;
  DateTime _lastStateSave = DateTime.now();
  static const Duration _stateSaveInterval = Duration(seconds: 5);
  int _supervisorTick = 0;

  late final SpeedTracker _speed;

  Completer<void>? _cancelCompleter;
  int _pendingCancelCount = 0;

  late String _savePath;
  late String _metaPath;
  final String? metaDir;

  final StreamController<Map<String, dynamic>> _statusController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  IDMDownloader({
    this.maxWorkers = 6,
    this.minChunkSize = 3 * 1024 * 1024,
    this.metaDir,
  });

  // Starts the multi-threaded download.
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

      final resumed = await _tryRecoverState(url);
      Map<String, String> currentHeaders = headers ?? {};

      if (!resumed) {
        bool acceptRanges;

        if (knownFileSize != null && knownFileSize > 0) {
          _totalFileSize = knownFileSize;
          acceptRanges = knownAcceptRanges ?? false;
        } else {
          final headRes = await getHeadInfo(url, currentHeaders);
          _totalFileSize = int.tryParse(headRes['content-length'] ?? '0') ?? 0;
          final arHeader = headRes['accept-ranges'];
          acceptRanges =
              arHeader != null && arHeader.toLowerCase().contains('bytes');
        }

        _writerSendPort!.send({
          'cmd': 'initFile',
          'path': _savePath,
          'size': _totalFileSize,
        });

        if (_totalFileSize == 0) {
          throw Exception(
              "Unknown file size - not supported with range splitting.");
        }

        if (!acceptRanges) {
          _workers.add(_WorkerState(
            id: 0,
            startPos: 0,
            currentPos: 0,
            endPos: _totalFileSize - 1,
            isDone: false,
          ));
        } else {
          int effectiveWorkers =
              min(maxWorkers, _totalFileSize ~/ minChunkSize);
          if (effectiveWorkers < 1) effectiveWorkers = 1;

          final chunkSize =
              (_totalFileSize + effectiveWorkers - 1) ~/ effectiveWorkers;
          int start = 0;

          for (int i = 0; i < effectiveWorkers; i++) {
            int end = start + chunkSize - 1;
            if (i == effectiveWorkers - 1) end = _totalFileSize - 1;
            _workers.add(_WorkerState(
              id: i,
              startPos: start,
              currentPos: start,
              endPos: end,
              isDone: false,
            ));
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

      final spawnFutures = <Future<void>>[];
      for (var w in _workers) {
        if (!w.isDone) {
          spawnFutures.add(_spawnWorker(w, url, currentHeaders, writerPort));
        }
      }
      await Future.wait(spawnFutures);

      _lastTotalDownloaded = _totalDownloaded;
      _startSupervisor(url, currentHeaders, writerPort);
      await _taskCompleter.future;

      if (File(_metaPath).existsSync()) File(_metaPath).deleteSync();
    } catch (e) {
      if (!_statusController.isClosed) {
        _statusController.add({'status': 'error', 'error': e.toString()});
      }
      if (!_taskCompleter.isCompleted) _taskCompleter.completeError(e);
      rethrow;
    } finally {
      await _cleanup();
    }
  }

  // Attempts to recover download state from a persisted meta file.
  Future<bool> _tryRecoverState(String url) async {
    final metaFile = File(_metaPath);
    final dataFile = File(_savePath);

    if (await metaFile.exists() && await dataFile.exists()) {
      try {
        final state =
            jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
        if (state['url'] != url) return false;

        _totalFileSize = state['totalSize'];
        _totalDownloaded = state['totalDownloaded'] ?? 0;

        final workerList = state['workers'] as List<dynamic>;
        _workers.clear();

        for (var wData in workerList) {
          var w = _WorkerState(
            id: wData['id'],
            startPos: wData['startPos'],
            currentPos: wData['currentPos'],
            endPos: wData['endPos'],
            isDone: wData['isDone'],
          );
          if (w.currentPos < w.endPos) w.isDone = false;
          _workers.add(w);

          if (state['totalDownloaded'] == null) {
            _totalDownloaded += (w.currentPos - w.startPos);
          }
        }

        if (_workers.isEmpty) return false;
        debugPrint(
            "Resumed with ${_workers.length} workers from byte $_totalDownloaded of $_totalFileSize");
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
        'totalDownloaded': _totalDownloaded,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'workers': _workers
            .map((w) => {
                  'id': w.id,
                  'startPos': w.startPos,
                  'currentPos': w.currentPos,
                  'endPos': w.endPos,
                  'isDone': w.isDone,
                })
            .toList(),
      };

      final metaFile = File(_metaPath);
      if (!await metaFile.parent.exists()) {
        await metaFile.parent.create(recursive: true);
      }

      final tempFile = File("$_metaPath.tmp");
      await tempFile.writeAsString(jsonEncode(state));
      if (await tempFile.exists()) await tempFile.rename(_metaPath);
    } catch (e) {
      debugPrint("Non-fatal error saving state: $e");
    } finally {
      _isSaving = false;
    }
  }

  // Spawns a worker isolate for one byte-range segment.
  Future<void> _spawnWorker(
    _WorkerState w,
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) async {
    final receivePort = ReceivePort();
    final readyCompleter = Completer<void>();
    w.receivePort = receivePort;

    receivePort.listen((msg) {
      if (msg is Map) {
        switch (msg['type']) {
          case 'ready':
            w.workerPort = msg['port'] as SendPort;
            if (!readyCompleter.isCompleted) readyCompleter.complete();
            break;
          case 'progress':
            if (!w.isDone) {
              _totalDownloaded += msg['bytes'] as int;
              w.currentPos = msg['currentPos'] as int;
            }
            break;
          case 'done':
            w.isDone = true;
            _checkAllDone();
            break;
          case 'cancelled':
            w.isDone = true;
            _pendingCancelCount--;
            if (_pendingCancelCount <= 0 &&
                _cancelCompleter != null &&
                !_cancelCompleter!.isCompleted) {
              _cancelCompleter!.complete();
            }
            break;
          case 'error':
            if (!_statusController.isClosed) {
              _statusController
                  .add({'status': 'error', 'error': msg['message']});
            }
            w.isDone = true;
            break;
        }
      }
    });

    w.isolate = await Isolate.spawn(
      _workerIsolateEntryPoint,
      _WorkerIsolateInitData(
        workerSendPort: receivePort.sendPort,
        workerId: w.id,
        url: url,
        headers: headers,
        startPos: w.startPos,
        currentPos: w.currentPos,
        endPos: w.endPos,
        writerPort: writerPort,
      ),
    );

    await readyCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Worker ${w.id} failed to initialize in time');
      },
    );
  }

  // Worker isolate entry point — runs on a separate thread.
  static void _workerIsolateEntryPoint(_WorkerIsolateInitData init) async {
    await Rhttp.init();

    final receivePort = ReceivePort();
    init.workerSendPort.send({'type': 'ready', 'port': receivePort.sendPort});

    int currentPos = init.currentPos;
    int endPos = init.endPos;
    final mainPort = init.workerSendPort;

    bool cancelled = false;
    bool isUnknownSize = (endPos == -1);

    StreamSubscription<Uint8List>? activeHttpSub;
    StreamController<Uint8List>? activeStreamController;

    late StreamSubscription commandSub;
    commandSub = receivePort.listen((msg) {
      if (msg is Map) {
        if (msg['cmd'] == 'cancel') {
          cancelled = true;
          try {
            activeHttpSub?.cancel();
          } catch (_) {}
          try {
            if (activeStreamController != null &&
                !activeStreamController.isClosed) {
              activeStreamController.close();
            }
          } catch (_) {}
        } else if (msg['cmd'] == 'updateEnd') {
          final newEnd = msg['newEnd'] as int;
          if (newEnd < endPos && newEnd >= currentPos) endPos = newEnd;
        }
      }
    });

    int retryCount = 0;
    const int maxRetries = 20;
    final random = Random();

    try {
      while (!cancelled && (isUnknownSize || currentPos <= endPos)) {
        try {
          final rustStream = downloadChunkStream(
            init.url,
            currentPos,
            isUnknownSize ? -1 : endPos,
            init.headers,
          );

          final controller = StreamController<Uint8List>();
          activeStreamController = controller;
          activeHttpSub = rustStream.listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );

          final buffer = BytesBuilder(copy: false);
          int bufferStartPos = currentPos;
          const int batchSize = 2 * 1024 * 1024;
          int localBytes = 0;

          // Backpressure: create a port to receive writer acks
          final ackPort = ReceivePort();
          final ackSendPort = ackPort.sendPort;
          final ackIterator = StreamIterator(ackPort);

          DateTime lastProgressUpdate = DateTime.now();
          const progressInterval = Duration(milliseconds: 200);

          await for (final chunk in controller.stream) {
            if (cancelled) break;
            if (retryCount > 0) retryCount = 0;
            if (!isUnknownSize && currentPos > endPos) break;

            Uint8List data = chunk;
            if (!isUnknownSize) {
              final limit = endPos - currentPos + 1;
              if (chunk.length > limit) data = chunk.sublist(0, limit);
            }

            if (data.isNotEmpty) {
              buffer.add(data);
              currentPos += data.length;
              localBytes += data.length;

              final now = DateTime.now();
              if (!cancelled &&
                  now.difference(lastProgressUpdate) >= progressInterval) {
                if (localBytes > 0) {
                  mainPort.send({
                    'type': 'progress',
                    'bytes': localBytes,
                    'currentPos': currentPos,
                  });
                  localBytes = 0;
                  lastProgressUpdate = now;
                }
              }

              if (buffer.length >= batchSize) {
                await _flushBufferToWriter(init.writerPort, buffer.takeBytes(),
                    bufferStartPos, ackSendPort, ackIterator);
                bufferStartPos = currentPos;
              }
            }
          }

          activeHttpSub = null;
          activeStreamController = null;

          if (buffer.length > 0) {
            await _flushBufferToWriter(init.writerPort, buffer.takeBytes(),
                bufferStartPos, ackSendPort, ackIterator);
          }

          await ackIterator.cancel();
          ackPort.close();

          if (!cancelled && localBytes > 0) {
            mainPort.send({
              'type': 'progress',
              'bytes': localBytes,
              'currentPos': currentPos,
            });
          }

          if (cancelled) break;

          if (!isUnknownSize) {
            if (currentPos >= endPos) {
              break;
            } else {
              throw Exception("Stream ended prematurely");
            }
          } else {
            break;
          }
        } catch (e) {
          if (cancelled) break;

          final err = e.toString();
          if (err.contains("403") || err.contains("Forbidden")) {
            mainPort
                .send({'type': 'error', 'message': "Link Expired (403): $e"});
            return;
          }

          retryCount++;
          if (retryCount > maxRetries) {
            mainPort.send({
              'type': 'error',
              'message': "Worker ${init.workerId} max retries exceeded: $e"
            });
            return;
          }

          final is429 =
              err.contains("429") || err.contains("Too Many Requests");
          final wait = is429
              ? 10 + random.nextInt(10)
              : min(30, pow(2, retryCount).toInt()) + random.nextInt(3);
          debugPrint(
              "Worker ${init.workerId} retry $retryCount/$maxRetries, waiting ${wait}s: $e");
          await Future.delayed(Duration(seconds: wait));
        }
      }

      mainPort.send({'type': cancelled ? 'cancelled' : 'done'});
    } catch (e) {
      if (!cancelled) {
        mainPort.send({
          'type': 'error',
          'message': 'Worker ${init.workerId} fatal error: $e'
        });
      }
    } finally {
      try {
        activeHttpSub?.cancel();
      } catch (_) {}
      try {
        if (activeStreamController != null &&
            !activeStreamController.isClosed) {
          activeStreamController.close();
        }
      } catch (_) {}
      await commandSub.cancel();
      await Future.delayed(const Duration(milliseconds: 50));
      receivePort.close();
      Isolate.exit();
    }
  }

  // Ack-based buffer transfer to the writer isolate.
  // Waits for the writer to acknowledge the write before returning,
  // providing backpressure to prevent memory accumulation.
  static Future<void> _flushBufferToWriter(
      SendPort writerPort,
      Uint8List buffer,
      int offset,
      SendPort ackSendPort,
      StreamIterator ackIterator) async {
    writerPort.send({
      'cmd': 'write',
      'offset': offset,
      'data': TransferableTypedData.fromList([buffer]),
      'ackPort': ackSendPort,
    });
    // Wait for writer to confirm the write is complete
    await ackIterator.moveNext();
  }

  Future<void> _spawnWriter() async {
    final rp = ReceivePort();
    _writerIsolate = await Isolate.spawn(_writerEntryPoint, rp.sendPort);
    _writerSendPort = await rp.first as SendPort;
    _writerPortCompleter.complete(_writerSendPort);
  }

  // Writer isolate — serializes all disk I/O via await-for.
  static void _writerEntryPoint(SendPort mainSendPort) async {
    final rp = ReceivePort();
    mainSendPort.send(rp.sendPort);

    RandomAccessFile? raf;

    await for (final msg in rp) {
      if (msg is Map) {
        final cmd = msg['cmd'] as String;

        if (cmd == 'initFile') {
          final path = msg['path'] as String;
          final size = msg['size'] as int;
          final resume = msg['resume'] ?? false;

          final f = File(path);
          if (!resume && await f.exists()) await f.delete();
          raf = await f.open(mode: resume ? FileMode.append : FileMode.write);

          if (!resume && size > 0 && Platform.isWindows) {
            _setSparseFileWindows(path);
          }
          if (!resume && size > 0 && size < 500 * 1024 * 1024) {
            try {
              await raf.truncate(size);
            } catch (_) {
              try {
                await raf.setPosition(size - 1);
                await raf.writeByte(0);
                await raf.setPosition(0);
              } catch (_) {}
            }
          }
        } else if (cmd == 'write') {
          final offset = msg['offset'] as int;
          final data = msg['data'] as TransferableTypedData;
          final ackPort = msg['ackPort'] as SendPort?;
          if (raf != null) {
            try {
              await raf.setPosition(offset);
              await raf.writeFrom(data.materialize().asUint8List());
            } catch (e) {
              debugPrint('Writer: error at offset $offset: $e');
            }
          }
          // Send ack back to worker for backpressure
          ackPort?.send('ack');
        } else if (cmd == 'close') {
          if (raf != null) {
            try {
              await raf.flush();
              await raf.close();
            } catch (e) {
              debugPrint('Writer: close error: $e');
            }
            raf = null;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          rp.close();
          Isolate.exit();
        }
      }
    }
  }

  // Windows: mark file as sparse to avoid writing zeros on pre-allocation.
  static void _setSparseFileWindows(String path) {
    if (!Platform.isWindows) return;

    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');

      const int fsctlSetSparse = 0x000900c4;
      const int genericWrite = 0x40000000;
      const int fileShareRead = 0x00000001;
      const int fileShareWrite = 0x00000002;
      const int openExisting = 3;
      const int fileAttributeNormal = 0x00000080;

      final createFileW = kernel32.lookupFunction<
          IntPtr Function(
              Pointer<Utf16>, Uint32, Uint32, Pointer, Uint32, Uint32, IntPtr),
          int Function(
              Pointer<Utf16>, int, int, Pointer, int, int, int)>('CreateFileW');

      final deviceIoControl = kernel32.lookupFunction<
          Int32 Function(IntPtr, Uint32, Pointer, Uint32, Pointer, Uint32,
              Pointer<Uint32>, Pointer),
          int Function(int, int, Pointer, int, Pointer, int, Pointer<Uint32>,
              Pointer)>('DeviceIoControl');

      final closeHandle =
          kernel32.lookupFunction<Int32 Function(IntPtr), int Function(int)>(
              'CloseHandle');

      final pathPtr = path.toNativeUtf16();
      final handle = createFileW(
        pathPtr,
        genericWrite,
        fileShareRead | fileShareWrite,
        nullptr,
        openExisting,
        fileAttributeNormal,
        0,
      );

      if (handle != -1) {
        final bytesReturned = calloc<Uint32>();
        deviceIoControl(handle, fsctlSetSparse, nullptr, 0, nullptr, 0,
            bytesReturned, nullptr);
        calloc.free(bytesReturned);
        closeHandle(handle);
      }
      calloc.free(pathPtr);
    } catch (e) {
      debugPrint('Failed to set sparse file flag: $e');
    }
  }

  void _startSupervisor(
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) {
    _speed = SpeedTracker(emaAlpha: 0.12);
    _speed.start(initialBytes: _totalDownloaded);
    _sendStatusUpdate();

    _monitorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _supervisorTick++;

      _lastTotalDownloaded = _totalDownloaded;

      final displaySpeed = _speed.update(_totalDownloaded);
      final remaining = _totalFileSize - _totalDownloaded;
      final eta = _speed.formatEta(remaining);

      // Throttle state persistence
      final now = DateTime.now();
      if (now.difference(_lastStateSave) >= _stateSaveInterval) {
        _lastStateSave = now;
        _saveState();
      }

      _sendStatusUpdate(displaySpeed, eta);

      // Dynamic splitting every ~2s
      if (_supervisorTick % 4 == 0) {
        _checkAndSplit(url, headers, writerPort);
      }
    });
  }

  // Emits current download status to the stream.
  void _sendStatusUpdate([double? speed, String? eta]) {
    if (_statusController.isClosed) return;

    final displaySpeed = speed ?? _speed.displaySpeed;
    final calculatedEta =
        eta ?? _speed.formatEta(_totalFileSize - _totalDownloaded);

    final workersInfo = _workers
        .map((w) => {
              'id': w.id,
              'progress': w.endPos - w.startPos > 0
                  ? (w.currentPos - w.startPos) / (w.endPos - w.startPos)
                  : 0.0,
              'isDone': w.isDone,
              'startPos': w.startPos,
              'currentPos': w.currentPos,
              'endPos': w.endPos,
            })
        .toList();

    _statusController.add({
      'status': 'running',
      'progress': _totalFileSize > 0 ? _totalDownloaded / _totalFileSize : 0.0,
      'speed': displaySpeed,
      'eta': calculatedEta,
      'downloaded': _totalDownloaded,
      'totalSize': _totalFileSize,
      'activeWorkers': _workers.where((w) => !w.isDone).length,
      'totalWorkers': _workers.length,
      'workers': workersInfo,
    });
  }

  void _checkAndSplit(
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) {
    int active = _workers.where((w) => !w.isDone).length;
    if (active >= maxWorkers) return;

    _WorkerState? slowest;
    int maxRemaining = 0;
    for (var w in _workers) {
      if (w.isDone) continue;
      final rem = w.endPos - w.currentPos;
      if (rem > maxRemaining) {
        maxRemaining = rem;
        slowest = w;
      }
    }

    if (slowest != null &&
        maxRemaining > minChunkSize * 2 &&
        _workers.length < maxWorkers * 2) {
      final newEnd = slowest.currentPos + (maxRemaining ~/ 2);
      final oldEnd = slowest.endPos;

      if (slowest.workerPort == null) return;
      try {
        slowest.workerPort!
            .send({'cmd': 'updateEnd', 'newEnd': newEnd, 'oldEnd': oldEnd});
      } catch (e) {
        debugPrint('Failed to send updateEnd to worker ${slowest.id}: $e');
        return;
      }

      slowest.endPos = newEnd;
      final newWorker = _WorkerState(
        id: _workers.length,
        startPos: newEnd + 1,
        currentPos: newEnd + 1,
        endPos: oldEnd,
        isDone: false,
      );
      _workers.add(newWorker);
      _spawnWorker(newWorker, url, headers, writerPort);
    }
  }

  void _checkAllDone() {
    if (_workers.every((w) => w.isDone) && !_taskCompleter.isCompleted) {
      _taskCompleter.complete();
    }
  }

  // Cooperatively pauses all workers and persists state.
  Future<void> pause() async {
    _monitorTimer?.cancel();

    final activeWorkers =
        _workers.where((w) => !w.isDone && w.workerPort != null).toList();

    if (activeWorkers.isNotEmpty) {
      _cancelCompleter = Completer<void>();
      _pendingCancelCount = activeWorkers.length;

      for (var w in activeWorkers) {
        try {
          w.workerPort!.send({'cmd': 'cancel'});
        } catch (_) {
          _pendingCancelCount--;
        }
      }

      if (_pendingCancelCount > 0) {
        await _cancelCompleter!.future.timeout(
          const Duration(seconds: 3),
          onTimeout: () => debugPrint(
              'Cancel timeout — $_pendingCancelCount workers did not respond'),
        );
      }
    }

    for (var w in _workers) {
      try {
        w.isolate?.kill(priority: Isolate.immediate);
      } catch (_) {}
      w.isolate = null;
    }

    await Future.delayed(const Duration(milliseconds: 100));
    for (var w in _workers) {
      try {
        w.receivePort?.close();
      } catch (_) {}
      w.receivePort = null;
    }

    _cancelCompleter = null;
    await _saveState();

    if (_writerSendPort != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        _writerSendPort!.send({'cmd': 'close'});
      } catch (_) {}
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
      try {
        w.isolate?.kill(priority: Isolate.immediate);
      } catch (_) {}
      w.isolate = null;
      try {
        w.receivePort?.close();
      } catch (_) {}
      w.receivePort = null;
    }

    if (_writerSendPort != null) {
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        _writerSendPort!.send({'cmd': 'close'});
      } catch (_) {}
      _writerSendPort = null;
    }

    if (!_statusController.isClosed) await _statusController.close();
  }
}

class _WorkerState {
  final int id;
  int startPos;
  int currentPos;
  int endPos;
  bool isDone;
  Isolate? isolate;
  SendPort? workerPort;
  ReceivePort? receivePort;

  _WorkerState({
    required this.id,
    required this.startPos,
    required this.currentPos,
    required this.endPos,
    required this.isDone,
  });
}

class _WorkerIsolateInitData {
  final SendPort workerSendPort;
  final int workerId;
  final String url;
  final Map<String, String> headers;
  final int startPos;
  final int currentPos;
  final int endPos;
  final SendPort writerPort;

  _WorkerIsolateInitData({
    required this.workerSendPort,
    required this.workerId,
    required this.url,
    required this.headers,
    required this.startPos,
    required this.currentPos,
    required this.endPos,
    required this.writerPort,
  });
}
