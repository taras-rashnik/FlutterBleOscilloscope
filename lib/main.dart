import 'package:ble_oscilloscope/ble/ble_responsive_service.dart';
import 'package:ble_oscilloscope/bloc/samples_cubit.dart';
import 'package:ble_oscilloscope/control_panel_widget.dart';
import 'package:ble_oscilloscope/scope_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'layout/responsive_layout.dart';

void main() {
  runApp(RepositoryProvider(
    create: (_) => BleResponsiveService()..start(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SamplesCubit(context.read<BleResponsiveService>()),
      child: MaterialApp(
        title: 'BLE Oscillosope',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE Oscilloscope"),
      ),
      body: ResponsiveLayout(
        scopeWidget: ScopeWidget(),
        controlPanelWidget: ControlPanelWidget(),
      ),
    );
  }
}
