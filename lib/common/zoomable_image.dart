import 'package:flutter/material.dart';

class ZoomableImage extends StatefulWidget {
  final String imageUrl;

  const ZoomableImage({super.key, required this.imageUrl});

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  double _scale = 1.0; // Initial scale factor
  double _previousScale = 1.0; // Previous scale factor
  double _offsetX = 0.0; // Horizontal offset
  double _offsetY = 0.0; // Vertical offset
  double _previousOffsetX = 0.0; // Previous horizontal offset
  double _previousOffsetY = 0.0; // Previous vertical offset

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onScaleStart: (details) {
          _previousScale = _scale;
          _previousOffsetX = details.focalPoint.dx - _offsetX;
          _previousOffsetY = details.focalPoint.dy - _offsetY;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = _previousScale * details.scale;
            _offsetX = details.focalPoint.dx - _previousOffsetX;
            _offsetY = details.focalPoint.dy - _previousOffsetY;
          });
        },
        onScaleEnd: (details) {
          // Optionally, you can add some logic to snap back the image
        },
        child: Center(
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offsetX, _offsetY)
              ..scale(_scale, _scale),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
