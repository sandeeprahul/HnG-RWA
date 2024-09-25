import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cameraRatio = controller.value.aspectRatio;

    return Center(
      child: AspectRatio(
        aspectRatio: cameraRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Container(
                width: size.width,
                height: size.width / cameraRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
