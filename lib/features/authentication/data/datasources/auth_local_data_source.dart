import 'dart:convert';

import 'package:beatsync_app/core/auth/auth_token_provider.dart';
import 'package:beatsync_app/core/errors/exceptions.dart';
import 'package:beatsync_app/features/authentication/data/models/login_response_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<LoginResponseDTO?> getLastLoginResponse();
  Future<void> cacheLoginResponse(LoginResponseDTO responseToCache);
  Future<void> clearCachedLoginResponse();
}

const String cachedLoginResponseKey = 'CACHED_LOGIN_RESPONSE';

class SecureStorageAuthLocalDataSource implements AuthLocalDataSource, AuthTokenProvider {
  final FlutterSecureStorage secureStorage;

  SecureStorageAuthLocalDataSource({required this.secureStorage});


  @override
  Future<void> cacheLoginResponse(LoginResponseDTO responseToCache) async {
    try {
      await secureStorage.write(
        key: cachedLoginResponseKey,
        value: jsonEncode(responseToCache.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache login response: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponseDTO?> getLastLoginResponse() async {
    try {
      final jsonString = await secureStorage.read(key: cachedLoginResponseKey);
      if (jsonString != null) {
        final response =
            LoginResponseDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
        return response;
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to retrieve login response: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedLoginResponse() async {
    try {
      await secureStorage.delete(key: cachedLoginResponseKey);
    } catch (e) {
      throw CacheException('Failed to clear login response: ${e.toString()}');
    }
  }


  @override
  Future<String?> getToken() async {
    final response = await getLastLoginResponse();
    if (response != null) {
      try {
        final expiryDate = DateTime.parse(response.expiresAt);
        if (expiryDate.isAfter(DateTime.now())) {
          return response.token;
        }
      } catch (e) {
        print("Error parsing expiry date from cached login response: $e");
      }
    }
    return null;
  }

  @override
  Future<void> clearToken() async {
    await clearCachedLoginResponse();
  }

  @override
  Future<void> saveToken(String token, String expiresAt) {

    throw UnimplementedError();
  }
}
