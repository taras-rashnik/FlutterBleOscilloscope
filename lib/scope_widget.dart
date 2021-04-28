import 'dart:ui';

import 'package:ble_oscilloscope/bloc/samples_cubit.dart';
import 'package:ble_oscilloscope/bloc/samples_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScopeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<SamplesCubit, SamplesState>(
        builder: (context, state) {
          return CustomPaint(
            painter: ScopePainter(state.samples),
            // size: Size(300, 200),
          );
        },
      ),
    );
  }
}

class ScopePainter extends CustomPainter {
  final List<int> samples;
  ScopePainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
        Rect.fromLTWH(5, 5, size.width - 10, size.height - 10), paint);

    final points = samples
        .asMap()
        .entries
        .map((e) => Offset(e.key.toDouble(), e.value.toDouble()))
        .where((p) => p.dx >= 0 && p.dy < size.width)
        .toList();

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
