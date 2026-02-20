import 'package:flutter/material.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

class UrlUtils {
  // Detects the provider (e.g., yt-dlp, http) based on the URL.
  static String detectProvider(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      final ytDlpDomains = [
        'youtube.com',
        'youtu.be',
        'dailymotion.com',
        'dai.ly',
        'vimeo.com',
        'twitch.tv',
        'tiktok.com',
        'instagram.com',
        'facebook.com',
        'fb.watch',
        'twitter.com',
        'x.com',
        'reddit.com',
        'soundcloud.com',
        'mixcloud.com',
        'bandcamp.com'
      ];

      if (ytDlpDomains.any((domain) => host.contains(domain))) {
        return 'yt-dlp';
      }

      return 'http';
    } catch (_) {
      return 'http';
    }
  }

  // Extracts the first valid URL from a given text.
  static String? extractUrl(String text) {
    final RegExp urlRegExp = RegExp(
      r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/[^\s]+)",
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    return match?.group(0);
  }

  // Categorizes a URL into specific types like video or music.
  static TaskCategory detectCategory(String url) {
    final lowerUrl = url.toLowerCase();

    if (isYouTubePlaylist(url)) {
      return TaskCategory.playlist;
    }

    if (lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('vimeo.com') ||
        lowerUrl.contains('twitch.tv') ||
        lowerUrl.contains('dailymotion.com') ||
        lowerUrl.contains('dai.ly') ||
        lowerUrl.contains('tiktok.com') ||
        lowerUrl.contains('facebook.com') ||
        lowerUrl.contains('instagram.com')) {
      return TaskCategory.video;
    }

    if (lowerUrl.contains('spotify.com') ||
        lowerUrl.contains('soundcloud.com') ||
        lowerUrl.contains('bandcamp.com') ||
        lowerUrl.contains('mixcloud.com')) {
      return TaskCategory.music;
    }

    // Check file extension for direct downloads
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final path = uri.path.toLowerCase();

      // Document/Generic file extensions
      if (path.endsWith('.pdf') ||
          path.endsWith('.doc') ||
          path.endsWith('.docx') ||
          path.endsWith('.txt') ||
          path.endsWith('.zip') ||
          path.endsWith('.rar') ||
          path.endsWith('.7z') ||
          path.endsWith('.tar') ||
          path.endsWith('.gz') ||
          path.endsWith('.exe') ||
          path.endsWith('.dmg') ||
          path.endsWith('.apk') ||
          path.endsWith('.iso') ||
          path.endsWith('.xls') ||
          path.endsWith('.xlsx') ||
          path.endsWith('.ppt') ||
          path.endsWith('.pptx')) {
        return TaskCategory.generic;
      }

      // Video file extensions (direct links)
      if (path.endsWith('.mp4') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          path.endsWith('.mov') ||
          path.endsWith('.wmv') ||
          path.endsWith('.flv') ||
          path.endsWith('.webm') ||
          path.endsWith('.m4v')) {
        return TaskCategory.video;
      }

      // Audio file extensions (direct links)
      if (path.endsWith('.mp3') ||
          path.endsWith('.wav') ||
          path.endsWith('.flac') ||
          path.endsWith('.aac') ||
          path.endsWith('.ogg') ||
          path.endsWith('.m4a') ||
          path.endsWith('.wma')) {
        return TaskCategory.music;
      }
    }

    return TaskCategory.generic;
  }

  // Checks if the URL is a YouTube playlist.
  static bool isYouTubePlaylist(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      if (!host.contains('youtube.com') && !host.contains('youtu.be')) {
        return false;
      }

      return uri.queryParameters.containsKey('list');
    } catch (_) {
      return false;
    }
  }

  // Extracts the playlist ID from a YouTube URL.
  static String? extractPlaylistId(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['list'];
    } catch (_) {
      return null;
    }
  }
}

// Calculates the elapsed time since [startTime] and returns a human-readable string.
// If [context] is provided, it uses localized strings, otherwise defaults to english.
String calculateProcessTime(DateTime startTime, [BuildContext? context]) {
  final duration = DateTime.now().difference(startTime);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final milliseconds = duration.inMilliseconds.remainder(1000);

  // Get localized strings or use english as fallback
  String hourStr,
      hoursStr,
      minuteStr,
      minutesStr,
      secondStr,
      secondsStr,
      millisecondStr,
      millisecondsStr,
      andStr;

  if (context != null) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      hourStr = l10n.hour;
      hoursStr = l10n.hours;
      minuteStr = l10n.minute;
      minutesStr = l10n.minutes;
      secondStr = l10n.second;
      secondsStr = l10n.seconds;
      millisecondStr = l10n.millisecond;
      millisecondsStr = l10n.milliseconds;
      andStr = l10n.and;
    } else {
      // Fallback to english
      hourStr = 'hour';
      hoursStr = 'hours';
      minuteStr = 'minute';
      minutesStr = 'minutes';
      secondStr = 'second';
      secondsStr = 'seconds';
      millisecondStr = 'millisecond';
      millisecondsStr = 'milliseconds';
      andStr = 'and';
    }
  } else {
    // Fallback to english when no context
    hourStr = 'hour';
    hoursStr = 'hours';
    minuteStr = 'minute';
    minutesStr = 'minutes';
    secondStr = 'second';
    secondsStr = 'seconds';
    millisecondStr = 'millisecond';
    millisecondsStr = 'milliseconds';
    andStr = 'and';
  }

  if (hours > 0) {
    final hStr = "$hours ${hours == 1 ? hourStr : hoursStr}";
    final mStr = "$minutes ${minutes == 1 ? minuteStr : minutesStr}";
    return minutes > 0 ? "$hStr $andStr $mStr" : hStr;
  } else if (minutes > 0) {
    final mStr = "$minutes ${minutes == 1 ? minuteStr : minutesStr}";
    final sStr = "$seconds ${seconds == 1 ? secondStr : secondsStr}";
    return seconds > 0 ? "$mStr $andStr $sStr" : mStr;
  } else if (seconds > 0) {
    return "$seconds ${seconds == 1 ? secondStr : secondsStr}";
  } else {
    // Show milliseconds when less than 1 second
    return "$milliseconds ${milliseconds == 1 ? millisecondStr : millisecondsStr}";
  }
}

class FileUtils {
  /// Reserved Windows device names (case-insensitive).
  static const _windowsReservedNames = {
    'CON', 'PRN', 'AUX', 'NUL',
    'COM0', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
    'LPT0', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
  };

  /// Returns a version of [name] that is safe to use as a filename on
  /// Windows, macOS and Linux.
  ///
  /// - Replaces characters forbidden by Windows / Unix filesystems with [replacement].
  /// - Strips control characters (U+0000–U+001F).
  /// - Removes trailing dots and spaces (disallowed by Windows).
  /// - Prefixes Windows reserved device names with [replacement].
  /// - Trims the result to [maxLength] characters.
  /// - Falls back to `'download'` when the result would otherwise be empty.
  static String sanitizeFilename(
    String name, {
    String replacement = '_',
    int maxLength = 200,
  }) {
    // 1. Replace forbidden characters and control characters.
    var result = name.replaceAll(
      RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
      replacement,
    );

    // 2. Strip trailing dots and spaces (Windows rejects them).
    result = result.replaceAll(RegExp(r'[. ]+$'), '');

    // 3. Prefix reserved Windows device names to avoid conflicts.
    final stem = result.contains('.')
        ? result.substring(0, result.lastIndexOf('.'))
        : result;
    if (_windowsReservedNames.contains(stem.toUpperCase())) {
      result = '$replacement$result';
    }

    // 4. Enforce maximum length.
    if (result.length > maxLength) {
      result = result.substring(0, maxLength);
    }

    // 5. Fallback for empty result.
    return result.trim().isEmpty ? 'download' : result;
  }
}
