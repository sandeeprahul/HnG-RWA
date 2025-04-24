import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class CameraPageController extends GetxController {
  final ImagePicker picker = ImagePicker(); // Use ImagePicker for capturing photos
  var base64img = ''.obs; // Observable for the base64 image
  var camVisible = false.obs; // Observable for camera visibility
  var imagePath = ''.obs;
  var croppedImageFile = Rx<XFile?>(null); // Observable for cropped image
  var croppedImageFiles = <XFile>[].obs;


  var cameraOpen = false.obs; // Flag to track camera open status

  // Use ImagePicker to pick an image from the camera
  Future<void> captureAndCropImage() async {
    try {
      // Show camera preview and allow capturing image
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null&& await File(photo.path).exists()) {
        await Future.delayed(const Duration(milliseconds: 300));

        imagePath.value = photo.path;
        camVisible.value = false; // Hide camera preview after capture

        await _cropImage(photo); // Crop the image after capture
        Get.back(); // Go back after capturing the image
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  // Function to crop the image
  Future<void> _cropImage(XFile? photo) async {
    if (photo == null || !(await File(photo.path).exists())) return;

    try{
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: Platform.isAndroid ? photo.path : photo.path,
          compressFormat: ImageCompressFormat.jpg,

          maxWidth: 1920,
          maxHeight: 1080,
          compressQuality: 50,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
          ],
        );

        if (croppedFile != null) {
          final imageBytes = await File(croppedFile.path).readAsBytes();
          croppedImageFile.value = XFile(croppedFile.path);
          croppedImageFiles.add(XFile(croppedFile.path)); // Add to the list
          base64img.value = base64.encode(imageBytes); // Update base64 image
          print("Base64 Image: ${base64img.value}");
        }
      }catch(e){
        Get.snackbar('Alert!', "Error:$e",overlayBlur: 2.0,backgroundColor: Colors.red,colorText: Colors.white);
      }


  }

  void clearCroppedImageFile() {
    croppedImageFile.value = null; // Set the value to null
    croppedImageFiles.clear();

  }
  @override
  void onClose() {
    super.onClose();
  }
}
