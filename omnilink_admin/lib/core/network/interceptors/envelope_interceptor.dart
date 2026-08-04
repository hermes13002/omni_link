import 'package:dio/dio.dart';
import 'package:omnilink_admin/core/network/exceptions.dart';

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
    } else if (statusCode != null) {
      if (statusCode == 404) {
        message = 'Service not found (404). Please check your internet or URL.';
      } else if (statusCode == 429) {
        message = 'Too many requests. Please wait a minute and try again.';
      } else if (statusCode == 413) {
        message = 'File is too large. Maximum allowed size is 50MB.';
      } else if (statusCode >= 500) {
        message = 'Server error ($statusCode). Please try again later.';
      } else {
        message = 'Request failed ($statusCode)';
      }
    } else if (err.error is ApiException) {
      message = (err.error as ApiException).message;
    } else if (err.type == DioExceptionType.connectionTimeout || err.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your internet.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'Failed to connect to the server.';
    }

    handler.next(
      err.copyWith(
        error: ApiException(message, statusCode: statusCode),
      ),
    );
  }
}
