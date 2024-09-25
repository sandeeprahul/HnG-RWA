import 'package:get/get.dart';
import 'package:hng_flutter/loginController.dart';

class loginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => loginController());
  }
}
