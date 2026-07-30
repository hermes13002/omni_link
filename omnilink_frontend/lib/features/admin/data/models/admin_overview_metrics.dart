class AdminOverviewMetrics {
  final double syncLatencyMs;
  final int activeSseConnections;
  final double dbPoolSaturationPercent;
  final double apiErrorRatePercent;
  final int dailyActiveUsers;
  final double devicesPerUser;
  final Map<String, int> itemsByType;
  final int totalUsers;
  final int newUsersToday;
  final int totalDevices;
  final int totalItems;

  AdminOverviewMetrics({
    required this.syncLatencyMs,
    required this.activeSseConnections,
    required this.dbPoolSaturationPercent,
    required this.apiErrorRatePercent,
    required this.dailyActiveUsers,
    required this.devicesPerUser,
    required this.itemsByType,
    required this.totalUsers,
    required this.newUsersToday,
    required this.totalDevices,
    required this.totalItems,
  });

  factory AdminOverviewMetrics.fromJson(Map<String, dynamic> json) {
    return AdminOverviewMetrics(
      syncLatencyMs: (json['sync_latency_ms'] as num).toDouble(),
      activeSseConnections: json['active_sse_connections'] as int,
      dbPoolSaturationPercent: (json['db_pool_saturation_percent'] as num).toDouble(),
      apiErrorRatePercent: (json['api_error_rate_percent'] as num).toDouble(),
      dailyActiveUsers: json['daily_active_users'] as int,
      devicesPerUser: (json['devices_per_user'] as num).toDouble(),
      itemsByType: Map<String, int>.from(json['items_by_type'] as Map),
      totalUsers: json['total_users'] as int,
      newUsersToday: json['new_users_today'] as int,
      totalDevices: json['total_devices'] as int,
      totalItems: json['total_items'] as int,
    );
  }
}
