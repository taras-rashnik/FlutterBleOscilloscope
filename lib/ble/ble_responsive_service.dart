import 'dart:async';
import 'dart:io';

import 'package:ble_oscilloscope/bloc/ble_device.dart';
import 'package:ble_oscilloscope/bloc/ble_state.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleResponsiveService {
  final Uuid SERVICE_UUID = Uuid.parse("924c7d3c-a4da-11eb-bcbc-0242ac130002");
  final Uuid CHARACTERISTIC_UUID =
      Uuid.parse("a4154cd8-a4da-11eb-bcbc-0242ac130002");

  final _ble = FlutterReactiveBle();

  final _samplesStreamController = StreamController<List<int>>();
  Stream<List<int>> get samplesStream => _samplesStreamController.stream;

  Stream<String> get statusStream =>
      _ble.statusStream.map((status) => status.toString());

  final _devicesStreamController = StreamController<BleDevice>();
  Stream<BleDevice> get devicesStream => _devicesStreamController.stream;

  final _connectionStateStreamController =
      StreamController<BleDeviceConnectionState>();
  Stream<BleDeviceConnectionState> get connectionStateStream =>
      _connectionStateStreamController.stream;

  // Future<void> start() async {
  //   Fimber.i("start().");

  //   try {
  //     await checkPermissions();
  //     DiscoveredDevice device = await _findDevice();
  //     await _connectToDevice(device);
  //     await Future.delayed(Duration(seconds: 2));
  //     await _ble.requestMtu(deviceId: device.id, mtu: 517);
  //     var stream = _getCharacteristicStream(device);

  //     stream.listen(
  //       (data) {
  //         _samplesStreamController.sink.add(data);
  //       },
  //       onError: (dynamic error) {
  //         Fimber.e("error getting data", ex: error);
  //       },
  //     );
  //   } catch (e) {
  //     Fimber.e("Error in start().", ex: e);
  //   }
  // }

  Future<void> stop() async {
    Fimber.i("stop().");
    await _samplesStreamController.close();
    await _devicesStreamController.close();
    await _connectionStateStreamController.close();
  }

  Future<void> checkPermissions() async {
    Fimber.i("Checking permissions");

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

  StreamSubscription<BleDevice> scanForDevices() {
    return _ble
        // .scanForDevices(withServices: [SERVICE_UUID])
        .scanForDevices(withServices: [])
        .map((device) => BleDevice(id: device.id, name: device.name))
        .listen(
          (device) async {
            Fimber.d("Device scanning: ${device.name}, with id: ${device.id}");
            _devicesStreamController.sink.add(device);
          },
          onError: (Object error) {
            Fimber.e("Error in _findDevice()", ex: error);
          },
        );
  }

  // Future<DiscoveredDevice> _findDevice() async {
  //   Fimber.i("_findDevice()");

  //   final completer = Completer<DiscoveredDevice>();

  //   StreamSubscription<DiscoveredDevice> subscription;

  //   subscription = _ble.scanForDevices(
  //     withServices: [SERVICE_UUID],
  //   ).listen(
  //     (device) async {
  //       Fimber.d("Device scanning: ${device.name}, with id: ${device.id}");
  //       if (device.name == "BLE Oscilloscope") {
  //         Fimber.i("Defice found: ${device.name}, with id: ${device.id}");
  //         await subscription.cancel();
  //         completer.complete(device);
  //       }
  //     },
  //     onError: (Object error) {
  //       Fimber.e("Error in _findDevice()", ex: error);
  //     },
  //   );

  //   return completer.future;
  // }

  Future<void> connectToDevice(BleDevice device) async {
    Fimber.i("connectToDevice(${device.name ?? device.id})");

    final completer = Completer();

    final stream = _ble.connectToAdvertisingDevice(
      id: device.id,
      prescanDuration: Duration(seconds: 1),
      // withServices: [SERVICE_UUID],
      withServices: [],
      // servicesWithCharacteristicsToDiscover: {
      //   SERVICE_UUID: [CHARACTERISTIC_UUID]
      // },
      connectionTimeout: const Duration(seconds: 2),
    );

    StreamSubscription<ConnectionStateUpdate> subscription;
    subscription = stream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            Fimber.i("Connecting to ${event.deviceId}");
            _connectionStateStreamController.sink
                .add(BleDeviceConnectionState.connecting);
            break;
          }
        case DeviceConnectionState.connected:
          {
            Fimber.i("Connected to ${event.deviceId}");
            _connectionStateStreamController.sink
                .add(BleDeviceConnectionState.connected);
            completer.complete();
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            Fimber.i("Disconnecting from ${event.deviceId}");
            _connectionStateStreamController.sink
                .add(BleDeviceConnectionState.disconnecting);
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            Fimber.i("Disconnected from ${event.deviceId}");
            _connectionStateStreamController.sink
                .add(BleDeviceConnectionState.disconnected);
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
