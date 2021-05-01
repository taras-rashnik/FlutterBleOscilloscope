import 'package:ble_oscilloscope/ble/ble_responsive_service.dart';
import 'package:ble_oscilloscope/bloc/samples_cubit.dart';
import 'package:ble_oscilloscope/control_panel_widget.dart';
import 'package:ble_oscilloscope/scope_widget.dart';
import 'package:ble_oscilloscope/screens/ble_details_page.dart';
import 'package:ble_oscilloscope/screens/ble_devices_page.dart';
import 'package:ble_oscilloscope/screens/oscilloscope_page.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/ble_cubit.dart';
import 'layout/responsive_layout.dart';

void main() {
  Fimber.plantTree(DebugTree());
  Fimber.i("Start app.");

  runApp(Provider<BleResponsiveService>(
    create: (_) => BleResponsiveService(),
    dispose: (_, service) => service.stop(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SamplesCubit(context.read<BleResponsiveService>()),
          ),
          BlocProvider(
            create: (_) => BleCubit(context.read<BleResponsiveService>()),
          ),
        ],
        child: MaterialApp(
          title: 'BLE Oscillosope',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routes: {
            OscilloscopePage.routeName: (context) => OscilloscopePage(),
            BleDevicesPage.routeName: (context) => BleDevicesPage(),
            BleDetailsPage.routeName: (context) => BleDetailsPage(),
          },
          initialRoute: OscilloscopePage.routeName,
        ));
  }
}
