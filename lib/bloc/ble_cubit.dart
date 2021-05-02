import 'dart:async';

import 'package:ble_oscilloscope/ble/ble_responsive_service.dart';
import 'package:ble_oscilloscope/bloc/ble_device.dart';
import 'package:ble_oscilloscope/bloc/ble_state.dart';
import 'package:bloc/bloc.dart';
import 'package:fimber/fimber.dart';

class BleCubit extends Cubit<BleState> {
  final BleResponsiveService bleService;

  BleCubit(this.bleService) : super(BleState.initial()) {
    bleService.statusStream.listen((status) {
      Fimber.i("Status: $status");
      emit(state.update(status: status));
    }, onError: (error) {
      emit(state.addError(error.toString()));
    });

    bleService.devicesStream.listen((device) {
      Fimber.i("Device found: $device");
      emit(state.addDevice(device));
    }, onError: (error) {
      emit(state.addError(error.toString()));
    });

    bleService.connectionStateStream.listen((connectionState) {
      Fimber.i("Connection state: $connectionState");
      emit(state.update(connectionState: connectionState));
    }, onError: (error) {
      emit(state.addError(error.toString()));
    });
  }

  StreamSubscription<BleDevice> _scanSubscription;

  void startScanning() async {
    stopScanning();
    Fimber.i("Start scanning");

    try {
      await bleService.checkPermissions();
      emit(state.update(permissionGranted: true));
    } catch (error) {
      emit(state.addError(error.toString()));
      emit(state.update(permissionGranted: false));
    }

    try {
      emit(state.update(devices: <BleDevice>[]));
      _scanSubscription = bleService.scanForDevices();
      emit(state.update(scanning: true));
    } catch (error) {
      emit(state.addError(error.toString()));
    }
  }

  void stopScanning() {
    Fimber.i("Stop scanning");

    try {
      _scanSubscription?.cancel();
      _scanSubscription = null;
      emit(state.update(scanning: false));
    } catch (error) {
      emit(state.addError(error.toString()));
    }
  }

  StreamSubscription _connectionStateSubscription = null;

  void connect() {
    disconnect();
    final device = state.selectedDevice;
    if (device == null) return;

    Fimber.i("Connecting to $device");
    _connectionStateSubscription = bleService.connectToDevice(device);
  }

  void disconnect() {
    Fimber.i("Disconnectiong...");
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    emit(state.update(connectionState: BleDeviceConnectionState.disconnected));
  }

  void selectDevice(BleDevice device) {
    Fimber.i("Selecting device: $device");
    disconnect();
    stopScanning();
    emit(state.update(selectedDevice: device));
  }
}
