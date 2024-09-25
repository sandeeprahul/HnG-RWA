import 'dart:math';

import 'package:flutter/material.dart';

class HealthyGlowCurve extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 4, size.height / 2, size.width / 2, 0);
    path.quadraticBezierTo(size.width * 3 / 4, size.height / 2, size.width, 0);
    path.close();

    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
