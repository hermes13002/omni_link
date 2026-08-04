import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:omnilink_frontend/core/di/injection.dart';

import '../../globals.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
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
    // Prevent infinite loop if the refresh token request itself fails with 401
    if (err.requestOptions.path.contains('/auth/refresh')) {
      return handler.next(err);
    }

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
        } on DioException catch (e) {
          if (e.response != null && 
              (e.response!.statusCode == 401 || 
               e.response!.statusCode == 403 || 
               e.response!.statusCode == 400)) {
            await _storage.delete(key: 'access_token');
            await _storage.delete(key: 'refresh_token');
            _handleSessionExpired();
          }
        } catch (e) {
          // Ignore other exceptions and just let the original request fail
        }
      }
    }
    handler.next(err);
  }

  void _handleSessionExpired() {
    getIt<AuthBloc>().add(AuthLogoutRequested());
    
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
