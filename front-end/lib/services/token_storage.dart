import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Clés
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  // ===================== WRITE =====================
  static Future<void> writeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<void> writeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // ===================== READ =====================
  static Future<String?> readAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // ===================== DELETE =====================
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

