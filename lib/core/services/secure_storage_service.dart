import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Keys for secure storage entries.
class StorageKeys {
  static const String openAiApiKey = 'openai_api_key';
  static const String googleApiKey = 'google_api_key';
  static const String anthropicApiKey = 'anthropic_api_key';
}

// Service for securely reading and writing sensitive data.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  // Writes a key-value pair to secure storage.
  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Reads a value from secure storage by key.
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Deletes a value from secure storage by key.
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiKeyProvider = FutureProvider.family<String?, String>((ref, key) async {
  final storageService = ref.watch(secureStorageServiceProvider);
  return await storageService.readSecureData(key);
});
