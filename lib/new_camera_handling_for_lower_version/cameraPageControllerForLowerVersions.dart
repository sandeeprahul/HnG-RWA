import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // New Import
import 'package:permission_handler/permission_handler.dart'; // New Import
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPageControllerForLowerVersions extends GetxController {
  final ImagePicker picker = ImagePicker();

  // Reactive variables
  var base64img = ''.obs;
  var imagePath = ''.obs;
  var croppedImageFile = Rx<XFile?>(null);
  var croppedImageFiles = <XFile>[].obs;

  // Camera-specific reactive variables
  var cameraControllerRx = Rx<CameraController?>(null);
  var isCameraInitialized = false.obs;
  var isDisposed = false;
  late CameraController cameraController;

  // --------------------------- CAMERA SETUP ---------------------------
  Future<void> initializeCamera() async {
    isCameraInitialized.value = false;
    try {
      final cameras = await availableCameras();
      final frontCam = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      // cameraControllerRx.value = CameraController(
      //   frontCam,
      //   ResolutionPreset.medium,
      //   enableAudio: false,
      // );

      cameraController = CameraController(
        frontCam,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // await cameraControllerRx.value!.initialize();
      await cameraController.initialize();
      cameraControllerRx.value = cameraController; // Set only after initialization

      isCameraInitialized.value = true;
      debugPrint("✅ Camera Initialized");
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
      Get.snackbar('Error', 'Failed to initialize camera: ${e.code}');
      isCameraInitialized.value = false;
    }
  }

  // --------------------------- CAPTURE IMAGE ---------------------------
  Future<String?> takePicture() async {
    // final controller = cameraControllerRx.value;
    if (!isCameraInitialized.value || cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile image = await cameraController.takePicture();
      return image.path;
    } catch (e) {
      debugPrint("Error taking picture: $e");
      return null;
    }
  }

  Future<String?> getPhoto() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        Get.defaultDialog(
          middleText: 'Please grant camera permission',
        );
        debugPrint('Camera permission denied');
        return null;
      }
    }

    if (Platform.isAndroid) {
      // Android uses CameraController; UI handles capture
      return null;
    } else {
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      if (photo != null) {
        await _processImage(photo);
        return photo.path;
      }
      return null;
    }
  }

  Future<void> _processImage(XFile photo) async {
    imagePath.value = photo.path;
    final bytes = await File(photo.path).readAsBytes();
    croppedImageFile.value = photo;
    croppedImageFiles.add(photo);
    base64img.value = base64.encode(bytes);

    debugPrint("✅ Captured image path: ${photo.path}");
    debugPrint("✅ Base64 length: ${base64img.value.length}");
  }

  Future<int> cropAndProcessImage(String? path) async {
    if (path == null) return 0;
    final photo = XFile(path);

    if (isDisposed || !(await File(photo.path).exists())) return 0;

    try {
      await _processImage(photo);
      return 1;
    } catch (e) {
      if (!isDisposed) {
        debugPrint("Error processing image: $e");
        Get.snackbar(
          'Alert!',
          "Error processing image: $e",
          overlayBlur: 2.0,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return 0;
    }
  }

  void clearCroppedImageFile() {
    croppedImageFile.value = null;
    croppedImageFiles.clear();
  }

  // --------------------------- LIFECYCLE ---------------------------
  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) {
      initializeCamera();
    }
  }

  @override
  void onClose() {
    isDisposed = true;
    cameraControllerRx.value?.dispose();
    super.onClose();
  }
}

// class CameraPageControllerForLowerVersions extends GetxController {
//   final ImagePicker picker = ImagePicker();
//   var base64img = ''.obs;
//   var imagePath = ''.obs;
//   var croppedImageFile = Rx<XFile?>(null);
//   var croppedImageFiles = <XFile>[].obs;
//
//   // ------------------------------------------------------------------
//   // Camera Package Variables (used for Android-specific camera handling)
//   // ------------------------------------------------------------------
//
//
//   var cameraController = Rx<CameraController?>(null); // MAKE IT REACTIVE
//   var cameraControllerRx = Rx<CameraController?>(null);
//
//
//   var isCameraInitialized = false.obs;
//   var isDisposed = false;
//   // ------------------------------------------------------------------
//
//   // Initializes the camera controller for the front camera
//   Future<void> initializeCamera() async {
//     isCameraInitialized.value = false;
//     try {
//       final cameras = await availableCameras();
//       final frontCam = cameras.firstWhere(
//               (camera) => camera.lensDirection == CameraLensDirection.front,
//           orElse: () => cameras[0]); // Fallback to first camera
//
//       cameraControllerRx.value = CameraController(
//         frontCam,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//       print("✅ Camera initializeCamera");
//
//       await cameraControllerRx.value!.initialize(); // Use .value! to access
//       // await cameraController!.initialize();
//       isCameraInitialized.value = true;
//       debugPrint("✅ Camera Initialized");
//       print("✅ Camera Initialized");
//     } on CameraException catch (e) {
//       print("Error initializing camera: $e");
//
//       debugPrint('Error initializing camera: $e');
//       // Handle permission denied or other errors
//       Get.snackbar('Error', 'Failed to initialize camera: ${e.code}');
//       isCameraInitialized.value = false;
//     }
//   }
//
//   // Captures the image using the initialized camera controller
//   Future<String?> takePicture() async {
//     if (!isCameraInitialized.value || cameraController.value == null || cameraController.value!.value.isTakingPicture) {
//       return null;
//     }
//     try {
//       final XFile image = await cameraController.value!.takePicture();
//       return image.path;
//     } catch (e) {
//       debugPrint("Error taking picture: $e");
//       return null;
//     }
//   }
//
//   // Handles both Android (using camera package) and iOS (using image_picker)
//   Future<String?> getPhoto() async {
//     var status = await Permission.camera.status;
//     if (!status.isGranted) {
//       status = await Permission.camera.request();
//       if (!status.isGranted) {
//         Get.defaultDialog(
//           middleText: 'Please grant camera permission for Location CheckIn',
//         );
//         debugPrint('Camera permission denied');
//         return null;
//       }
//     }
//
//     if (Platform.isAndroid) {
//       // For Android, we use the CameraPackage approach
//       // The view will handle the CameraController setup and use takePicture()
//       return null; // View handles the capture process
//     } else {
//       // For iOS, use the simple ImagePicker approach
//       final photo = await picker.pickImage(
//           source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
//
//       if (photo != null) {
//         // Automatically crop/encode if not Android
//         await _processImage(photo);
//         return photo.path;
//       }
//       return null;
//     }
//   }
//
//   // New utility function to process the captured image
//   Future<void> _processImage(XFile photo) async {
//     imagePath.value = photo.path;
//     // 🚫 No cropping for this case, directly read and encode image
//     final imageBytes = await File(photo.path).readAsBytes();
//     croppedImageFile.value = XFile(photo.path);
//     croppedImageFiles.add(XFile(photo.path));
//     base64img.value = base64.encode(imageBytes);
//
//     debugPrint("✅ Captured image path: ${photo.path}");
//     debugPrint("✅ Base64 length: ${base64img.value.length}");
//   }
//
//   // Function to crop the image (modified to accept XFile or String path)
//   Future<int> cropAndProcessImage(String? path) async {
//     if (path == null) return 0;
//
//     final photo = XFile(path);
//
//     if (isDisposed || !(await File(photo.path).exists())) {
//       return 0;
//     }
//     try {
//       // 🚫 Skipped cropping for simplicity based on your original logic
//       await _processImage(photo);
//
//       // Your original logic returned 1 on success
//       return 1;
//     } catch (e) {
//       if (!isDisposed) {
//         debugPrint("Error processing image: $e");
//         Get.snackbar(
//           'Alert!',
//           "Error processing image: $e",
//           overlayBlur: 2.0,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//       return 0;
//     }
//   }
//
//   void clearCroppedImageFile() {
//     croppedImageFile.value = null;
//     croppedImageFiles.clear();
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Initialize the camera only if running on Android
//     if (Platform.isAndroid) {
//       initializeCamera();
//     }
//   }
//
//   @override
//   void onClose() {
//     isDisposed = true;
//     // Dispose of the CameraController
//     if (cameraController.value != null) {
//       cameraController.value!.dispose();
//     }
//     super.onClose();
//   }
// }