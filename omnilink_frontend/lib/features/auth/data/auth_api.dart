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

  Future<UserModel> getMe() async {
    final response = await _dio.get('/api/v1/auth/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post('/api/v1/auth/logout', data: {
      'refresh_token': refreshToken,
    });
  }
}
