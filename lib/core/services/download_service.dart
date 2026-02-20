import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:rhttp_plus/rhttp_plus.dart';

Future<Map<String, String>> getHeadInfo(String url, Map<String, String> headers) async {
  // Clean headers (skip 'host' like in the Rust code)
  final cleanedHeaders = Map<String, String>.from(headers)..removeWhere((k, _) => k.toLowerCase() == 'host');

  // Configure with Chrome emulation
  const settings = ClientSettings(emulator: Emulation.chrome136, redirectSettings: RedirectSettings.limited(10));

  // Try HEAD request
  HttpResponse response;
  try {
    response = await Rhttp.head(
      url, 
      headers: HttpHeaders.rawMap(cleanedHeaders), 
      settings: settings,
    );
  } catch (e) {
    throw Exception('HEAD request failed: $e');
  }

  // Fallback to GET if HEAD fails
  final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
  if (!isSuccess) {
    try {
      response = await Rhttp.get(
        url, 
        headers: HttpHeaders.rawMap(cleanedHeaders), 
        settings: settings,
      );
      final isGetSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (!isGetSuccess) {
        throw Exception('Fallback GET failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('GET fallback failed: $e');
    }
  }

  // Extract headers (lowercase keys like in Rust)
  final resultHeaders = <String, String>{};
  for (final header in response.headers) {
    resultHeaders[header.$1.toLowerCase()] = header.$2;
  }

  debugPrint(resultHeaders.toString());

  return resultHeaders;
}

// Stream-based variant that returns a Stream<Uint8List> for compatibility with existing code
Stream<Uint8List> downloadChunkStream(
  String url,
  int start,
  int end,
  Map<String, String> headers,
) async* {
  if (start > end && end != -1) {
    throw Exception('Invalid range: start > end');
  }

  // Clean headers (skip 'host')
  final cleanedHeaders = Map<String, String>.from(headers)..removeWhere((k, _) => k.toLowerCase() == 'host');

  // Add Range header for partial download if needed
  if (start > 0 || end != -1) {
    if (end == -1) {
      cleanedHeaders['range'] = 'bytes=$start-';
    } else {
      cleanedHeaders['range'] = 'bytes=$start-$end';
    }
  }

  // Configure with Chrome emulation and redirect following
  const settings = ClientSettings(
    emulator: Emulation.chrome136,
    redirectSettings: RedirectSettings.limited(10),
  );

  // Get streaming response
  final streamResponse = await Rhttp.getStream(
    url, 
    headers: HttpHeaders.rawMap(cleanedHeaders), 
    settings: settings,
  );

  final isSuccess = streamResponse.statusCode >= 200 && streamResponse.statusCode < 300;
  if (!isSuccess && streamResponse.statusCode != 206) {  // 206 = Partial Content
    throw Exception('Server refused connection: ${streamResponse.statusCode}');
  }

  // Stream chunks
  await for (final chunk in streamResponse.body) {
    yield Uint8List.fromList(chunk);
  }
}

// Original sink-based variant
Future<void> downloadChunk(
  StreamSink<List<int>> streamSink,
  String url,
  int start,
  int end,
  Map<String, String> headers,
) async {
  if (start > end) {
    throw Exception('Invalid range: start > end');
  }

  // Clean headers (skip 'host')
  final cleanedHeaders = Map<String, String>.from(headers)..removeWhere((k, _) => k.toLowerCase() == 'host');

  // Add Range header for partial download
  cleanedHeaders['range'] = 'bytes=$start-$end';

  // Configure with Chrome emulation and redirect following
  const settings = ClientSettings(
    emulator: Emulation.chrome136,
    redirectSettings: RedirectSettings.limited(10),
  );

  // Get streaming response
  final streamResponse = await Rhttp.getStream(
    url, 
    headers: HttpHeaders.rawMap(cleanedHeaders), 
    settings: settings,
  );

  final isSuccess = streamResponse.statusCode >= 200 && streamResponse.statusCode < 300;
  if (!isSuccess && streamResponse.statusCode != 206) {  // 206 = Partial Content
    throw Exception('Server refused connection: ${streamResponse.statusCode}');
  }

  // Stream chunks to the sink
  await for (final chunk in streamResponse.body) {
    streamSink.add(chunk);
  }
}
