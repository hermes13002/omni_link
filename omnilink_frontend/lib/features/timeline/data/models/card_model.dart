import 'dart:typed_data';
import 'tag_model.dart';

enum CardSyncStatus { pending, synced, error }

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
  final CardSyncStatus syncStatus;
  final Uint8List? localBytes;

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
    this.syncStatus = CardSyncStatus.synced,
    this.localBytes,
  });

  CardModel copyWith({
    String? id,
    String? cardType,
    String? title,
    String? body,
    bool? pinned,
    List<TagModel>? tags,
    String? gcsSignedUrl,
    String? mimeType,
    int? fileSizeBytes,
    String? ogTitle,
    String? ogImage,
    String? sourceDeviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    CardSyncStatus? syncStatus,
    Uint8List? localBytes,
  }) {
    return CardModel(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      title: title ?? this.title,
      body: body ?? this.body,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
      gcsSignedUrl: gcsSignedUrl ?? this.gcsSignedUrl,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      ogTitle: ogTitle ?? this.ogTitle,
      ogImage: ogImage ?? this.ogImage,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localBytes: localBytes ?? this.localBytes,
    );
  }

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
      syncStatus: CardSyncStatus.synced, // Always synced when coming from API
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
