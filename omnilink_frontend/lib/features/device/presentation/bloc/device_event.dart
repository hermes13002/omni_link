import 'package:equatable/equatable.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class DevicesLoadRequested extends DeviceEvent {}

class DeviceAutoRegisterRequested extends DeviceEvent {}

class DeviceDeleteRequested extends DeviceEvent {
  final String deviceId;

  const DeviceDeleteRequested(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class DeviceUpdateRequested extends DeviceEvent {
  final String deviceId;
  final String friendlyName;

  const DeviceUpdateRequested(this.deviceId, this.friendlyName);

  @override
  List<Object?> get props => [deviceId, friendlyName];
}

class DevicePingRequested extends DeviceEvent {
  final String deviceId;

  const DevicePingRequested(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}
