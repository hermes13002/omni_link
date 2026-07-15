import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'models/device_model.dart';

@lazySingleton
class DevicesApi {
  final Dio _dio;

  DevicesApi(this._dio);

  Future<List<DeviceModel>> getDevices() async {
    final response = await _dio.get('/api/v1/devices');
    final items = response.data as List<dynamic>;
    return items.map((e) => DeviceModel.fromJson(e)).toList();
  }

  Future<DeviceModel> registerDevice(String clientUuid, String friendlyName) async {
    final response = await _dio.post('/api/v1/devices', data: {
      'client_uuid': clientUuid,
      'friendly_name': friendlyName,
    });
    return DeviceModel.fromJson(response.data);
  }

  Future<void> deleteDevice(String deviceId) async {
    await _dio.delete('/api/v1/devices/$deviceId');
  }
}
