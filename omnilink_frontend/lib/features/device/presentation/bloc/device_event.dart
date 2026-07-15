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
