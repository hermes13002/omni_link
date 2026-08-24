import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<UserModel> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: '45215730119-qtcuih2b8bp9lmhne4ar4085n26jo6kr.apps.googleusercontent.com',
      serverClientId: '45215730119-qtcuih2b8bp9lmhne4ar4085n26jo6kr.apps.googleusercontent.com',
      scopes: ['email', 'profile', 'openid'],
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In aborted');
    }
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;
    
    if (idToken == null && accessToken == null) {
      throw Exception('Failed to obtain any auth token from Google');
    }

    final tokenResponse = await _api.googleLogin(idToken, accessToken);
    await _storage.write(key: 'access_token', value: tokenResponse.accessToken);
    await _storage.write(key: 'refresh_token', value: tokenResponse.refreshToken);
    return await _api.getMe();
  }

  Future<UserModel> adminLogin(String email, String password, String secretKey) async {
    final tokenResponse = await _api.adminLogin(email, password, secretKey);
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
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        await _api.logout(refreshToken);
      } else {
        await _api.logout("");
      }
    } catch (_) {
      // Ignore errors if token is already invalid or network is down
    }
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'device_secret');
  }

  Future<UserModel> updateDisplayName(String displayName) async {
    return await _api.updateDisplayName(displayName);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _api.changePassword(oldPassword, newPassword);
  }

  Future<void> deleteAccount() async {
    await _api.deleteAccount();
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'device_secret');
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: 'has_seen_onboarding');
    return value == 'true';
  }

  Future<void> completeOnboarding() async {
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
  }
}
