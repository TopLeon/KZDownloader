// Tracks download speed using a blend of session-average and EMA for smooth display.
class SpeedTracker {
  final double _emaAlpha;
  final double _sessionWeight;

  double _emaSpeed = 0.0;
  double _sessionAvgSpeed = 0.0;
  int _sessionDownloaded = 0;
  late DateTime _sessionStart;
  int _lastDownloaded = 0;
  DateTime? _lastUpdate;

  SpeedTracker({
    double emaAlpha = 0.15,
    double sessionWeight = 0.8,
  })  : _emaAlpha = emaAlpha,
        _sessionWeight = sessionWeight;

  // Initializes tracking from a given byte offset (useful for resume).
  void start({int initialBytes = 0}) {
    _sessionStart = DateTime.now();
    _lastUpdate = _sessionStart;
    _lastDownloaded = initialBytes;
    _sessionDownloaded = 0;
    _emaSpeed = 0.0;
    _sessionAvgSpeed = 0.0;
  }

  // Updates speed calculation with the current total received bytes.
  // Returns the blended display speed in bytes/sec, or 0 if no time has passed.
  double update(int totalReceived) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastUpdate!).inMilliseconds;
    if (elapsed < 300) return displaySpeed;

    final diff = totalReceived - _lastDownloaded;

    // EMA speed
    if (diff > 0) {
      final timeSec = elapsed / 1000.0;
      final instant = diff / timeSec;
      _emaSpeed = _emaSpeed == 0
          ? instant
          : _emaAlpha * instant + (1 - _emaAlpha) * _emaSpeed;
    }

    // Session average speed
    _sessionDownloaded += diff;
    final sessionSec =
        now.difference(_sessionStart).inMicroseconds / 1000000.0;
    if (sessionSec > 0.5 && _sessionDownloaded > 0) {
      _sessionAvgSpeed = _sessionDownloaded / sessionSec;
    }

    _lastDownloaded = totalReceived;
    _lastUpdate = now;
    return displaySpeed;
  }

  // Returns the blended display speed in bytes/sec.
  double get displaySpeed => _sessionAvgSpeed > 0
      ? _sessionAvgSpeed * _sessionWeight + _emaSpeed * (1 - _sessionWeight)
      : _emaSpeed;

  // Estimates remaining time given [remainingBytes].
  String? formatEta(int remainingBytes) {
    if (_sessionAvgSpeed <= 0 || remainingBytes <= 0) return null;
    final seconds = remainingBytes / _sessionAvgSpeed;
    if (seconds.isNaN || seconds.isInfinite || seconds < 0) return '...';
    if (seconds < 60) return '${seconds.toInt()}s';
    if (seconds < 3600) {
      final m = (seconds / 60).toInt();
      final s = (seconds % 60).toInt();
      return '${m}m ${s}s';
    }
    final h = (seconds / 3600).toInt();
    final m = ((seconds % 3600) / 60).toInt();
    return '${h}h ${m}m';
  }

  // Formats raw bytes/sec into a human-readable speed string.
  static String formatSpeed(double bytesPerSec) {
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(2)}MiB/s';
  }
}
