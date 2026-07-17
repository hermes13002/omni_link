import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../auth_api.dart';
import '../models/user_model.dart';

@lazySingleton
class AuthRepository {
  final AuthApi _api;
  final FlutterSecureStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<UserModel> login(String email, String password) async {
    final tokenResponse = await _api.login(email, password);
    await _storage.write(key: 'access_token', value: tokenResponse.accessToken);
    await _storage.write(key: 'refresh_token', value: tokenResponse.refreshToken);
    return await _api.getMe();
  }

  Future<UserModel> register(String email, String password, String displayName) async {
    final tokenResponse = await _api.register(email, password, displayName);
    await _storage.write(key: 'access_token', value: tokenResponse.accessToken);
    await _storage.write(key: 'refresh_token', value: tokenResponse.refreshToken);
    return await _api.getMe();
  }

  Future<UserModel?> checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        return await _api.getMe();
      } catch (e) {
        // Token might be invalid/expired, AuthInterceptor will try to refresh.
        // If refresh fails, it clears tokens and throws here.
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'device_secret');
  }
}
