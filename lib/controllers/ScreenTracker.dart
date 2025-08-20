import 'package:get/get.dart';

class ScreenTracker extends GetxController {
  var activeScreen = "".obs;
}

final screenTracker = Get.put(ScreenTracker());
