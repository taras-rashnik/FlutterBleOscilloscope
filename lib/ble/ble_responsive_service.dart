import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleResponsiveService {
  final Uuid SERVICE_UUID = Uuid.parse("924c7d3c-a4da-11eb-bcbc-0242ac130002");
  final Uuid CHARACTERISTIC_UUID =
      Uuid.parse("a4154cd8-a4da-11eb-bcbc-0242ac130002");

  final _ble = FlutterReactiveBle();
  final _streamController = StreamController<List<int>>();

  Stream<List<int>> get samplesStream => _streamController.stream;

  Future<void> start() async {
    Fimber.i("start().");

    try {
      _ble.statusStream.listen((status) {
        Fimber.i("Status: $status");
      });

      await _checkPermissions();
      DiscoveredDevice device = await _findDevice();
      await _connectToDevice(device);
      await Future.delayed(Duration(seconds: 2));
      await _ble.requestMtu(deviceId: device.id, mtu: 517);
      var stream = _getCharacteristicStream(device);

      stream.listen(
        (data) {
          _streamController.sink.add(data);
        },
        onError: (dynamic error) {
          Fimber.e("error getting data", ex: error);
        },
      );
    } catch (e) {
      Fimber.e("Error in start().", ex: e);
    }

    // int counter = 10;
    // while (!_stopping) {
    //   // Fimber.d("Send samples from BLE service.");
    //   _streamController.sink.add(List<int>.filled(512, counter++));
    //   if (counter > 250) counter = 5;

    //   await Future.delayed(Duration(milliseconds: 10));
    // }

    // Fimber.i("BleResponsiveService.start() exited.");
  }

  Future<void> stop() async {
    Fimber.i("stop().");
    await _streamController.close();
  }

  Future<void> _checkPermissions() async {
    Fimber.i("_checkPermissions()");

    if (Platform.isAndroid) {
      var locGranted = await Permission.location.isGranted;
      if (locGranted == false) {
        locGranted = (await Permission.location.request()).isGranted;
      }
      if (locGranted == false) {
        Fimber.e("Location permission not granted");
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }

  Future<DiscoveredDevice> _findDevice() async {
    Fimber.i("_findDevice()");

    final completer = Completer<DiscoveredDevice>();

    StreamSubscription<DiscoveredDevice> subscription;

    subscription = _ble.scanForDevices(
      withServices: [SERVICE_UUID],
    ).listen(
      (device) async {
        Fimber.d("Device scanning: ${device.name}, with id: ${device.id}");
        if (device.name == "BLE Oscilloscope") {
          Fimber.i("Defice found: ${device.name}, with id: ${device.id}");
          await subscription.cancel();
          completer.complete(device);
        }
      },
      onError: (Object error) {
        Fimber.e("Error in _findDevice()", ex: error);
      },
    );

    return completer.future;
  }

  Future<void> _connectToDevice(DiscoveredDevice device) async {
    Fimber.i("_connectToDevice(${device.name})");

    final completer = Completer();

    final stream = _ble.connectToAdvertisingDevice(
      id: device.id,
      prescanDuration: Duration(seconds: 1),
      withServices: [SERVICE_UUID],
      servicesWithCharacteristicsToDiscover: {
        SERVICE_UUID: [CHARACTERISTIC_UUID]
      },
      connectionTimeout: const Duration(seconds: 2),
    );

    StreamSubscription<ConnectionStateUpdate> subscription;
    subscription = stream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            Fimber.i("Connecting to ${event.deviceId}");
            break;
          }
        case DeviceConnectionState.connected:
          {
            Fimber.i("Connected to ${event.deviceId}");
            completer.complete();
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            Fimber.i("Disconnecting from ${event.deviceId}");
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            Fimber.i("Disconnected from ${event.deviceId}");
            break;
          }
      }
    });

    return completer.future;
  }

  Stream<List<int>> _getCharacteristicStream(DiscoveredDevice device) {
    var characteristic = QualifiedCharacteristic(
      serviceId: SERVICE_UUID,
      characteristicId: CHARACTERISTIC_UUID,
      deviceId: device.id,
    );

    return _ble.subscribeToCharacteristic(characteristic);
  }
}
