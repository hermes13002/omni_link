import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'models/admin_overview_metrics.dart';
import 'models/admin_user_item.dart';

@injectable
class AdminApi {
  final ApiClient _apiClient;

  AdminApi({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<AdminOverviewMetrics> getOverviewMetrics() async {
    final response = await _apiClient.dio.get('/admin/metrics/overview');
    return AdminOverviewMetrics.fromJson(response.data['data']);
  }

  Future<List<AdminUserItem>> getAllUsers() async {
    final response = await _apiClient.dio.get('/admin/users');
    final List<dynamic> usersJson = response.data['data']['users'];
    return usersJson.map((json) => AdminUserItem.fromJson(json)).toList();
  }

  Future<void> toggleUserSuspension(String userId, bool suspend) async {
    await _apiClient.dio.patch(
      '/admin/users/$userId/suspend',
      queryParameters: {'is_suspended': suspend},
    );
  }
}
