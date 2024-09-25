import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hng_flutter/common/my_cusotm_clipper.dart';

class MyCustomClipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create a path.
    Path path = MyCustomClipper().getClip(size);

    // Draw the path.
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}