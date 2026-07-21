import 'dart:async';
import 'package:injectable/injectable.dart';

@singleton
class GlobalEventBus {
  final _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void fire(String event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
