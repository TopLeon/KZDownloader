import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memory_service.g.dart';

/// Monitors the app's memory usage via ProcessInfo.currentRss.
/// Exposes a Stream<int> with the current MB usage and tracks peak memory.
class MemoryService {
  final _controller = StreamController<int>.broadcast();
  int _peakMb = 0;
  Timer? _timer;

  Stream<int> get stream => _controller.stream;
  int get peakMb => _peakMb;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final mb = ProcessInfo.currentRss ~/ (1024 * 1024);
      if (mb > _peakMb) _peakMb = mb;
      if (!_controller.isClosed) _controller.add(mb);
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

@Riverpod(keepAlive: true)
MemoryService memoryService(Ref ref) {
  final service = MemoryService();
  service.start();
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
Stream<int> memoryUsage(Ref ref) {
  return ref.watch(memoryServiceProvider).stream;
}
