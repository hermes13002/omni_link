import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Dio dio(FlutterSecureStorage storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000', // Changed to localhost for Windows desktop
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(storage, dio),
      EnvelopeInterceptor(),
      LogInterceptor(responseBody: true, requestBody: true),
    ]);

    return dio;
  }
}
