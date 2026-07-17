import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:omnilink_frontend/features/device/data/repositories/device_repository.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_event.dart';
import '../../shared/utils/omni_toast.dart';

@lazySingleton
class SseClient {
  final Dio _dio;
  final DeviceRepository _deviceRepository;
  final TimelineBloc _timelineBloc;
  
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _currentDeviceId;

  SseClient(this._dio, this._deviceRepository, this._timelineBloc);

  Future<void> connect() async {
    if (_isConnected) return;

    final secret = await _deviceRepository.getDeviceSecret();
    if (secret == null) {
      print('Cannot connect to SSE: device secret is null');
      return;
    }

    try {
      final devices = await _deviceRepository.getDevices();
      final clientUuid = await _deviceRepository.getClientUuid();
      final currentDevice = devices.cast<dynamic>().firstWhere((d) => d.clientUuid == clientUuid, orElse: () => null);
      _currentDeviceId = currentDevice?.id;
    } catch (e) {
      print('Failed to get current device ID for SSE filtering: $e');
    }

    try {
      final response = await _dio.get<ResponseBody>(
        '/api/v1/stream',
        queryParameters: {'device_secret': secret},
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(milliseconds: 0),
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      _isConnected = true;

      _subscription = response.data?.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (String line) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr.isNotEmpty) {
              try {
                final decoded = jsonDecode(dataStr);
                if (decoded is Map<String, dynamic>) {
                  final payload = decoded['payload'];
                  final targetDeviceIds = decoded['target_device_ids'] as List<dynamic>?;

                  // If this event is targeted at specific devices, check if we are one of them
                  bool isTargetedAtMe = true;
                  if (targetDeviceIds != null && targetDeviceIds.isNotEmpty) {
                    isTargetedAtMe = _currentDeviceId != null && targetDeviceIds.contains(_currentDeviceId);
                  }

                  if (isTargetedAtMe && payload is Map<String, dynamic> && payload['type'] == 'ping') {
                    final message = payload['message'] ?? 'Ping received!';
                    OmniToast.showInfo(null, message);
                  } else {
                    // It's a broadcast event (like new card) or targeted at us, trigger reload
                    if (isTargetedAtMe || payload is Map<String, dynamic> && payload['type'] != 'ping') {
                      _timelineBloc.add(const TimelineLoadRequested());
                    }
                  }
                } else {
                  _timelineBloc.add(const TimelineLoadRequested());
                }
              } catch (e) {
                // Not json, maybe just trigger reload
                _timelineBloc.add(const TimelineLoadRequested());
              }
            }
          } else if (line == ': keepalive') {
            // keepalive, ignore
          }
        },
        onError: (e) {
          print('SSE stream error: $e');
          _reconnect();
        },
        onDone: () {
          print('SSE stream done');
          _reconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Failed to connect to SSE: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    
    // Attempt reconnect after delay
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
  }
}
