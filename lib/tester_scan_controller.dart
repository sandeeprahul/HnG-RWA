// lib/app/controllers/scan_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'tester_product_controller.dart';

class ScanController extends GetxController {
  final ProductController productController = Get.find<ProductController>();
  final RxBool isScanning = true.obs;
  final RxString lastScannedBarcode = ''.obs;

  void onBarcodeDetected(BarcodeCapture capture) {
    if (!isScanning.value) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code != lastScannedBarcode.value) {
        lastScannedBarcode.value = code;
        _processBarcode(code);
        Future.delayed(const Duration(seconds: 2), () {
          if (lastScannedBarcode.value == code) lastScannedBarcode.value = '';
        });
      }
    }
  }

  void _processBarcode(String barcode) {
    final found = productController.updateProductByBarcode(barcode);
    productController.addScanRecord(barcode);
    Get.snackbar(
      found ? 'Product Updated' : 'Scanned',
      found ? '$barcode → Available' : 'No matching product for $barcode',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: found ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
  }

  void manualEANSubmit(String ean) {
    if (ean.trim().isEmpty) {
      Get.snackbar('Error', 'Enter an EAN code', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final found = productController.updateProductByBarcode(ean);
    productController.addScanRecord(ean);
    Get.snackbar(
      found ? 'Product Updated' : 'Scanned',
      found ? '$ean → Available' : 'No product for $ean',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: found ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
  }
}