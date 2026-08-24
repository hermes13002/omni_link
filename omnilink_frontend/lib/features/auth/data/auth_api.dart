import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'models/token_response.dart';
import 'models/user_model.dart';

@lazySingleton
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<TokenResponse> register(String email, String password, String displayName) async {
    final response = await _dio.post('/api/v1/auth/register', data: {
      'email': email,
      'password': password,
      'display_name': displayName,
    });
    return TokenResponse.fromJson(response.data);
  }

    Future<TokenResponse> login(String email, String password) async {
      final response = await _dio.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      return TokenResponse.fromJson(response.data);
    }

    Future<TokenResponse> googleLogin(String? idToken, String? accessToken) async {
      final response = await _dio.post('/api/v1/auth/google', data: {
        'id_token': idToken,
        'access_token': accessToken,
      });
      return TokenResponse.fromJson(response.data);
    }

  Future<TokenResponse> adminLogin(String email, String password, String secretKey) async {
    final response = await _dio.post('/api/v1/admin/login', data: {
      'email': email,
      'password': password,
      'secret_key': secretKey,
    });
    return TokenResponse.fromJson(response.data);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/api/v1/auth/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post('/api/v1/auth/logout', data: {
      'refresh_token': refreshToken,
    });
  }

  Future<UserModel> updateDisplayName(String displayName) async {
    final response = await _dio.patch('/api/v1/auth/me', data: {
      'display_name': displayName,
    });
    return UserModel.fromJson(response.data);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.patch('/api/v1/auth/password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/api/v1/auth/me');
  }

  Future<void> securityAlert(String alertType, String message, String? deviceInfo) async {
    await _dio.post('/api/v1/auth/security-alert', data: {
      'alert_type': alertType,
      'message': message,
      'device_info': deviceInfo,
    });
  }
}
