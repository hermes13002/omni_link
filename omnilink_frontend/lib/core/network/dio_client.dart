import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
        // baseUrl: 'http://127.0.0.1:8000', // localhost
        baseUrl: 'https://omnilink-backend.onrender.com',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(storage, dio),
      EnvelopeInterceptor(),
      OmniLogInterceptor(),
    ]);

    return dio;
  }
}

class OmniLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('=== Request ===');
    debugPrint('url: ${options.uri}');
    if (options.data != null) {
      print('request data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('=== Response ===');
    debugPrint('url: ${response.requestOptions.uri}');
    if (response.data is ResponseBody) {
      debugPrint('response stream: [Streaming Data]');
    } else {
      debugPrint('response data: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('=== Error ===');
    debugPrint('url: ${err.requestOptions.uri}');
    debugPrint('error message: ${err.message}');
    if (err.response != null && err.response!.data != null) {
      debugPrint('error data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
