import 'package:equatable/equatable.dart';
import '../../data/models/device_model.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DevicesLoaded extends DeviceState {
  final List<DeviceModel> devices;
  final DeviceModel? currentDevice;

  const DevicesLoaded(this.devices, {this.currentDevice});

  @override
  List<Object?> get props => [devices, currentDevice];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}
