import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget scopeWidget;
  final Widget controlPanelWidget;

  const ResponsiveLayout({Key key, this.scopeWidget, this.controlPanelWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: scopeWidget,
                flex: 1,
              ),
              Expanded(
                child: controlPanelWidget,
                flex: 1,
              )
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: scopeWidget,
                flex: 3,
              ),
              Expanded(
                child: controlPanelWidget,
                flex: 2,
              )
            ],
          );
        }
      },
    );
  }
}
