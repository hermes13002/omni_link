class TagModel {
  final String id;
  final String name;
  final String? colorHex;

  TagModel({
    required this.id,
    required this.name,
    this.colorHex,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['color_hex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
    };
  }
}
