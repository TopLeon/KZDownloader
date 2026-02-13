import 'dart:math';

// Helper methods for download related formatting.
class DownloadHelper {
  // Formats bytes into human readable string.
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Formats download speed into human readable string.
  static String formatSpeed(double bytesPerSecond) {
    return '${formatBytes(bytesPerSecond.toInt())}/s';
  }
}
