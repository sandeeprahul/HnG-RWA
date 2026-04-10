import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CamOverlayController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isCapturing = false.obs;
  var flashMode = FlashMode.off.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        try {
          await cameraController!.initialize();
          isCameraInitialized.value = true;
          // Set initial flash mode
          await cameraController!.setFlashMode(flashMode.value);
        } catch (e) {
          print("Error initializing camera: $e");
        }
      }
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    if (flashMode.value == FlashMode.off) {
      flashMode.value = FlashMode.always;
    } else if (flashMode.value == FlashMode.always) {
      flashMode.value = FlashMode.auto;
    } else {
      flashMode.value = FlashMode.off;
    }

    try {
      await cameraController!.setFlashMode(flashMode.value);
    } catch (e) {
      print("Error setting flash mode: $e");
    }
  }

  Future<XFile?> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }
    try {
      isCapturing.value = true;
      final XFile file = await cameraController!.takePicture();
      isCapturing.value = false;
      return file;
    } catch (e) {
      isCapturing.value = false;
      print("Error capturing photo: $e");
      return null;
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
