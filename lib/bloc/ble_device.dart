class BleDevice {
  final String id;
  final String name;

  BleDevice({this.id, this.name});

  @override
  String toString() {
    return "BleDevice(id: $id, name: $name)";
  }
}
