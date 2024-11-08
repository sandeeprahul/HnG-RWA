import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/camerapageController.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraPage extends StatefulWidget {

   const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final CameraPageController controller = Get.put(CameraPageController());

  @override
  void initState() {
    super.initState();
    // Call an async method to capture and crop image when the page is initialized
    _captureAndCropImageOnInit();
  }

  // Define a separate async function to handle async operations
  Future<void> _captureAndCropImageOnInit() async {
    await controller.captureAndCropImage(); // Capture and crop image on page init
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Capture Image")),
      body: Obx(() {
        return Stack(
          children: [
            // If the camera is visible, show a placeholder for the camera
            if (controller.camVisible.value)
        const Center(child: CircularProgressIndicator()), //

          ],
        );
      }),
    );
  }
}

