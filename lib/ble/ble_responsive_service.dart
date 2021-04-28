import 'dart:async';

import 'package:fimber/fimber.dart';

class BleResponsiveService {
  final _streamController = StreamController<List<int>>();
  bool _stopping = false;

  Stream<List<int>> get samplesStream => _streamController.stream;

  Future<void> start() async {
    Fimber.i("BleResponsiveService.start().");

    int counter = 10;
    while (!_stopping) {
      // Fimber.d("Send samples from BLE service.");
      _streamController.sink.add(List<int>.filled(512, counter++));
      if (counter > 250) counter = 5;

      await Future.delayed(Duration(milliseconds: 10));
    }

    Fimber.i("BleResponsiveService.start() exited.");
  }

  Future<void> stop() async {
    Fimber.i("BleResponsiveService.stop().");
    _stopping = true;
    await _streamController.close();
  }
}
