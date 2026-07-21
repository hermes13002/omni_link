import 'package:isar/isar.dart';
import 'card_model.dart';
import 'tag_model.dart';

part 'isar_models.g.dart';

@collection
class IsarCard {
  Id get isarId => fastHash(id);
  
  @Index(unique: true, replace: true)
  late String id;
  
  late String cardType;
  String? title;
  String? body;
  late bool pinned;
  
  String? gcsSignedUrl;
  String? mimeType;
  int? fileSizeBytes;
  String? ogTitle;
  String? ogImage;
  String? sourceDeviceId;
  
  @Index()
  late DateTime createdAt;
  
  late DateTime updatedAt;
  
  List<IsarTag> tags = [];

  static IsarCard fromModel(CardModel model) {
    final isarCard = IsarCard()
      ..id = model.id
      ..cardType = model.cardType
      ..title = model.title
      ..body = model.body
      ..pinned = model.pinned
      ..gcsSignedUrl = model.gcsSignedUrl
      ..mimeType = model.mimeType
      ..fileSizeBytes = model.fileSizeBytes
      ..ogTitle = model.ogTitle
      ..ogImage = model.ogImage
      ..sourceDeviceId = model.sourceDeviceId
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..tags = model.tags.map((t) => IsarTag.fromModel(t)).toList();
    return isarCard;
  }

  CardModel toModel() {
    return CardModel(
      id: id,
      cardType: cardType,
      title: title,
      body: body,
      pinned: pinned,
      gcsSignedUrl: gcsSignedUrl,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      ogTitle: ogTitle,
      ogImage: ogImage,
      sourceDeviceId: sourceDeviceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags.map((t) => t.toModel()).toList(),
    );
  }
}

@embedded
class IsarTag {
  late String id;
  late String name;
  String? colorHex;

  static IsarTag fromModel(TagModel model) {
    return IsarTag()
      ..id = model.id
      ..name = model.name
      ..colorHex = model.colorHex;
  }

  TagModel toModel() {
    return TagModel(
      id: id,
      name: name,
      colorHex: colorHex,
    );
  }
}

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
