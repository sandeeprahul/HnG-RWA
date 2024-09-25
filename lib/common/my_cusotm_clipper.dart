import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a list of points for the sigmoid curve.
    List<double> points = [];
    for (int i = -10; i <= 10; i++) {
      points.add(sigmoid(double.parse(i.toString())));
    }

    // Create a path.
    Path path = Path();
    path.moveTo(0, 0);
    for (int i = 0; i < points.length; i++) {
      path.lineTo(i.toDouble(), points[i]);
    }
    path.lineTo(size.width, 0);
    path.close();

    return path;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
double sigmoid(double x) {
  return 1 / (1 + exp(-x));
}
