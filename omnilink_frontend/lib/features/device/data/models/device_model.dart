class DeviceModel {
  final String id;
  final String clientUuid;
  final String friendlyName;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final String? deviceSecret;

  DeviceModel({
    required this.id,
    required this.clientUuid,
    required this.friendlyName,
    this.lastSeen,
    required this.createdAt,
    this.deviceSecret,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      clientUuid: json['client_uuid'] as String,
      friendlyName: json['friendly_name'] as String,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      deviceSecret: json['device_secret'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_uuid': clientUuid,
      'friendly_name': friendlyName,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (deviceSecret != null) 'device_secret': deviceSecret,
    };
  }
}

