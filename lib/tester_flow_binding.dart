// lib/app/bindings/home_binding.dart
import 'package:get/get.dart';
import 'package:hng_flutter/tester_product_controller.dart';
import 'package:hng_flutter/tester_scan_controller.dart';


class TestterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProductController());
    Get.put(ScanController());
  }
}