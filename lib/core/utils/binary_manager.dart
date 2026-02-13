import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';

// Manages external binaries required by the application (yt-dlp, ffmpeg, deno, etc.).
class BinaryManager {
  static final BinaryManager _instance = BinaryManager._internal();
  factory BinaryManager() => _instance;
  BinaryManager._internal();

  final Dio _dio = Dio();

  // returns the directory where binaries are stored.
  Future<String> getBinariesPath() async {
    final dir = await getApplicationSupportDirectory();
    final binDir = Directory(p.join(dir.path, 'bin'));
    if (!await binDir.exists()) {
      await binDir.create(recursive: true);
    }
    return binDir.path;
  }

  // returns the path to the yt-dlp executable.
  Future<String> getYtDlpPath() async {
    final binDir = await getBinariesPath();
    String fileName = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';
    return p.join(binDir, fileName);
  }

  // returns the path to the ffmpeg executable.
  Future<String> getFfmpegPath() async {
    final binDir = await getBinariesPath();
    String fileName = Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';
    return p.join(binDir, fileName);
  }

  // returns the path to the deno executable.
  Future<String> getDenoPath() async {
    final binDir = await getBinariesPath();
    String fileName = Platform.isWindows ? 'deno.exe' : 'deno';
    return p.join(binDir, fileName);
  }

  // returns the path to the AI model file.
  Future<String> getModelPath() async {
    final dir = await getApplicationSupportDirectory();
    final modelDir = Directory(p.join(dir.path, 'models'));
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return p.join(modelDir.path, 'gemma-3-4b-it-qat-int4-q4_k_m.gguf');
  }

  // Checks if yt-dlp is installed.
  Future<bool> isYtDlpInstalled() async {
    return File(await getYtDlpPath()).exists();
  }

  // Checks if ffmpeg is installed.
  Future<bool> isFfmpegInstalled() async {
    return File(await getFfmpegPath()).exists();
  }

  // Checks if deno is installed.
  Future<bool> isDenoInstalled() async {
    return File(await getDenoPath()).exists();
  }

  // Checks if the AI model is downloaded.
  Future<bool> isModelDownloaded() async {
    final path = await getModelPath();
    return File(path).existsSync() && await File(path).length() > 0;
  }

  // Ensures all required binaries are installed.
  Future<void> ensureInitialized() async {
    if (!await isYtDlpInstalled()) await downloadYtDlp();
    if (!await isFfmpegInstalled()) await downloadFfmpeg();
    if (!await isDenoInstalled()) await downloadDeno();
  }

  // Downloads the yt-dlp binary.
  Future<void> downloadYtDlp({Function(double)? onProgress}) async {
    final path = await getYtDlpPath();
    String url;
    if (Platform.isWindows) {
      url =
          'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe';
    } else if (Platform.isMacOS) {
      url =
          'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos';
    } else {
      url = 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp';
    }
    await _dio.download(
      url,
      path,
      onReceiveProgress: (received, total) {
        if (total != -1 && onProgress != null) onProgress(received / total);
      },
    );
    if (!Platform.isWindows) await _setExecutablePermission(path);
  }

  // Downloads and extracts the Deno binary.
  Future<void> downloadDeno({Function(double)? onProgress}) async {
    final binDir = await getBinariesPath();
    final archivePath = p.join(binDir, 'deno.zip');
    String url;

    if (Platform.isWindows) {
      url =
          'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip';
    } else if (Platform.isMacOS) {
      final result = await Process.run('uname', ['-m']);
      final arch = result.stdout.toString().trim();
      if (arch == 'arm64') {
        url =
            'https://github.com/denoland/deno/releases/latest/download/deno-aarch64-apple-darwin.zip';
      } else {
        url =
            'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-apple-darwin.zip';
      }
    } else {
      url =
          'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip';
    }

    await _dio.download(
      url,
      archivePath,
      onReceiveProgress: (received, total) {
        if (total != -1 && onProgress != null) onProgress(received / total);
      },
    );

    final bytes = File(archivePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(binDir, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }

    File(archivePath).deleteSync();

    if (!Platform.isWindows) {
      await _setExecutablePermission(await getDenoPath());
    }
  }

  // Downloads and extracts the FFmpeg binary.
  Future<void> downloadFfmpeg({Function(double)? onProgress}) async {
    final binDir = await getBinariesPath();
    String url;
    String archiveName;

    if (Platform.isWindows) {
      url = 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip';
      archiveName = 'ffmpeg.zip';
    } else if (Platform.isMacOS) {
      url = 'https://evermeet.cx/ffmpeg/ffmpeg-6.0.zip';
      archiveName = 'ffmpeg.zip';
    } else {
      return;
    }

    final archivePath = p.join(binDir, archiveName);
    await _dio.download(
      url,
      archivePath,
      onReceiveProgress: (received, total) {
        if (total != -1 && onProgress != null) onProgress(received / total);
      },
    );

    final bytes = File(archivePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.isFile) {
        final filename = file.name;
        if (filename.endsWith('ffmpeg.exe') || filename.endsWith('ffmpeg')) {
          final data = file.content as List<int>;
          final ffmpegPath = await getFfmpegPath();
          File(ffmpegPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
          if (!Platform.isWindows) await _setExecutablePermission(ffmpegPath);
          break;
        }
      }
    }
    try {
      File(archivePath).deleteSync();
    } catch (_) {}
  }

  Future<void> _setExecutablePermission(String path) async {
    await Process.run('chmod', ['+x', path]);
    try {
      await Process.run('xattr', ['-d', 'com.apple.quarantine', path]);
    } catch (e) {}
  }

  // Checks if the model is downloaded and downloads it if missing.
  Future<void> checkAndDownloadModel({Function(double)? onProgress}) async {
    if (await isModelDownloaded()) return;

    final path = await getModelPath();

    const url =
        'https://huggingface.co/unsloth/gemma-3-4b-it-qat-int4-GGUF/resolve/main/gemma-3-4b-it-qat-int4-Q4_K_M.gguf?download=true';

    try {
      await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      if (await File(path).length() < 1024) {
        throw Exception("File modello scaricato corrotto o troppo piccolo.");
      }
    } catch (e) {
      final file = File(path);
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }
}
