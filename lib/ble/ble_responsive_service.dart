import 'dart:async';

class BleResponsiveService {
  final _streamController = StreamController<List<int>>();
  bool _stopping = false;

  Stream<List<int>> get samplesStream => _streamController.stream;

  Future<void> start() async {
    int counter = 10;
    while (!_stopping) {
      _streamController.sink.add(List<int>.filled(512, counter++));
      if (counter > 250) counter = 5;

      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  Future<void> stop() async {
    _stopping = true;
    await _streamController.close();
  }
}
