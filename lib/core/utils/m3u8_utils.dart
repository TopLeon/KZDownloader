import 'package:kzdownloader/models/download_task.dart';

/// Represents a single media segment from an M3U8 media playlist.
class M3U8Segment {
  final String url;
  final double? duration;

  const M3U8Segment({required this.url, this.duration});
}

/// Represents encryption info from #EXT-X-KEY.
class M3U8Encryption {
  final String method; // AES-128, NONE, etc.
  final String? keyUri;
  final String? iv;

  const M3U8Encryption({required this.method, this.keyUri, this.iv});
}

/// Represents a variant stream from a master playlist.
class M3U8Variant {
  final String url;
  final int? bandwidth;
  final String? resolution;
  final String? name;
  final String? codecs;
  final double? frameRate;

  const M3U8Variant({
    required this.url,
    this.bandwidth,
    this.resolution,
    this.name,
    this.codecs,
    this.frameRate,
  });
}

/// Result of parsing an M3U8 file — either a master or media playlist.
class M3U8ParseResult {
  final bool isMasterPlaylist;

  /// Variants (only if master playlist)
  final List<M3U8Variant> variants;

  /// Segments (only if media playlist)
  final List<M3U8Segment> segments;

  /// Encryption info (only if media playlist with encryption)
  final M3U8Encryption? encryption;

  const M3U8ParseResult({
    required this.isMasterPlaylist,
    this.variants = const [],
    this.segments = const [],
    this.encryption,
  });

  /// Total duration of all segments in seconds.
  double get totalDuration {
    double total = 0;
    for (final seg in segments) {
      total += seg.duration ?? 0;
    }
    return total;
  }

  /// Human-readable duration string (e.g., "1h 23m 45s").
  String get formattedDuration {
    final totalSeconds = totalDuration.round();
    if (totalSeconds <= 0) return 'Unknown';
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0 || parts.isEmpty) parts.add('${s}s');
    return parts.join(' ');
  }

  /// Estimated file size in bytes for a given bandwidth (bits/s).
  int estimatedFileSize(int bandwidth) {
    return (bandwidth * totalDuration / 8).round();
  }
}

/// Represents a single entry parsed from an M3U8 file (for music playlist export/import).
class M3U8Entry {
  final String path;
  final String? title;
  final int? durationSeconds;

  const M3U8Entry({required this.path, this.title, this.durationSeconds});
}

/// Utility class for M3U8 playlist operations.
class M3U8Utils {
  /// Parses M3U8 content and determines if it's a master or media playlist.
  static M3U8ParseResult parseHLS(String content) {
    final lines = content.split(RegExp(r'\r?\n'));

    // Check if this is a master playlist (contains #EXT-X-STREAM-INF)
    final hasMasterTags =
        lines.any((l) => l.trim().startsWith('#EXT-X-STREAM-INF'));

    if (hasMasterTags) {
      return _parseMasterPlaylist(lines);
    } else {
      return _parseMediaPlaylist(lines);
    }
  }

  /// Parses a master playlist to extract variant streams.
  static M3U8ParseResult _parseMasterPlaylist(List<String> lines) {
    final variants = <M3U8Variant>[];
    int? pendingBandwidth;
    String? pendingResolution;
    String? pendingName;
    String? pendingCodecs;
    double? pendingFrameRate;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXT-X-STREAM-INF:')) {
        final attrs = line.substring('#EXT-X-STREAM-INF:'.length);
        pendingBandwidth = _extractIntAttr(attrs, 'BANDWIDTH');
        pendingResolution = _extractStringAttr(attrs, 'RESOLUTION');
        pendingName = _extractStringAttr(attrs, 'NAME');
        pendingCodecs = _extractStringAttr(attrs, 'CODECS');
        final frStr = _extractStringAttr(attrs, 'FRAME-RATE');
        pendingFrameRate = frStr != null ? double.tryParse(frStr) : null;
        continue;
      }

      if (line.startsWith('#')) continue;

      // This is a variant URL
      if (pendingBandwidth != null || pendingResolution != null) {
        variants.add(M3U8Variant(
          url: line,
          bandwidth: pendingBandwidth,
          resolution: pendingResolution,
          name: pendingName,
          codecs: pendingCodecs,
          frameRate: pendingFrameRate,
        ));
        pendingBandwidth = null;
        pendingResolution = null;
        pendingName = null;
        pendingCodecs = null;
        pendingFrameRate = null;
      }
    }

    // Sort by bandwidth descending (highest quality first)
    variants.sort((a, b) => (b.bandwidth ?? 0).compareTo(a.bandwidth ?? 0));

    return M3U8ParseResult(isMasterPlaylist: true, variants: variants);
  }

  /// Parses a media playlist to extract segments and encryption info.
  static M3U8ParseResult _parseMediaPlaylist(List<String> lines) {
    final segments = <M3U8Segment>[];
    M3U8Encryption? encryption;
    double? pendingDuration;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line == '#EXTM3U') continue;

      if (line.startsWith('#EXT-X-KEY:')) {
        final attrs = line.substring('#EXT-X-KEY:'.length);
        final method = _extractStringAttr(attrs, 'METHOD') ?? 'NONE';
        if (method != 'NONE') {
          encryption = M3U8Encryption(
            method: method,
            keyUri: _extractStringAttr(attrs, 'URI'),
            iv: _extractStringAttr(attrs, 'IV'),
          );
        }
        continue;
      }

      if (line.startsWith('#EXTINF:')) {
        final afterTag = line.substring('#EXTINF:'.length);
        final commaIndex = afterTag.indexOf(',');
        if (commaIndex >= 0) {
          pendingDuration = double.tryParse(afterTag.substring(0, commaIndex));
        } else {
          pendingDuration = double.tryParse(afterTag);
        }
        continue;
      }

      // Skip other directives
      if (line.startsWith('#')) continue;

      // This is a segment URL
      segments.add(M3U8Segment(url: line, duration: pendingDuration));
      pendingDuration = null;
    }

    return M3U8ParseResult(
      isMasterPlaylist: false,
      segments: segments,
      encryption: encryption,
    );
  }

  /// Extracts an integer attribute from M3U8 tag attributes string.
  static int? _extractIntAttr(String attrs, String name) {
    final regex = RegExp('$name=(\\d+)');
    final match = regex.firstMatch(attrs);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Extracts a string attribute from M3U8 tag attributes string.
  static String? _extractStringAttr(String attrs, String name) {
    // Try quoted value first: NAME="value"
    final quotedRegex = RegExp('$name="([^"]*)"');
    final quotedMatch = quotedRegex.firstMatch(attrs);
    if (quotedMatch != null) return quotedMatch.group(1);

    // Try unquoted value: NAME=value
    final unquotedRegex = RegExp('$name=([^,]+)');
    final unquotedMatch = unquotedRegex.firstMatch(attrs);
    return unquotedMatch?.group(1);
  }

  /// Resolves relative URLs in M3U8 entries against a base URL.
  static String resolveUrl(String baseUrl, String entryPath) {
    if (entryPath.startsWith('http://') || entryPath.startsWith('https://')) {
      return entryPath;
    }

    final baseUri = Uri.parse(baseUrl);
    if (entryPath.startsWith('/')) {
      return baseUri.replace(path: entryPath).toString();
    }

    // Relative to base URL's directory
    final basePath = baseUri.path;
    final lastSlash = basePath.lastIndexOf('/');
    final dir = lastSlash >= 0 ? basePath.substring(0, lastSlash + 1) : '/';
    return baseUri.replace(path: '$dir$entryPath').toString();
  }

  // =========================================================================
  // Music playlist M3U8 export/import (separate from HLS)
  // =========================================================================

  /// Generates M3U8 content string from a list of download tasks.
  static String exportPlaylistToM3U8(List<DownloadTask> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');

    for (final task in tasks) {
      if (task.filePath == null) continue;

      final title = task.title ?? 'Unknown';
      final channel = task.channelName;
      final label = channel != null ? '$title - $channel' : title;

      buffer.writeln('#EXTINF:-1,$label');
      buffer.writeln(task.filePath);
    }

    return buffer.toString();
  }

  /// Parses M3U8 content for music playlist import (simple #EXTINF + path).
  static List<M3U8Entry> parseM3U8(String content) {
    final entries = <M3U8Entry>[];
    final lines = content.split(RegExp(r'\r?\n'));

    String? pendingTitle;
    int? pendingDuration;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line == '#EXTM3U') continue;

      if (line.startsWith('#EXTINF:')) {
        final afterTag = line.substring('#EXTINF:'.length);
        final commaIndex = afterTag.indexOf(',');
        if (commaIndex >= 0) {
          pendingDuration = int.tryParse(afterTag.substring(0, commaIndex));
          pendingTitle = afterTag.substring(commaIndex + 1).trim();
        }
        continue;
      }

      if (line.startsWith('#')) continue;

      entries.add(M3U8Entry(
        path: line,
        title: pendingTitle,
        durationSeconds: pendingDuration,
      ));
      pendingTitle = null;
      pendingDuration = null;
    }

    return entries;
  }
}
