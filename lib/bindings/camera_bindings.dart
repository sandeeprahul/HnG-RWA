import 'package:get/get.dart';
import 'package:hng_flutter/new_camera_handling_for_lower_version/cameraPageControllerForLowerVersions.dart';

import '../controllers/camerapageController.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraPageController>(() => CameraPageController());
    Get.lazyPut<CameraPageControllerForLowerVersions>(() => CameraPageControllerForLowerVersions());
  }
}
