import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/device_repository.dart';
import 'device_event.dart';
import 'device_state.dart';

@lazySingleton
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository _deviceRepository;

  DeviceBloc(this._deviceRepository) : super(DeviceInitial()) {
    on<DevicesLoadRequested>(_onLoadRequested);
    on<DeviceAutoRegisterRequested>(_onAutoRegisterRequested);
    on<DeviceDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    DevicesLoadRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      final devices = await _deviceRepository.getDevices();
      // Optionally find the current device from the list
      // final currentSecret = await _deviceRepository.getDeviceSecret();
      emit(DevicesLoaded(devices));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onAutoRegisterRequested(
    DeviceAutoRegisterRequested event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      await _deviceRepository.autoRegisterDevice();
      // reload devices
      if (state is DevicesLoaded) {
        add(DevicesLoadRequested());
      }
    } catch (e) {
      // It might throw if already registered, which is fine to ignore for auto-registration
      // print('Auto registration: $e');
    }
  }

  Future<void> _onDeleteRequested(
    DeviceDeleteRequested event,
    Emitter<DeviceState> emit,
  ) async {
    if (state is DevicesLoaded) {
      final currentState = state as DevicesLoaded;
      try {
        await _deviceRepository.deleteDevice(event.deviceId);
        final updated = currentState.devices.where((d) => d.id != event.deviceId).toList();
        emit(DevicesLoaded(updated, currentDevice: currentState.currentDevice));
      } catch (e) {
        emit(DeviceError(e.toString()));
        emit(currentState);
      }
    }
  }
}
