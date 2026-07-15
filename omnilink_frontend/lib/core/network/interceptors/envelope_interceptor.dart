import 'package:dio/dio.dart';
import 'package:omnilink_frontend/core/network/exceptions.dart';

class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool?;
      final message = data['message'] as String?;
      final payload = data['data'];

      if (success == true) {
        response.data = payload;
        handler.next(response);
      } else {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: ApiException(message ?? 'Unknown error', statusCode: response.statusCode),
          ),
        );
      }
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Network error occurred';
    int? statusCode = err.response?.statusCode;

    if (err.response?.data is Map<String, dynamic>) {
      message = err.response?.data['message'] ?? message;
    } else if (err.error is ApiException) {
      message = (err.error as ApiException).message;
    } else if (err.message != null) {
      message = err.message!;
    }

    handler.next(
      err.copyWith(
        error: ApiException(message, statusCode: statusCode),
      ),
    );
  }
}
