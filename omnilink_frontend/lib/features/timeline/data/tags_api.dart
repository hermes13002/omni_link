import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'models/tag_model.dart';

@lazySingleton
class TagsApi {
  final Dio _dio;

  TagsApi(this._dio);

  Future<List<TagModel>> getTags() async {
    final response = await _dio.get('/api/v1/tags');
    final items = response.data as List<dynamic>;
    return items.map((e) => TagModel.fromJson(e)).toList();
  }

  Future<TagModel> createTag(String name, {String? colorHex}) async {
    final data = <String, dynamic>{'name': name};
    if (colorHex != null) data['color_hex'] = colorHex;

    final response = await _dio.post('/api/v1/tags', data: data);
    return TagModel.fromJson(response.data);
  }

  Future<void> deleteTag(String tagId) async {
    await _dio.delete('/api/v1/tags/$tagId');
  }
}
