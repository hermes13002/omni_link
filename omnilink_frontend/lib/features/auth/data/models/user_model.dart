class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final bool hasPassword;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.hasPassword,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      hasPassword: json['has_password'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'has_password': hasPassword,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
