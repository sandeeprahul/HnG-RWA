

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/new_camera_handling_for_lower_version/cameraPageControllerForLowerVersions.dart';
import 'dart:io'; // New Import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'cameraPageControllerForLowerVersions.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import 'cameraPageControllerForLowerVersions.dart';

class CameraPageForLowerVersions extends StatefulWidget {
  const CameraPageForLowerVersions({super.key});

  @override
  State<CameraPageForLowerVersions> createState() =>
      _CameraPageForLowerVersionsState();
}

class _CameraPageForLowerVersionsState
    extends State<CameraPageForLowerVersions> {
  final CameraPageControllerForLowerVersions controller = Get.find();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid) {
        /// Android → use CameraController
        await controller.initializeCamera();
        setState(() {});
      } else {
        /// iOS → open ImagePicker camera immediately
        final image = await ImagePicker().pickImage(source: ImageSource.camera);

        if (image == null) {
          Get.back(); // user cancelled
          return;
        }

        // Crop + process same as Android
        final result = await controller.cropAndProcessImage(image.path);

        if (result == 1) {
          Get.back(result: controller.imagePath.value);
        } else {
          Get.back();
        }
      }
    });
  }

  /// Android photo capture
  Future<void> _captureAndroidImage() async {
    final imagePath = await controller.takePicture();

    if (imagePath != null) {
      final result = await controller.cropAndProcessImage(imagePath);

      if (result == 1) {
        Get.back(result: controller.imagePath.value);
      } else {
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    // iOS never reaches this UI → it directly opens ImagePicker camera
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Image")),
      body: Obx(() {
        if (Platform.isIOS) {
          return const Center(
            child: Text(
              "Opening camera...",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        /// ANDROID PREVIEW UI
        final bool isInitialized = controller.isCameraInitialized.value;
        final CameraController? camController =
            controller.cameraControllerRx.value;

        if (isInitialized && camController != null) {
          return Stack(
            children: [
              Positioned.fill(child: CameraPreview(camController)),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: _captureAndroidImage,
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 35,
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}

//
// class CameraPageForLowerVersions extends StatefulWidget {
//   const CameraPageForLowerVersions({super.key});
//
//   @override
//   State<CameraPageForLowerVersions> createState() => _CameraPageForLowerVersionsState();
// }
//
// class _CameraPageForLowerVersionsState extends State<CameraPageForLowerVersions> {
//   final CameraPageControllerForLowerVersions controller = Get.find();
//
//   @override
//   void initState() {
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) => _handleCameraInit());
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (Platform.isAndroid) {
//         await controller.initializeCamera();
//         setState(() {}); // Force rebuild after camera is ready
//       }
//     });
//   }
//
//
//
//   Future<void> _captureImage() async {
//     final imagePath = await controller.takePicture();
//     if (imagePath != null) {
//       final result = await controller.cropAndProcessImage(imagePath);
//       if (result == 1) {
//         Get.back(result: controller.imagePath.value);
//       } else {
//         Get.back();
//       }
//     } else {
//       Get.back();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Capture Image")),
//       body: Obx(() {
//         final bool isInitialized = controller.isCameraInitialized.value;
//         final CameraController? camController = controller.cameraControllerRx.value;
//
//         print("isInitialized");
//         print(isInitialized);
//         print(camController);
//         if ( isInitialized && camController != null) {
//           return Stack(
//             children: [
//               SizedBox(
//                 height: double.infinity,
//                 width: double.infinity,
//                 child: CameraPreview(camController),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: InkWell(
//                   onTap: _captureImage,
//                   child: const Padding(
//                     padding: EdgeInsets.all(15.0),
//                     child: CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 35,
//                       child: Icon(Icons.camera_alt),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//
//         return const Center(child: CircularProgressIndicator());
//       }),
//     );
//   }
// }
//
// // class CameraPageForLowerVersions extends StatefulWidget {
// //   const CameraPageForLowerVersions({super.key});
// //
// //   @override
// //   State<CameraPageForLowerVersions> createState() => _CameraPageForLowerVersionsState();
// // }
// //
// // class _CameraPageForLowerVersionsState extends State<CameraPageForLowerVersions> {
// //   final CameraPageControllerForLowerVersions controller = Get.find<CameraPageControllerForLowerVersions>();
// //   bool showCameraPreview = false; // Flag to control preview visibility
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Delay until after first frame
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _handleCameraInit();
// //     });
// //   }
// //
// //   // Define a separate async function to handle async operations
// //   Future<void> _handleCameraInit() async {
// //     if (Platform.isAndroid) {
// //       // For Android, wait for the CameraController to initialize
// //       // and set flag to show the custom camera UI.
// //       if (!controller.isCameraInitialized.value) {
// //         await controller.initializeCamera();
// //       }
// //       // No need for setState or showCameraPreview flag here.
// //       if (!controller.isCameraInitialized.value) {
// //         // Camera failed to init, close the page
// //         Get.back();
// //       }
// //     } else {
// //       // For iOS, use the simple ImagePicker logic
// //       final path = await controller.getPhoto();
// //       if (path != null) {
// //         Get.back(result: path);
// //       } else {
// //         Get.back();
// //       }
// //     }
// //   }
// //
// //   // Function to capture image when the button is pressed on Android
// //   Future<void> _captureImage() async {
// //     final imagePath = await controller.takePicture();
// //
// //     if (imagePath != null) {
// //       final result = await controller.cropAndProcessImage(imagePath);
// //       if (result == 1) {
// //         Get.back(result: controller.imagePath.value);
// //       } else {
// //         Get.back();
// //       }
// //     } else {
// //       Get.back();
// //     }
// //   }
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Capture Image")),
// //       body: Obx(() {
// //         // final camController = controller.cameraController;
// // // Read the reactive variables inside Obx
// //         final bool isInitialized = controller.isCameraInitialized.value;
// //         final CameraController? camController = controller.cameraControllerRx.value;
// //         print("isInitialized");
// //         print(isInitialized);
// //         print(camController);
// //         // --- Android Camera UI (using 'camera' package) ---
// //         if (Platform.isAndroid && isInitialized && camController != null) {
// //           return Stack(
// //             children: [
// //               SizedBox(
// //                 height: double.infinity,
// //                 width: double.infinity,
// //                 child: CameraPreview(camController),
// //               ),
// //               Align(
// //                 alignment: Alignment.bottomCenter,
// //                 child: InkWell(
// //                   onTap: _captureImage, // Call the capture function
// //                   child: const Padding(
// //                     padding: EdgeInsets.all(15.0),
// //                     child: CircleAvatar(
// //                       backgroundColor: Colors.white,
// //                       radius: 35,
// //                       child: Icon(Icons.camera_alt),
// //                     ),
// //                   ),
// //                 ),
// //               )
// //             ],
// //           );
// //         }
// //
// //         // --- Placeholder UI (iOS or Android while initializing) ---
// //         return const Center(child: CircularProgressIndicator());
// //       }),
// //     );
// //   }
// // }