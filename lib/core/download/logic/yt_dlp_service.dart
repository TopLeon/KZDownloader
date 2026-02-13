import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:kzdownloader/core/utils/binary_manager.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/download/logic/youtube_transcript_helper.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Service responsible for handling yt-dlp operations and metadata retrieval.
class YtDlpService {
  final BinaryManager _binaryManager = BinaryManager();
  final YoutubeExplode _yt = YoutubeExplode();

  // Retrieves metadata for a video URL using youtube_explode (fast for YouTube) or yt-dlp (for other sites).
  Future<Map<String, dynamic>> getMetadata(String url) async {
    // youtube_explode only supports YouTube, use yt-dlp for all other sites
    if (_isYouTubeUrl(url)) {
      try {
        return await _getMetadataWithYoutubeExplode(url);
      } catch (e) {
        debugPrint('youtube_explode failed, falling back to yt-dlp: $e');
        return await _getMetadataWithYtDlp(url);
      }
    } else {
      // For non-YouTube URLs, use yt-dlp directly
      return await _getMetadataWithYtDlp(url);
    }
  }

  // Checks if the URL is a YouTube URL.
  bool _isYouTubeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      return host.contains('youtube.com') ||
          host.contains('youtu.be') ||
          host.contains('youtube-nocookie.com');
    } catch (e) {
      return false;
    }
  }

  // Fast metadata extraction using youtube_explode_dart (native Dart, no external process).
  Future<Map<String, dynamic>> _getMetadataWithYoutubeExplode(
      String url) async {
    final video = await _yt.videos.get(url).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException(
            'youtube_explode did not respond within 15 seconds.');
      },
    );

    final streamManifest =
        await _yt.videos.streamsClient.getManifest(video.id.value);

    // Build formats list similar to yt-dlp structure
    final formats = <Map<String, dynamic>>[];

    // Video + Audio streams
    for (var stream in streamManifest.muxed) {
      formats.add({
        'format_id': stream.tag.toString(),
        'ext': stream.container.name,
        'quality': '${stream.videoQuality.name}',
        'filesize': stream.size.totalBytes,
        'tbr': stream.bitrate.bitsPerSecond / 1000,
        'vcodec': stream.videoCodec,
        'acodec': stream.audioCodec,
        'width': stream.videoResolution.width,
        'height': stream.videoResolution.height,
        'fps': stream.framerate.framesPerSecond,
      });
    }

    // Video-only streams
    for (var stream in streamManifest.video) {
      formats.add({
        'format_id': stream.tag.toString(),
        'ext': stream.container.name,
        'quality': '${stream.videoQuality.name}',
        'filesize': stream.size.totalBytes,
        'tbr': stream.bitrate.bitsPerSecond / 1000,
        'vcodec': stream.videoCodec,
        'acodec': 'none',
        'width': stream.videoResolution.width,
        'height': stream.videoResolution.height,
        'fps': stream.framerate.framesPerSecond,
      });
    }

    // Audio-only streams
    for (var stream in streamManifest.audio) {
      formats.add({
        'format_id': stream.tag.toString(),
        'ext': stream.container.name,
        'quality': 'audio only',
        'filesize': stream.size.totalBytes,
        'tbr': stream.bitrate.bitsPerSecond / 1000,
        'vcodec': 'none',
        'acodec': stream.audioCodec,
        'abr': stream.bitrate.bitsPerSecond / 1000,
      });
    }

    return {
      'id': video.id.value,
      'title': video.title,
      'description': video.description,
      'duration': video.duration?.inSeconds ?? 0,
      'thumbnail': video.thumbnails.highResUrl,
      'thumbnails': [
        {
          'url': video.thumbnails.lowResUrl,
          'id': 'low',
        },
        {
          'url': video.thumbnails.mediumResUrl,
          'id': 'medium',
        },
        {
          'url': video.thumbnails.highResUrl,
          'id': 'high',
        },
        {
          'url': video.thumbnails.maxResUrl,
          'id': 'maxres',
        },
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
      'upload_date': video.uploadDate != null
          ? video.uploadDate.toString().replaceAll('-', '').substring(0, 8)
          : null,
      'webpage_url': video.url,
      'formats': formats,
      'ext': streamManifest.muxed.isNotEmpty
          ? streamManifest.muxed.bestQuality.container.name
          : 'mp4',
      '_fetched_with': 'youtube_explode_dart',
    };
  }

  // Fallback: Retrieves metadata using yt-dlp (slower, external process).
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
        onTimeout: () {
          throw TimeoutException('yt-dlp did not respond within 30 seconds.');
        },
      );

      if (result.exitCode != 0) {
        final error = result.stderr.toString();
        if (error.contains('Unsupported URL')) {
          throw Exception('Unsupported URL or video unavailable.');
        }
        throw Exception('yt-dlp error (Exit ${result.exitCode}): $error');
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) {
        throw Exception('yt-dlp returned empty output.');
      }

      try {
        final metadata = jsonDecode(output);
        metadata['_fetched_with'] = 'yt-dlp';
        return metadata;
      } catch (e) {
        final lines = const LineSplitter().convert(output);
        for (var line in lines) {
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

  // Cleanup method for YoutubeExplode client
  void dispose() {
    _yt.close();
  }

  // Starts the download process using yt-dlp binary.
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
    final separator = Platform.isWindows ? ';' : ':';
    env['PATH'] = '$binDir$separator${env['PATH'] ?? ""}';

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
      args.addAll([
        '-P',
        'temp:$tempPath',
        '-P',
        downloadPath,
        '-o',
        outputTemplate,
      ]);
    } else {
      args.addAll(['-o', '$downloadPath/$outputTemplate']);
    }

    _addFormatArgs(args, format, quality);
    args.add(url);

    return Process.start(ytDlpPath, args, environment: env);
  }

  // Adds format-specific arguments to the download command.
  void _addFormatArgs(
      List<String> args, DownloadFormat format, DownloadQuality quality) {
    if (format == DownloadFormat.mp3) {
      args.addAll(['-x', '--audio-format', 'mp3']);
    } else if (format == DownloadFormat.m4a) {
      args.addAll(['-x', '--audio-format', 'm4a']);
    } else {
      final heightConstraint = _getHeightConstraint(quality);

      if (format == DownloadFormat.mp4) {
        if (heightConstraint.isNotEmpty) {
          args.addAll([
            '-f',
            'bv*$heightConstraint[ext=mp4]+ba[ext=m4a]/b$heightConstraint[ext=mp4] / bv*$heightConstraint+ba/b$heightConstraint',
          ]);
        } else {
          args.addAll(['-f', 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b']);
        }
        args.addAll(['--merge-output-format', 'mp4']);
      } else if (format == DownloadFormat.mkv) {
        if (heightConstraint.isNotEmpty) {
          args.addAll(['-f', 'bv*$heightConstraint+ba/b$heightConstraint']);
        }
        args.addAll(['--merge-output-format', 'mkv']);
      }
    }
  }

  // Returns height constraint string based on quality.
  String _getHeightConstraint(DownloadQuality quality) {
    switch (quality) {
      case DownloadQuality.best:
        return '';
      case DownloadQuality.medium:
        return '[height<=720]';
      case DownloadQuality.low:
        return '[height<=480]';
      case DownloadQuality.p1080:
        return '[height<=1080]';
      case DownloadQuality.p720:
        return '[height<=720]';
      case DownloadQuality.p480:
        return '[height<=480]';
    }
  }

  // Fetches subtitles for a video, falling back to description if needed.
  Future<String?> fetchVideoSubtitles(String url,
      {String langCode = 'en'}) async {
    final ytDlpTranscript = await _fetchSubtitlesWithYtDlp(url, langCode);
    if (ytDlpTranscript != null) {
      return ytDlpTranscript;
    }

    try {
      final helper = YouTubeTranscriptFetcher();
      final xml = await helper.fetchCaptions(url, languageCode: langCode);
      final captions = CaptionParser.parseXml(xml);
      final fullTranscript = captions.map((c) => c.text).join(' ');

      if (fullTranscript.trim().isEmpty) {
        throw Exception("Empty subtitles");
      }
      return fullTranscript;
    } catch (e) {
      debugPrint("Fallback subtitles fetch failed: $e");
      return null;
    }
  }

  // Fetches subtitles using yt-dlp.
  Future<String?> _fetchSubtitlesWithYtDlp(String url, String langCode) async {
    Directory? tempDir;
    try {
      final ytDlpPath = await _binaryManager.getYtDlpPath();
      tempDir = Directory.systemTemp.createTempSync('yt_subs_');
      final fileName = 'subs_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '${tempDir.path}/$fileName';

      final args = [
        '--skip-download',
        '--write-sub',
        '--write-auto-sub',
        '--sub-lang',
        '$langCode,$langCode-orig,en,en-orig',
        '--convert-subs',
        'vtt',
        '--force-ipv4',
        '--geo-bypass',
        '--ignore-config',
        '--user-agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        '-o',
        filePath,
        url
      ];

      final result = await Process.run(ytDlpPath, args);
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

      if (subFile != null) {
        final content = await subFile.readAsString();
        return _cleanVttAttributes(content);
      }

      if (result.exitCode != 0) {
        debugPrint("yt-dlp subs failed: ${result.stderr}");
      }

      return null;
    } catch (e) {
      debugPrint("yt-dlp fallback error: $e");
      return null;
    } finally {
      if (tempDir != null && tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  }

  // Pre-compiled regexes for VTT cleaning (avoids recompilation per call).
  static final _vttTimestampRegex =
      RegExp(r'(\d{2}:)?\d{2}:\d{2}\.\d{3}\s-->\s(\d{2}:)?\d{2}:\d{2}\.\d{3}');
  static final _htmlTagRegex = RegExp(r'<[^>]*>');

  // Cleans VTT subtitle format, removing metadata and tags.
  String _cleanVttAttributes(String vttContent) {
    final lines = vttContent.split('\n');
    final buffer = StringBuffer();

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty ||
          line.startsWith('WEBVTT') ||
          line.startsWith('Kind:') ||
          line.startsWith('Language:') ||
          _vttTimestampRegex.hasMatch(line) ||
          int.tryParse(line) != null) {
        continue;
      }

      var text = line
          .replaceAll(_htmlTagRegex, '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"');

      if (text.isNotEmpty) {
        buffer.write("$text ");
      }
    }
    return buffer.toString().trim();
  }

  // Retrieves metadata for a YouTube playlist.
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

      final output = result.stdout.toString().trim();
      final lines = const LineSplitter().convert(output);

      if (lines.isEmpty) {
        throw Exception('Empty output from yt-dlp');
      }

      final playlistInfo = jsonDecode(lines.first);
      final videos = <Map<String, dynamic>>[];

      for (int i = 0; i < lines.length; i++) {
        try {
          final item = jsonDecode(lines[i]);
          if (item['_type'] == 'url' || item['_type'] == 'url_transparent') {
            videos.add(item);
          }
        } catch (e) {
          debugPrint('Error parsing video $i: $e');
        }
      }

      return {
        'title': playlistInfo['title'] ??
            playlistInfo['playlist_title'] ??
            'Playlist',
        'uploader': playlistInfo['uploader'] ??
            playlistInfo['channel'] ??
            playlistInfo['uploader_id'] ??
            'Unknown',
        'thumbnail': playlistInfo['thumbnail'] ??
            (videos.isNotEmpty ? videos.first['thumbnail'] : null),
        'videoCount': videos.length,
        'videos': videos,
        'playlistId': playlistInfo['id'] ?? playlistInfo['playlist_id'],
      };
    } catch (e) {
      debugPrint("Playlist metadata error: $e");
      rethrow;
    }
  }

  // Downloads a YouTube playlist.
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
    final separator = Platform.isWindows ? ';' : ':';
    env['PATH'] = '$binDir$separator${env['PATH'] ?? ""}';

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
      args.addAll([
        '-P',
        'temp:$tempPath',
        '-P',
        downloadPath,
        '-o',
        outputTemplate,
      ]);
    } else {
      args.addAll(['-o', '$downloadPath/$outputTemplate']);
    }

    _addFormatArgs(args, format, quality);
    args.add(url);

    return Process.start(ytDlpPath, args, environment: env);
  }

  // Pre-compiled regex patterns for progress parsing (avoids recompilation per call).
  static final _progressRegex = RegExp(
    r'\[download\]\s+(\d+\.?\d*)%\s+of\s+([^\s]+)\s+at\s+([^\s]+)\s+ETA\s+([^\s]+)',
  );
  static final _simpleProgressRegex = RegExp(r'\[download\]\s+(\d+\.?\d*)%');

  // Parses yt-dlp output line to extract progress information.
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

    final simpleMatch = _simpleProgressRegex.firstMatch(line);
    if (simpleMatch != null) {
      return {'progress': double.tryParse(simpleMatch.group(1)!)};
    }

    return null;
  }
}
