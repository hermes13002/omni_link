import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'models/admin_overview_metrics.dart';
import 'models/admin_user_item.dart';
import 'models/admin_audit_log_item.dart';

@injectable
class AdminApi {
  final Dio _dio;

  AdminApi(this._dio);

  Future<AdminOverviewMetrics> getOverviewMetrics() async {
    final response = await _dio.get('/api/v1/admin/metrics/overview');
    return AdminOverviewMetrics.fromJson(response.data);
  }

  Future<List<AdminUserItem>> getAllUsers() async {
    final response = await _dio.get('/api/v1/admin/users');
    final List<dynamic> usersJson = response.data['users'];
    return usersJson.map((json) => AdminUserItem.fromJson(json)).toList();
  }

  Future<void> toggleUserSuspension(String userId, bool suspend) async {
    await _dio.patch(
      '/api/v1/admin/users/$userId/suspend',
      queryParameters: {'is_suspended': suspend},
    );
  }

  Future<List<AdminAuditLogItem>> getAuditLogs() async {
    final response = await _dio.get('/api/v1/admin/audit-logs');
    final List<dynamic> logsJson = response.data['logs'];
    return logsJson.map((json) => AdminAuditLogItem.fromJson(json)).toList();
  }
}
