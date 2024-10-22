import 'package:flutter/material.dart';

import '../common/zoomable_image.dart';

class ZoomImageScreen extends StatelessWidget {
  final String imageUrl;
  const ZoomImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Image'),
      ),
      body: ZoomableImage(imageUrl: imageUrl),

    );
  }
}
