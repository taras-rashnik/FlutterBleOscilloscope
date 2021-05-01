import 'package:ble_oscilloscope/bloc/ble_cubit.dart';
import 'package:ble_oscilloscope/bloc/ble_device.dart';
import 'package:ble_oscilloscope/bloc/ble_state.dart';
import 'package:ble_oscilloscope/screens/ble_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BleDevicesPage extends StatelessWidget {
  static const routeName = '/ble_device';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: Text("BLE devices"),
              actions: [
                _getScanButton(context, state),
              ],
            ),
            body: ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                return _bleDeviceCard(context, state.devices[index]);
              },
            ));
      },
    );
  }
}

Widget _getScanButton(BuildContext context, BleState state) {
  return TextButton(
    onPressed: () {
      if (state.scanning)
        BlocProvider.of<BleCubit>(context).stopScanning();
      else
        BlocProvider.of<BleCubit>(context).startScanning();
    },
    child: Text(state.scanning ? "stop scanning" : "scan"),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  );
}

Widget _bleDeviceCard(BuildContext context, BleDevice device) {
  return Card(
    child: ListTile(
      dense: true,
      enabled: true,
      trailing: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {},
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: const Icon(Icons.add_link),
        ),
      ),
      subtitle: Text(device.id),
      title: Text("${device.name}"),
      onTap: () {
        BlocProvider.of<BleCubit>(context).selectDevice(device);
        Navigator.pushNamed(context, BleDetailsPage.routeName);
      },
    ),
  );
}
