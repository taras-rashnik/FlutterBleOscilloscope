import 'package:ble_oscilloscope/bloc/ble_cubit.dart';
import 'package:ble_oscilloscope/bloc/ble_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BleDetailsPage extends StatelessWidget {
  static const routeName = '/ble_details';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (contect, state) {
        final device = state.selectedDevice;
        final title = device?.name ?? device?.id ?? "N/A";

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              _getConnectButton(context, state),
            ],
          ),
          body: Center(
            child: Text("BLE device details"),
          ),
        );
      },
    );
  }
}

Widget _getConnectButton(BuildContext context, BleState state) {
  VoidCallback onPressed = state.connected
      ? () => BlocProvider.of<BleCubit>(context).disconnect()
      : (state.disconnected
          ? () => BlocProvider.of<BleCubit>(context).connect()
          : null);

  String title =
      state.connected ? "disconnect" : (state.disconnected ? "connect" : null);

  return TextButton(
    onPressed: onPressed,
    child: Text(title),
    style: TextButton.styleFrom(
      primary: Colors.white,
    ),
  );
}
