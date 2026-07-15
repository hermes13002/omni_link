import 'tag_model.dart';

class CardModel {
  final String id;
  final String cardType;
  final String? title;
  final String? body;
  final bool pinned;
  final List<TagModel> tags;
  final String? gcsSignedUrl;
  final String? mimeType;
  final int? fileSizeBytes;
  final String? ogTitle;
  final String? ogImage;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardModel({
    required this.id,
    required this.cardType,
    this.title,
    this.body,
    required this.pinned,
    required this.tags,
    this.gcsSignedUrl,
    this.mimeType,
    this.fileSizeBytes,
    this.ogTitle,
    this.ogImage,
    this.sourceDeviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      cardType: json['card_type'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      pinned: json['pinned'] as bool,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gcsSignedUrl: json['gcs_signed_url'] as String?,
      mimeType: json['mime_type'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      ogTitle: json['og_title'] as String?,
      ogImage: json['og_image'] as String?,
      sourceDeviceId: json['source_device_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_type': cardType,
      'title': title,
      'body': body,
      'pinned': pinned,
      'tags': tags.map((e) => e.toJson()).toList(),
      'gcs_signed_url': gcsSignedUrl,
      'mime_type': mimeType,
      'file_size_bytes': fileSizeBytes,
      'og_title': ogTitle,
      'og_image': ogImage,
      'source_device_id': sourceDeviceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
