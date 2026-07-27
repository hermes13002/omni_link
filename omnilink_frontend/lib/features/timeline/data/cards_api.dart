import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'models/card_model.dart';

@lazySingleton
class CardsApi {
  final Dio _dio;

  CardsApi(this._dio);

  Future<List<CardModel>> getCards({
    int page = 1,
    int pageSize = 20,
    String? cardType,
    String? tagId,
    bool? pinned,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (cardType != null) query['card_type'] = cardType;
    if (tagId != null) query['tag_id'] = tagId;
    if (pinned != null) query['pinned'] = pinned;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _dio.get('/api/v1/cards', queryParameters: query);
    final items = response.data['items'] as List<dynamic>;
    return items.map((e) => CardModel.fromJson(e)).toList();
  }

  Future<CardModel> createTextCard(String body, {String? title, List<String>? tagIds}) async {
    final response = await _dio.post('/api/v1/cards/text', data: {
      'body': body,
      if (title != null) 'title': title,
      if (tagIds != null) 'tag_ids': tagIds,
    });
    return CardModel.fromJson(response.data);
  }

  Future<CardModel> createMetadataCard(String title, {String? body, List<String>? tagIds}) async {
    final response = await _dio.post('/api/v1/cards/metadata', data: {
      'title': title,
      if (body != null) 'body': body,
      if (tagIds != null) 'tag_ids': tagIds,
    });
    return CardModel.fromJson(response.data);
  }

  Future<CardModel> createFileCard({
    String? filePath,
    List<int>? bytes,
    required String fileName,
    String? title, 
    List<String>? tagIds,
  }) async {
    MultipartFile? multipartFile;
    
    if (bytes != null) {
      multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
    } else if (filePath != null) {
      multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
    } else {
      throw Exception('Either filePath or bytes must be provided');
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
    });
    
    final query = <String, dynamic>{};
    if (title != null) {
      query['title'] = title;
    }
    if (tagIds != null && tagIds.isNotEmpty) {
      query['tag_ids'] = tagIds.join(',');
    }

    final response = await _dio.post('/api/v1/cards/file', data: formData, queryParameters: query);
    return CardModel.fromJson(response.data);
  }

  Future<CardModel> getCard(String cardId) async {
    final response = await _dio.get('/api/v1/cards/$cardId');
    return CardModel.fromJson(response.data);
  }

  Future<CardModel> updateCard(String cardId, {String? title, String? body, bool? pinned, List<String>? tagIds}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (body != null) data['body'] = body;
    if (pinned != null) data['pinned'] = pinned;
    if (tagIds != null) data['tag_ids'] = tagIds;

    final response = await _dio.patch('/api/v1/cards/$cardId', data: data);
    return CardModel.fromJson(response.data);
  }

  Future<void> deleteCard(String cardId) async {
    await _dio.delete('/api/v1/cards/$cardId');
  }
}
