class AdminUserItem {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final String role;
  final bool isSuspended;
  final int deviceCount;
  final int storageUsedBytes;

  AdminUserItem({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.role,
    required this.isSuspended,
    required this.deviceCount,
    required this.storageUsedBytes,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String,
      isSuspended: json['is_suspended'] as bool,
      deviceCount: json['device_count'] as int,
      storageUsedBytes: json['storage_used_bytes'] as int,
    );
  }
}
