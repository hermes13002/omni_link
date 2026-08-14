class AdminAuditLogItem {
  final String id;
  final String? adminId;
  final String action;
  final String resourceType;
  final String? resourceId;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  AdminAuditLogItem({
    required this.id,
    this.adminId,
    required this.action,
    required this.resourceType,
    this.resourceId,
    this.details,
    required this.createdAt,
  });

  factory AdminAuditLogItem.fromJson(Map<String, dynamic> json) {
    return AdminAuditLogItem(
      id: json['id'] as String,
      adminId: json['admin_id'] as String?,
      action: json['action'] as String,
      resourceType: json['resource_type'] as String,
      resourceId: json['resource_id'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
