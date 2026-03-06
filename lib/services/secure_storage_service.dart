// ── HIGH-01 FIX: Encrypted Storage Service ──────────────────────
// Wraps flutter_secure_storage for sensitive data at rest.
// Used for FCM tokens, preferences, and any sensitive local data.

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Keys ────────────────────────────────────────────────────────
  static const _keyFcmToken = 'fcm_token';
  static const _keyFcmTokenTimestamp = 'fcm_token_ts';

  // ── FCM Token ───────────────────────────────────────────────────

  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _keyFcmToken, value: token);
    await _storage.write(
      key: _keyFcmTokenTimestamp,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<String?> getFcmToken() async {
    return _storage.read(key: _keyFcmToken);
  }

  Future<DateTime?> getFcmTokenTimestamp() async {
    final ts = await _storage.read(key: _keyFcmTokenTimestamp);
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  // ── Generic ─────────────────────────────────────────────────────

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> wipeAll() async {
    await _storage.deleteAll();
    debugPrint('[SECURE_STORAGE] All data wiped');
  }
}
