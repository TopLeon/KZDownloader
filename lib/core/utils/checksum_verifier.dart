import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Verifies file checksums using MD5 or SHA256.
class ChecksumVerifier {
  /// Auto-detect algorithm from hash length.
  /// MD5 = 32 hex chars, SHA256 = 64 hex chars.
  static String? detectAlgorithm(String hash) {
    final cleaned = hash.trim().toLowerCase();
    if (cleaned.length == 32 && RegExp(r'^[a-f0-9]+$').hasMatch(cleaned)) {
      return 'md5';
    } else if (cleaned.length == 64 &&
        RegExp(r'^[a-f0-9]+$').hasMatch(cleaned)) {
      return 'sha256';
    }
    return null;
  }

  /// Compute checksum of a file using the specified algorithm.
  /// Runs in a separate isolate to avoid blocking the UI.
  static Future<String> computeChecksum(
      String filePath, String algorithm) async {
    return compute(_computeChecksumSync,
        _ChecksumArgs(filePath, algorithm.trim().toLowerCase()));
  }

  /// Verify a file against an expected checksum.
  /// Returns 'match' or 'mismatch'.
  static Future<String> verify(
      String filePath, String expectedChecksum, String algorithm) async {
    final computed = await computeChecksum(filePath, algorithm);
    final expected = expectedChecksum.trim().toLowerCase();
    return computed == expected ? 'match' : 'mismatch';
  }

  static String _computeChecksumSync(_ChecksumArgs args) {
    final file = File(args.filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: ${args.filePath}');
    }

    final bytes = file.readAsBytesSync();

    switch (args.algorithm) {
      case 'md5':
        return md5.convert(bytes).toString();
      case 'sha256':
        return sha256.convert(bytes).toString();
      default:
        throw Exception('Unsupported algorithm: ${args.algorithm}');
    }
  }
}

class _ChecksumArgs {
  final String filePath;
  final String algorithm;
  _ChecksumArgs(this.filePath, this.algorithm);
}
