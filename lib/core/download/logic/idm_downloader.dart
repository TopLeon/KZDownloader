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

/// Proxy configuration data object.
class ProxyConfig {
  final String host;
  final int port;
  final String type; // 'http' or 'socks5'
  final String? username;
  final String? password;

  const ProxyConfig({
    required this.host,
    required this.port,
    this.type = 'http',
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'type': type,
        'username': username,
        'password': password,
      };

  factory ProxyConfig.fromJson(Map<String, dynamic> json) => ProxyConfig(
        host: json['host'] as String,
        port: json['port'] as int,
        type: json['type'] as String? ?? 'http',
        username: json['username'] as String?,
        password: json['password'] as String?,
      );
}

// IDM-like multi-threaded downloader with resume, dynamic splitting, and state persistence.
// Workers run as real Dart isolates for multi-core parallelism.
// File I/O is serialized through a dedicated writer isolate.
// Enhanced with advanced network resilience, drift detection, and adaptive retries.
class IDMDownloader {
  final int maxWorkers;
  final int minChunkSize;
  final int globalSpeedLimit; // bytes/sec, 0 = unlimited
  final ProxyConfig? proxyConfig;
  String _currentUrl = "";
  bool _isSaving = false;

  final List<_WorkerState> _workers = [];
  final List<_WorkerState> _pendingWorkers = [];
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
  // ignore: unused_field
  int _supervisorTick = 0;
  DateTime _lastSplitCheck = DateTime.now();
  bool _splitDisabled = false;
  static const int _maxTotalSegments = 64;

  late final SpeedTracker _speed;
  final List<double> _speedHistory = [];
  static const int _maxSpeedHistorySamples = 60;

  DateTime? _startTime; // for 24h timeout
  bool _proxyDowngraded = false;

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
    this.globalSpeedLimit = 0,
    this.proxyConfig,
  });

  /// Calculates the optimal number of workers based on file size.
  static int calculateOptimalWorkers(int fileSize, int userMaxWorkers) {
    if (fileSize <= 0) return 1;
    if (fileSize < 1024 * 1024) return 1;
    if (fileSize < 50 * 1024 * 1024) return min(4, userMaxWorkers);
    if (fileSize < 500 * 1024 * 1024) return min(8, userMaxWorkers);
    return min(16, userMaxWorkers);
  }

  /// Returns the split check interval based on file size.
  Duration _splitCheckInterval() {
    if (_totalFileSize < 100 * 1024 * 1024) return const Duration(seconds: 3);
    if (_totalFileSize < 1024 * 1024 * 1024) return const Duration(seconds: 5);
    return const Duration(seconds: 10);
  }

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

    // Set start time (may be overridden by resume)
    _startTime = DateTime.now();

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

        if (!acceptRanges || _totalFileSize < 1024 * 1024) {
          if (!acceptRanges) {
            debugPrint(
                "Server does not support Range requests, using single thread");
          } else {
            debugPrint("File < 1MB, using single thread");
          }
          _splitDisabled = true;
          _workers.add(_WorkerState(
            id: 0,
            startPos: 0,
            currentPos: 0,
            endPos: _totalFileSize - 1,
            isDone: false,
          ));
        } else {
          int effectiveWorkers =
              calculateOptimalWorkers(_totalFileSize, maxWorkers);
          effectiveWorkers =
              min(effectiveWorkers, _totalFileSize ~/ minChunkSize);
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

        // Recover startTime from meta
        if (state['startTime'] != null) {
          _startTime = DateTime.fromMillisecondsSinceEpoch(state['startTime']);
        }

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
        'startTime': _startTime?.millisecondsSinceEpoch,
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
          case 'proxy_downgrade':
            _proxyDowngraded = true;
            debugPrint(
                'Worker ${w.id} downgraded from proxy to direct connection');
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

    final activeCount = _workers.where((x) => !x.isDone).length;
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
        globalSpeedLimit: globalSpeedLimit,
        activeWorkerCount: max(1, activeCount),
        proxyConfig: proxyConfig,
      ),
    );

    await readyCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Worker ${w.id} failed to initialize in time');
      },
    );
  }

  static void _workerIsolateEntryPoint(_WorkerIsolateInitData init) async {
    await Rhttp.init();

    final receivePort = ReceivePort();
    init.workerSendPort.send({'type': 'ready', 'port': receivePort.sendPort});

    int currentPos = init.currentPos;
    int endPos = init.endPos;
    final mainPort = init.workerSendPort;

    bool cancelled = false;
    bool isUnknownSize = (endPos == -1);
    bool useProxy = init.proxyConfig != null;

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
    const int maxRetries = 50;
    final random = Random();

    // Speed throttle state
    final workerSpeedLimit = init.globalSpeedLimit > 0
        ? (init.globalSpeedLimit / max(1, init.activeWorkerCount))
        : 0.0;

    try {
      while (!cancelled && (isUnknownSize || currentPos <= endPos)) {
        try {
          final rustStream = downloadChunkStream(
            init.url,
            currentPos,
            isUnknownSize ? -1 : endPos,
            init.headers,
            proxy: useProxy ? init.proxyConfig : null,
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
          const int batchSize = 512 * 1024; // Lower batch size to reduce latency spikes on write isolate
          int localBytes = 0;

          final ackPort = ReceivePort();
          final ackSendPort = ackPort.sendPort;
          final ackIterator = StreamIterator(ackPort);

          DateTime lastProgressUpdate = DateTime.now();
          const progressInterval = Duration(milliseconds: 50);

          // Throttle tracking
          final throttleStopwatch = Stopwatch()..start();
          int throttleBatchBytes = 0;

          await for (final chunk in controller.stream) {
            if (cancelled) break;
            if (retryCount > 0) retryCount = 0;
            if (!isUnknownSize && currentPos > endPos) break;

            Uint8List data = chunk;

            if (!isUnknownSize) {
              final limit = endPos - currentPos + 1;
              if (chunk.length > limit) {
                data = chunk.sublist(0, limit);
              }
            }

            if (data.isNotEmpty) {
              buffer.add(data);
              currentPos += data.length;
              localBytes += data.length;
              throttleBatchBytes += data.length;

              // Speed throttle enforcement with token bucket approximation
              if (workerSpeedLimit > 0) {
                final elapsedSec =
                    throttleStopwatch.elapsedMilliseconds / 1000.0;
                if (elapsedSec > 0) {
                  final currentRate = throttleBatchBytes / elapsedSec;
                  if (currentRate > workerSpeedLimit) {
                    final expectedTime = throttleBatchBytes / workerSpeedLimit;
                    final delayMs =
                        ((expectedTime - elapsedSec) * 1000).toInt();
                    if (delayMs > 0) {
                      await Future.delayed(Duration(milliseconds: delayMs));
                    }
                  }
                }
                // Continuous token bucket like window
                if (throttleStopwatch.elapsedMilliseconds > 1000) {
                  final deduction = workerSpeedLimit.toInt();
                  throttleBatchBytes -= deduction;
                  if (throttleBatchBytes < 0) throttleBatchBytes = 0;
                  throttleStopwatch.reset();
                  // For a precise token bucket we'd just track the elapsed time,
                  // but this is a simple sufficient approximation.
                }
              }

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

          final err = e.toString().toLowerCase();

          // Manages critical errors
          if (err.contains("403") || err.contains("forbidden")) {
            mainPort
                .send({'type': 'error', 'message': "Link Expired (403): $e"});
            return;
          }
          if (err.contains("416") || err.contains("range not satisfiable")) {
            mainPort.send({
              'type': 'error',
              'message': "Range Not Satisfiable (416): $e"
            });
            return;
          }

          // Proxy fallback on 502, 503, 504, 407
          if (useProxy &&
              (err.contains("502") ||
                  err.contains("503") ||
                  err.contains("504") ||
                  err.contains("407"))) {
            useProxy = false;
            mainPort.send({
              'type': 'proxy_downgrade',
              'workerId': init.workerId,
              'error': e.toString()
            });
            debugPrint(
                'Worker ${init.workerId}: Proxy error, falling back to direct connection');
            continue; // Retry without proxy
          }

          retryCount++;
          if (retryCount >= maxRetries) {
            mainPort.send({
              'type': 'error',
              'message': "Worker ${init.workerId} max retries exceeded: $e"
            });
            return;
          }

          int delayMs;
          if (err.contains("429") || err.contains("too many requests")) {
            delayMs = (10 + random.nextInt(10)) *
                1000; // 10-20 seconds per Rate Limit
          } else if (retryCount <= 10) {
            delayMs = 20 + (retryCount * 10); // 20-120ms
          } else if (retryCount <= 30) {
            delayMs = 200 + (retryCount * 20); // 200-800ms
          } else {
            delayMs = 1500 + random.nextInt(1000); // Up to 2.5s
          }

          if (retryCount % 10 == 1) {
            debugPrint(
                "Worker ${init.workerId} retry $retryCount/$maxRetries: $e");
          }
          await Future.delayed(Duration(milliseconds: delayMs));
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
    await ackIterator.moveNext();
  }

  Future<void> _spawnWriter() async {
    final rp = ReceivePort();
    _writerIsolate = await Isolate.spawn(_writerEntryPoint, rp.sendPort);
    _writerSendPort = await rp.first as SendPort;
    _writerPortCompleter.complete(_writerSendPort);
  }

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
    _speed = SpeedTracker(emaAlpha: 0.30);
    _speed.start(initialBytes: _totalDownloaded);
    _sendStatusUpdate();

    _lastSplitCheck = DateTime.now();

    _monitorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _supervisorTick++;

      // 24h timeout check
      if (_startTime != null &&
          DateTime.now().difference(_startTime!).inHours >= 24) {
        debugPrint('Download exceeded 24h timeout, stopping.');
        if (!_statusController.isClosed) {
          _statusController.add({
            'status': 'timeout',
            'message': 'Download exceeded 24 hour limit'
          });
        }
        pause();
        return;
      }

      // Drift Detection
      final realTotalDownloaded = _workers.fold<int>(
          0, (sum, w) => sum + max(0, w.currentPos - w.startPos));

      final driftThreshold = max(256 * 1024, (_totalFileSize * 0.001).toInt());
      if ((_totalDownloaded - realTotalDownloaded).abs() > driftThreshold) {
        debugPrint(
            'Progress drift detected: $_totalDownloaded vs $realTotalDownloaded, calibrating');
        // Graduale correzione per prevenire spike bruschi di velocità
        _totalDownloaded = ((_totalDownloaded * 3 + realTotalDownloaded) ~/ 4);
      }

      // Clamp
      if (_totalFileSize > 0 && _totalDownloaded > _totalFileSize) {
        _totalDownloaded = _totalFileSize;
      }

      _lastTotalDownloaded = _totalDownloaded;

      final displaySpeed = _speed.update(_totalDownloaded);
      final remaining = _totalFileSize - _totalDownloaded;
      final eta = _speed.formatEta(remaining);

      // Track speed history (last 60 samples)
      _speedHistory.add(displaySpeed);
      if (_speedHistory.length > _maxSpeedHistorySamples) {
        _speedHistory.removeAt(0);
      }

      final now = DateTime.now();
      if (now.difference(_lastStateSave) >= _stateSaveInterval) {
        _lastStateSave = now;
        _saveState();
      }

      _sendStatusUpdate(displaySpeed, eta);

      // Spawn pending workers up to concurrency limit
      _drainPendingWorkers(url, headers, writerPort);

      // Adaptive split check interval based on file size
      if (!_splitDisabled &&
          now.difference(_lastSplitCheck) >= _splitCheckInterval()) {
        _lastSplitCheck = now;
        _checkAndSplit(url, headers, writerPort);
      }
    });
  }

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
      'speedHistory': List<double>.from(_speedHistory),
      'proxyActive': proxyConfig != null && !_proxyDowngraded,
    });
  }

  /// Drains the pending worker queue, spawning workers up to the concurrency limit.
  void _drainPendingWorkers(
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) {
    if (_pendingWorkers.isEmpty) return;

    final maxConcurrent = calculateOptimalWorkers(_totalFileSize, maxWorkers);
    int activeIsolates =
        _workers.where((w) => !w.isDone && !_pendingWorkers.contains(w)).length;

    while (_pendingWorkers.isNotEmpty && activeIsolates < maxConcurrent) {
      final worker = _pendingWorkers.removeAt(0);
      _spawnWorker(worker, url, headers, writerPort);
      activeIsolates++;
    }
  }

  void _checkAndSplit(
    String url,
    Map<String, String> headers,
    SendPort writerPort,
  ) {
    if (_splitDisabled) return;
    if (_workers.length >= _maxTotalSegments) return;

    final activeWorkers = _workers.where((w) => !w.isDone).toList();
    if (activeWorkers.length <= 1) return;

    // Calculate average remaining bytes across active workers
    final remainingList =
        activeWorkers.map((w) => w.endPos - w.currentPos).toList();
    final avgRemaining =
        remainingList.fold<int>(0, (s, r) => s + r) / activeWorkers.length;

    const int minSplitThreshold = 20 * 1024 * 1024; // 20 MB
    final double slowFactor = 2.0;

    for (var w in activeWorkers) {
      if (_workers.length >= _maxTotalSegments) break;

      final remaining = w.endPos - w.currentPos;
      if (remaining <= minSplitThreshold) continue;
      if (remaining <= avgRemaining * slowFactor) continue;

      // This worker is a "slow" segment — split it
      final newEnd = w.currentPos + (remaining ~/ 2);
      final oldEnd = w.endPos;

      if (w.workerPort == null) continue;
      try {
        w.workerPort!
            .send({'cmd': 'updateEnd', 'newEnd': newEnd, 'oldEnd': oldEnd});
      } catch (e) {
        debugPrint('Failed to send updateEnd to worker ${w.id}: $e');
        continue;
      }

      w.endPos = newEnd;
      final newWorker = _WorkerState(
        id: _workers.length,
        startPos: newEnd + 1,
        currentPos: newEnd + 1,
        endPos: oldEnd,
        isDone: false,
      );
      _workers.add(newWorker);
      _pendingWorkers.add(newWorker);
    }
  }

  void _checkAllDone() {
    if (_pendingWorkers.isEmpty &&
        _workers.every((w) => w.isDone) &&
        !_taskCompleter.isCompleted) {
      _taskCompleter.complete();
    }
  }

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
  final int globalSpeedLimit;
  final int activeWorkerCount;
  final ProxyConfig? proxyConfig;

  _WorkerIsolateInitData({
    required this.workerSendPort,
    required this.workerId,
    required this.url,
    required this.headers,
    required this.startPos,
    required this.currentPos,
    required this.endPos,
    required this.writerPort,
    this.globalSpeedLimit = 0,
    this.activeWorkerCount = 1,
    this.proxyConfig,
  });
}
