import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

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

  Future<DeviceModel?> autoRegisterDevice() async {
    final storedSecret = await _storage.read(key: 'device_secret');
    if (storedSecret != null) {
      // Device is already registered, skip registration.
      return null;
    }

    // Since we don't have a device info package yet, generate a client UUID.
    final clientUuid = await getClientUuid();
    final friendlyName = await _getDeviceName();

    try {
      final device = await _api.registerDevice(clientUuid, friendlyName);
      
      if (device.deviceSecret != null) {
        await _storage.write(key: 'device_secret', value: device.deviceSecret);
      }
      
      return device;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // The client_uuid is already registered (likely to another user account on this machine).
        // Generate a new one and retry.
        await _storage.delete(key: 'client_uuid');
        final newClientUuid = await getClientUuid();
        
        final device = await _api.registerDevice(newClientUuid, friendlyName);
        if (device.deviceSecret != null) {
          await _storage.write(key: 'device_secret', value: device.deviceSecret);
        }
        return device;
      }
      rethrow;
    }
  }

  Future<String> getClientUuid() async {
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

  Future<void> clearDeviceSecret() async {
    await _storage.delete(key: 'device_secret');
  }

  Future<void> deleteDevice(String deviceId) async {
    await _api.deleteDevice(deviceId);
  }

  Future<DeviceModel> updateDevice(String deviceId, String friendlyName) async {
    return await _api.updateDevice(deviceId, friendlyName);
  }

  Future<void> pingDevice(String deviceId) async {
    await _api.pingDevice(deviceId);
  }

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final webBrowserInfo = await deviceInfo.webBrowserInfo;
        return 'Web Browser (${webBrowserInfo.browserName.name})';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.prettyName;
      }
    } catch (e) {
      // ignore
    }
    return 'Unknown Device';
  }
}
