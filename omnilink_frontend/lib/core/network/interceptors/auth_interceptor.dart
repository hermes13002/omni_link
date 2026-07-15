import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final response = await _dio.post('/api/v1/auth/refresh', data: {
            'refresh_token': refreshToken,
          });
          
          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];
            
            await _storage.write(key: 'access_token', value: newAccessToken);
            await _storage.write(key: 'refresh_token', value: newRefreshToken);
            
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await _dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'refresh_token');
        }
      }
    }
    handler.next(err);
  }
}
