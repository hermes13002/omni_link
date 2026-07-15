import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../features/device/data/repositories/device_repository.dart';
import '../../features/timeline/presentation/bloc/timeline_bloc.dart';
import '../../features/timeline/presentation/bloc/timeline_event.dart';

@lazySingleton
class SseClient {
  final Dio _dio;
  final DeviceRepository _deviceRepository;
  final TimelineBloc _timelineBloc;
  
  StreamSubscription? _subscription;
  bool _isConnected = false;

  SseClient(this._dio, this._deviceRepository, this._timelineBloc);

  Future<void> connect() async {
    if (_isConnected) return;

    final secret = await _deviceRepository.getDeviceSecret();
    if (secret == null) {
      print('Cannot connect to SSE: device secret is null');
      return;
    }

    try {
      final response = await _dio.get<ResponseBody>(
        '/api/v1/stream',
        queryParameters: {'device_secret': secret},
        options: Options(
          responseType: ResponseType.stream,
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
                // If a new event arrives, we can just trigger a reload for now
                // Or parse it if it contains the full card
                _timelineBloc.add(const TimelineLoadRequested());
              } catch (e) {
                print('Error processing SSE data: $e');
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
