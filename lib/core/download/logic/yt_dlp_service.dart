import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:kzdownloader/core/utils/binary_manager.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Handles yt-dlp operations: metadata retrieval, subtitle extraction, and download management.
class YtDlpService {
  final BinaryManager _binaryManager = BinaryManager();
  final YoutubeExplode _yt = YoutubeExplode();

  // Retrieves metadata using youtube_explode (fast, YouTube only) with yt-dlp fallback.
  Future<Map<String, dynamic>> getMetadata(String url) async {
    if (_isYouTubeUrl(url)) {
      try {
        return await _getMetadataWithYoutubeExplode(url);
      } catch (e) {
        debugPrint('youtube_explode failed, falling back to yt-dlp: $e');
        return await _getMetadataWithYtDlp(url);
      }
    }
    return await _getMetadataWithYtDlp(url);
  }

  bool _isYouTubeUrl(String url) {
    try {
      final host = Uri.parse(url).host.toLowerCase();
      return host.contains('youtube.com') ||
          host.contains('youtu.be') ||
          host.contains('youtube-nocookie.com');
    } catch (_) {
      return false;
    }
  }

  // Fast native metadata extraction via youtube_explode_dart.
  Future<Map<String, dynamic>> _getMetadataWithYoutubeExplode(
      String url) async {
    final video = await _yt.videos.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
              'youtube_explode did not respond within 10 seconds.'),
        );

    final manifest =
        await _yt.videos.streamsClient.getManifest(video.id.value);

    final formats = <Map<String, dynamic>>[];

    for (var s in manifest.muxed) {
      formats.add({
        'format_id': s.tag.toString(),
        'ext': s.container.name,
        'quality': s.videoQuality.name,
        'filesize': s.size.totalBytes,
        'tbr': s.bitrate.bitsPerSecond / 1000,
        'vcodec': s.videoCodec,
        'acodec': s.audioCodec,
        'width': s.videoResolution.width,
        'height': s.videoResolution.height,
        'fps': s.framerate.framesPerSecond,
      });
    }

    for (var s in manifest.video) {
      formats.add({
        'format_id': s.tag.toString(),
        'ext': s.container.name,
        'quality': s.videoQuality.name,
        'filesize': s.size.totalBytes,
        'tbr': s.bitrate.bitsPerSecond / 1000,
        'vcodec': s.videoCodec,
        'acodec': 'none',
        'width': s.videoResolution.width,
        'height': s.videoResolution.height,
        'fps': s.framerate.framesPerSecond,
      });
    }

    for (var s in manifest.audio) {
      formats.add({
        'format_id': s.tag.toString(),
        'ext': s.container.name,
        'quality': 'audio only',
        'filesize': s.size.totalBytes,
        'tbr': s.bitrate.bitsPerSecond / 1000,
        'vcodec': 'none',
        'acodec': s.audioCodec,
        'abr': s.bitrate.bitsPerSecond / 1000,
      });
    }

    return {
      'id': video.id.value,
      'title': video.title,
      'description': video.description,
      'duration': video.duration?.inSeconds ?? 0,
      'thumbnail': video.thumbnails.highResUrl,
      'thumbnails': [
        {'url': video.thumbnails.lowResUrl, 'id': 'low'},
        {'url': video.thumbnails.mediumResUrl, 'id': 'medium'},
        {'url': video.thumbnails.highResUrl, 'id': 'high'},
        {'url': video.thumbnails.maxResUrl, 'id': 'maxres'},
      ],
      'uploader': video.author,
      'uploader_id': video.channelId.value,
      'channel': video.author,
      'channel_id': video.channelId.value,
      'channel_url': video.channelId.value.isNotEmpty
          ? 'https://www.youtube.com/channel/${video.channelId.value}'
          : null,
      'view_count': video.engagement.viewCount,
      'like_count': video.engagement.likeCount,
      'upload_date':
          video.uploadDate?.toString().replaceAll('-', '').substring(0, 8),
      'webpage_url': video.url,
      'formats': formats,
      'ext': manifest.muxed.isNotEmpty
          ? manifest.muxed.bestQuality.container.name
          : 'mp4',
      '_fetched_with': 'youtube_explode_dart',
    };
  }

  // Fallback metadata retrieval using the yt-dlp binary.
  Future<Map<String, dynamic>> _getMetadataWithYtDlp(String url) async {
    final execPath = await _binaryManager.getYtDlpPath();

    final args = [
      '--dump-json',
      '--no-playlist',
      '--flat-playlist',
      '--force-ipv4',
      '--no-warnings',
      '--skip-download',
      '--geo-bypass',
      '--ignore-config',
      '--user-agent',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
      url,
    ];

    try {
      final result = await Process.run(execPath, args).timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('yt-dlp did not respond within 30 seconds.'),
      );

      if (result.exitCode != 0) {
        final error = result.stderr.toString();
        if (error.contains('Unsupported URL')) {
          throw Exception('Unsupported URL or video unavailable.');
        }
        throw Exception('yt-dlp error (Exit ${result.exitCode}): $error');
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) throw Exception('yt-dlp returned empty output.');

      try {
        final metadata = jsonDecode(output);
        metadata['_fetched_with'] = 'yt-dlp';
        return metadata;
      } catch (_) {
        for (var line in const LineSplitter().convert(output)) {
          try {
            if (line.trim().startsWith('{')) {
              final metadata = jsonDecode(line);
              metadata['_fetched_with'] = 'yt-dlp';
              return metadata;
            }
          } catch (_) {}
        }
        throw Exception('Unable to parse metadata JSON.');
      }
    } on TimeoutException {
      throw Exception('Timeout: Server not responding.');
    }
  }

  void dispose() {
    _yt.close();
  }

  // Starts a yt-dlp download process.
  Future<Process> startDownload(
    String url,
    String downloadPath, {
    DownloadFormat format = DownloadFormat.mp4,
    DownloadQuality quality = DownloadQuality.best,
    String? tempPath,
    String? customFilename,
  }) async {
    final ytDlpPath = await _binaryManager.getYtDlpPath();
    final ffmpegPath = await _binaryManager.getFfmpegPath();
    final binDir = await _binaryManager.getBinariesPath();

    final env = Map<String, String>.from(Platform.environment);
    final sep = Platform.isWindows ? ';' : ':';
    env['PATH'] = '$binDir$sep${env['PATH'] ?? ""}';

    final args = [
      '--newline',
      '--ffmpeg-location',
      ffmpegPath,
      '--concurrent-fragments',
      '8',
    ];

    final outputTemplate = customFilename != null
        ? '$customFilename.%(ext)s'
        : '%(title)s.%(ext)s';

    if (tempPath != null) {
      args.addAll(['-P', 'temp:$tempPath', '-P', downloadPath, '-o', outputTemplate]);
    } else {
      args.addAll(['-o', '$downloadPath/$outputTemplate']);
    }

    _addFormatArgs(args, format, quality);
    args.add(url);
    return Process.start(ytDlpPath, args, environment: env);
  }

  void _addFormatArgs(
      List<String> args, DownloadFormat format, DownloadQuality quality) {
    if (format == DownloadFormat.mp3) {
      args.addAll(['-x', '--audio-format', 'mp3']);
    } else if (format == DownloadFormat.m4a) {
      args.addAll(['-x', '--audio-format', 'm4a']);
    } else if (format == DownloadFormat.ogg) {
      args.addAll(['-x', '--audio-format', 'vorbis']);
    } else {
      final hc = _heightConstraint(quality);
      if (format == DownloadFormat.mp4) {
        args.addAll([
          '-f',
          hc.isNotEmpty
              ? 'bv*$hc[ext=mp4]+ba[ext=m4a]/b$hc[ext=mp4] / bv*$hc+ba/b$hc'
              : 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b',
          '--merge-output-format',
          'mp4',
        ]);
      } else if (format == DownloadFormat.mkv) {
        if (hc.isNotEmpty) args.addAll(['-f', 'bv*$hc+ba/b$hc']);
        args.addAll(['--merge-output-format', 'mkv']);
      }
    }
  }

  String _heightConstraint(DownloadQuality quality) {
    switch (quality) {
      case DownloadQuality.best:
        return '';
      case DownloadQuality.high:
      case DownloadQuality.p1080:
        return '[height<=1080]';
      case DownloadQuality.medium:
      case DownloadQuality.p720:
        return '[height<=720]';
      case DownloadQuality.low:
      case DownloadQuality.p480:
        return '[height<=480]';
      case DownloadQuality.p1440:
        return '[height<=1440]';
      case DownloadQuality.p2160:
        return '[height<=2160]';
    }
  }

  // Fetches subtitles for a video, falling back to English if the requested language fails.
  Future<String?> fetchVideoSubtitles(String url,
      {String langCode = 'en'}) async {
    try {
      return await _fetchSubtitlesWithYtDlp(url, langCode);
    } catch (_) {
      return await _fetchSubtitlesWithYtDlp(url, 'en');
    }
  }

  Future<String?> _fetchSubtitlesWithYtDlp(String url, String langCode) async {
    Directory? tempDir;
    try {
      final ytDlpPath = await _binaryManager.getYtDlpPath();
      tempDir = Directory.systemTemp.createTempSync('yt_subs_');
      final filePath =
          '${tempDir.path}/subs_${DateTime.now().millisecondsSinceEpoch}';

      final result = await Process.run(ytDlpPath, [
        '--skip-download',
        '--write-sub',
        '--write-auto-sub',
        '--sub-lang',
        '$langCode,$langCode-orig',
        '--convert-subs',
        'vtt',
        '--force-ipv4',
        '--geo-bypass',
        '--ignore-config',
        '--user-agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        '-o',
        filePath,
        url,
      ]);

      final dirFiles = tempDir.listSync();
      File? subFile;

      try {
        subFile = dirFiles
            .map((e) => File(e.path))
            .firstWhere((f) => f.path.contains('.$langCode.vtt'));
      } catch (_) {
        for (var file in dirFiles) {
          if (file.path.endsWith('.vtt')) {
            subFile = File(file.path);
            break;
          }
        }
      }

      if (subFile != null) return _cleanVtt(await subFile.readAsString());
      if (result.exitCode != 0) {
        debugPrint("Subtitle extraction failed for lang=$langCode");
        throw Exception(result.stderr); 
      }
      return null;
    } catch (e) {
      debugPrint("Subtitle extraction failed for lang=$langCode");
      throw Exception(e);
    } finally {
      try {
        tempDir?.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  static final _vttTimestampRegex = RegExp(
      r'(\d{2}:)?\d{2}:\d{2}\.\d{3}\s-->\s(\d{2}:)?\d{2}:\d{2}\.\d{3}');
  static final _htmlTagRegex = RegExp(r'<[^>]*>');

  // Strips VTT metadata, timestamps, and HTML tags to produce plain transcript text.
  String _cleanVtt(String vttContent) {
    final buffer = StringBuffer();
    for (var line in vttContent.split('\n')) {
      line = line.trim();
      if (line.isEmpty ||
          line.startsWith('WEBVTT') ||
          line.startsWith('Kind:') ||
          line.startsWith('Language:') ||
          _vttTimestampRegex.hasMatch(line) ||
          int.tryParse(line) != null) {
        continue;
      }
      final text = line
          .replaceAll(_htmlTagRegex, '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"');
      if (text.isNotEmpty) buffer.write("$text ");
    }
    return buffer.toString().trim();
  }

  // Retrieves playlist metadata via yt-dlp.
  Future<Map<String, dynamic>> getPlaylistMetadata(String url) async {
    final execPath = await _binaryManager.getYtDlpPath();

    final args = [
      '--dump-json',
      '--flat-playlist',
      '--force-ipv4',
      '--no-warnings',
      '--geo-bypass',
      '--ignore-config',
      '--user-agent',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
      url,
    ];

    try {
      final result = await Process.run(execPath, args)
          .timeout(const Duration(seconds: 60));

      if (result.exitCode != 0) {
        throw Exception('yt-dlp error: ${result.stderr}');
      }

      final lines = const LineSplitter().convert(result.stdout.toString().trim());
      if (lines.isEmpty) throw Exception('Empty output from yt-dlp');

      Map<String, dynamic>? playlistInfo;
      final videos = <Map<String, dynamic>>[];

      for (int i = 0; i < lines.length; i++) {
        try {
          final item = jsonDecode(lines[i]);
          if (item['_type'] == 'playlist') {
            playlistInfo = item;
          } else if (item['_type'] == 'url' ||
              item['_type'] == 'url_transparent') {
            videos.add(item);
          }
        } catch (e) {
          debugPrint('Error parsing playlist item $i: $e');
        }
      }

      playlistInfo ??= jsonDecode(lines.first);

      String? thumbnail = playlistInfo?['thumbnail'] as String?;
      if (thumbnail == null && playlistInfo?['thumbnails'] is List) {
        final thumbs = playlistInfo?['thumbnails'] as List;
        if (thumbs.isNotEmpty && thumbs.last is Map) {
          thumbnail = thumbs.last['url'] as String?;
        }
      }
      thumbnail ??=
          videos.isNotEmpty ? videos.first['thumbnail'] as String? : null;

      return {
        'title': playlistInfo?['playlist_title'] ??
            playlistInfo?['title'] ??
            'Playlist',
        'uploader': playlistInfo?['playlist_uploader'] ??
            playlistInfo?['uploader'] ??
            playlistInfo?['channel'] ??
            playlistInfo?['uploader_id'] ??
            'Unknown',
        'thumbnail': thumbnail,
        'videoCount': videos.length,
        'videos': videos,
        'playlistId': playlistInfo?['playlist_id'] ?? playlistInfo?['id'],
      };
    } catch (e) {
      debugPrint("Playlist metadata error: $e");
      rethrow;
    }
  }

  // Starts a playlist download via yt-dlp.
  Future<Process> startPlaylistDownload(
    String url,
    String downloadPath, {
    DownloadFormat format = DownloadFormat.mp4,
    DownloadQuality quality = DownloadQuality.best,
    String? tempPath,
  }) async {
    final ytDlpPath = await _binaryManager.getYtDlpPath();
    final ffmpegPath = await _binaryManager.getFfmpegPath();
    final binDir = await _binaryManager.getBinariesPath();

    final env = Map<String, String>.from(Platform.environment);
    final sep = Platform.isWindows ? ';' : ':';
    env['PATH'] = '$binDir$sep${env['PATH'] ?? ""}';

    final args = [
      '--newline',
      '--ffmpeg-location',
      ffmpegPath,
      '--concurrent-fragments',
      '8',
      '--downloader',
      'aria2c',
      '--downloader-args',
      'aria2c:-x 16 -s 16 -k 1M --lowest-speed-limit=100K --file-allocation=falloc --optimize-concurrent-downloads=true',
      '--yes-playlist',
    ];

    const outputTemplate = '%(playlist_index)s - %(title)s.%(ext)s';

    if (tempPath != null) {
      args.addAll(['-P', 'temp:$tempPath', '-P', downloadPath, '-o', outputTemplate]);
    } else {
      args.addAll(['-o', '$downloadPath/$outputTemplate']);
    }

    _addFormatArgs(args, format, quality);
    args.add(url);
    return Process.start(ytDlpPath, args, environment: env);
  }

  static final _progressRegex = RegExp(
    r'\[download\]\s+(\d+\.?\d*)%\s+of\s+([^\s]+)\s+at\s+([^\s]+)\s+ETA\s+([^\s]+)',
  );
  static final _simpleProgressRegex = RegExp(r'\[download\]\s+(\d+\.?\d*)%');

  // Parses a yt-dlp output line to extract progress information.
  Map<String, dynamic>? parseProgress(String line) {
    final match = _progressRegex.firstMatch(line);
    if (match != null) {
      return {
        'progress': double.tryParse(match.group(1)!),
        'totalSize': match.group(2),
        'speed': match.group(3),
        'eta': match.group(4),
      };
    }

    final simple = _simpleProgressRegex.firstMatch(line);
    if (simple != null) {
      return {'progress': double.tryParse(simple.group(1)!)};
    }
    return null;
  }
}
