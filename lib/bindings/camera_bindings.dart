import 'package:get/get.dart';

import '../controllers/camerapageController.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraPageController>(() => CameraPageController());
  }
}
