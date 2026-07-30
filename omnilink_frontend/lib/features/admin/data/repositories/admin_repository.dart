import 'package:injectable/injectable.dart';
import '../admin_api.dart';
import 'models/admin_overview_metrics.dart';
import 'models/admin_user_item.dart';

@injectable
class AdminRepository {
  final AdminApi _adminApi;

  AdminRepository({required AdminApi adminApi}) : _adminApi = adminApi;

  Future<AdminOverviewMetrics> getOverviewMetrics() async {
    return await _adminApi.getOverviewMetrics();
  }

  Future<List<AdminUserItem>> getAllUsers() async {
    return await _adminApi.getAllUsers();
  }

  Future<void> toggleUserSuspension(String userId, bool suspend) async {
    await _adminApi.toggleUserSuspension(userId, suspend);
  }
}
