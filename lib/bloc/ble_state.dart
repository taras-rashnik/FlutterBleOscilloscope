import 'package:ble_oscilloscope/bloc/ble_device.dart';

enum BleDeviceConnectionState {
  connecting,
  connected,
  disconnecting,
  disconnected
}

class BleState {
  final BleDevice selectedDevice;
  final List<BleDevice> devices;
  final bool permissionGranted;
  final bool scanning;
  final String status;
  final String lastError;
  final BleDeviceConnectionState connectionState;

  BleState({
    this.selectedDevice,
    this.devices = const <BleDevice>[],
    this.permissionGranted = false,
    this.scanning = false,
    this.status = "na",
    this.lastError,
    this.connectionState = BleDeviceConnectionState.disconnected,
  });

  factory BleState.initial() {
    return BleState();
  }

  bool get connected => connectionState == BleDeviceConnectionState.connected;

  bool get disconnected =>
      connectionState == BleDeviceConnectionState.disconnected;

  BleState update({
    BleDevice selectedDevice,
    List<BleDevice> devices,
    bool permissionGranted,
    bool scanning,
    String status,
    String lastError,
    BleDeviceConnectionState connectionState,
  }) {
    return BleState(
      selectedDevice: selectedDevice ?? this.selectedDevice,
      devices: devices ?? this.devices,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      scanning: scanning ?? this.scanning,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      connectionState: connectionState ?? this.connectionState,
    );
  }

  BleState addDevice(BleDevice device) {
    if (devices.any((element) => element.id == device.id)) return this;

    return update(devices: [...devices, device]);
  }

  BleState addError(String error) {
    return update(lastError: error);
  }
}
