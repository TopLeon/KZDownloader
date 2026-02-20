import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/core/services/download_service.dart';
import 'package:kzdownloader/core/download/logic/speed_tracker.dart';

// Sequential HTTP chunk downloader with write buffering and resume support.
// Uses rhttp (Rust-based) via downloadChunkStream for high throughput.
class ChunkDownloader {
  bool _isPaused = false;

  void pause() {
    _isPaused = true;
  }

  // Downloads [url] to [savePath], resuming if the server supports range requests.
  Future<void> download(
    String url,
    String savePath, {
    Map<String, String>? headers,
    Function(double progress, double speed, int downloaded)? onProgress,
    int chunkSize = 100 * 1024 * 1024,
    int? knownFileSize,
    bool? knownAcceptRanges,
  }) async {
    _isPaused = false;

    final totalSize = knownFileSize ?? 0;
    final acceptRanges = knownAcceptRanges ?? false;
    final file = File(savePath);

    int received = 0;
    RandomAccessFile raf;

    if (await file.exists() && acceptRanges && totalSize > 0) {
      final existingSize = await file.length();
      if (existingSize < totalSize) {
        received = existingSize;
        raf = await file.open(mode: FileMode.append);
        await raf.setPosition(received);
        debugPrint("Resuming download from byte $received of $totalSize");
      } else {
        await file.delete();
        raf = await file.open(mode: FileMode.write);
      }
    } else {
      if (await file.exists()) await file.delete();
      raf = await file.open(mode: FileMode.write);
    }

    final speed = SpeedTracker();
    speed.start(initialBytes: received);

    final writeBuffer = BytesBuilder(copy: false);
    const int flushThreshold = 8 * 1024 * 1024;
    int chunkCounter = 0;

    Future<void> flush() async {
      if (writeBuffer.length > 0) {
        await raf.writeFrom(writeBuffer.takeBytes());
      }
    }

    void reportSpeed() {
      final displaySpeed = speed.update(received);
      onProgress?.call(
        totalSize > 0 ? received / totalSize : 0.0,
        displaySpeed,
        received,
      );
    }

    try {
      if (acceptRanges && totalSize > 0) {
        int start = received;
        const int maxRetries = 5;

        while (start < totalSize) {
          if (_isPaused) throw Exception('Download paused by user');

          final end = min(start + chunkSize - 1, totalSize - 1);
          int retryCount = 0;
          bool chunkDone = false;

          while (!chunkDone && retryCount < maxRetries) {
            if (_isPaused) throw Exception('Download paused by user');
            try {
              final stream =
                  downloadChunkStream(url, start, end, headers ?? {});

              if (retryCount > 0 || start != received) {
                await raf.setPosition(start);
              }

              await for (final chunk in stream) {
                if (_isPaused) throw Exception('Download paused by user');
                writeBuffer.add(chunk);
                received += chunk.length;

                chunkCounter++;
                if (chunkCounter >= 128) {
                  chunkCounter = 0;
                  reportSpeed();
                }
                if (writeBuffer.length >= flushThreshold) await flush();
              }

              await flush();
              reportSpeed();
              chunkDone = true;
            } catch (e) {
              retryCount++;
              if (!_isPausedOrCancelled(e)) {
                debugPrint(
                    "Error chunk $start-$end (attempt $retryCount): $e");
              }
              if (retryCount >= maxRetries) rethrow;
              await Future.delayed(Duration(seconds: retryCount * 2));
            }
          }
          start = end + 1;
        }
      } else {
        await raf.truncate(0);
        await raf.setPosition(0);
        received = 0;

        final stream = downloadChunkStream(url, 0, -1, headers ?? {});
        await for (final chunk in stream) {
          if (_isPaused) throw Exception('Download paused by user');
          writeBuffer.add(chunk);
          received += chunk.length;

          chunkCounter++;
          if (chunkCounter >= 128) {
            chunkCounter = 0;
            reportSpeed();
          }
          if (writeBuffer.length >= flushThreshold) await flush();
        }
        await flush();
      }
    } catch (e) {
      await flush();
      if (!_isPausedOrCancelled(e)) debugPrint("Critical Error: $e");
      rethrow;
    } finally {
      await raf.close();
    }
  }

  static bool _isPausedOrCancelled(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('paused') || msg.contains('cancel');
  }
}
