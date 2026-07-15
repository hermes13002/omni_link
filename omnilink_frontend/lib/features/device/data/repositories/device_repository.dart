import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../devices_api.dart';
import '../models/device_model.dart';

@lazySingleton
class DeviceRepository {
  final DevicesApi _api;
  final FlutterSecureStorage _storage;
  final Uuid _uuid = const Uuid();

  DeviceRepository(this._api, this._storage);

  Future<List<DeviceModel>> getDevices() async {
    return await _api.getDevices();
  }

  Future<DeviceModel> autoRegisterDevice() async {
    final storedSecret = await _storage.read(key: 'device_secret');
    if (storedSecret != null) {
      // Device is already registered. 
      // We could return the current device or just rely on the API to list it.
      // For now, if we need to return it, we might need an API to get current device by secret.
      // But we just skip registration.
      throw Exception('Device already registered on this client.');
    }

    // Since we don't have a device info package yet, generate a client UUID.
    final clientUuid = await _getClientUuid();
    final friendlyName = 'Flutter Client'; // TODO: use device_info_plus to get actual model name

    final device = await _api.registerDevice(clientUuid, friendlyName);
    
    if (device.deviceSecret != null) {
      await _storage.write(key: 'device_secret', value: device.deviceSecret);
    }
    
    return device;
  }

  Future<String> _getClientUuid() async {
    var clientUuid = await _storage.read(key: 'client_uuid');
    if (clientUuid == null) {
      clientUuid = _uuid.v4();
      await _storage.write(key: 'client_uuid', value: clientUuid);
    }
    return clientUuid;
  }

  Future<String?> getDeviceSecret() async {
    return await _storage.read(key: 'device_secret');
  }

  Future<void> deleteDevice(String deviceId) async {
    await _api.deleteDevice(deviceId);
  }
}
