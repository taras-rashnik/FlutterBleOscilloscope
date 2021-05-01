import 'package:ble_oscilloscope/layout/responsive_layout.dart';
import 'package:ble_oscilloscope/screens/ble_devices_page.dart';
import 'package:flutter/material.dart';

import '../control_panel_widget.dart';
import '../scope_widget.dart';

class OscilloscopePage extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE Oscilloscope"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: "select device",
            onPressed: () {
              Navigator.pushNamed(context, BleDevicesPage.routeName);
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        scopeWidget: ScopeWidget(),
        controlPanelWidget: ControlPanelWidget(),
      ),
    );
  }
}
