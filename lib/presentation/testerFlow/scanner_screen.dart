import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'tester_models.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically start scanning when the screen is pushed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanProduct();
    });
  }

  Future<void> _scanProduct() async {
    // Use the same QR scanning logic as in ProductQuickEnquiryPage
    String? scannedCode = await goToQrPage("your-phone-number");
    
    // SimpleBarcodeScanner returns "-1" if the user cancels
    if (scannedCode != null && scannedCode != "-1" && scannedCode.isNotEmpty) {
      _fetchProductAndNavigate(scannedCode);
    } else {
      // If cancelled or empty, go back to the previous screen
      Get.back();
    }
  }

  // Implementation copied from ProductQuickEnquiryPage
  Future<String?> goToQrPage(String phone) async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'HnG RWA',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );

    return res;
  }

  Future<void> _fetchProductAndNavigate(String code) async {
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    final testerController = Get.find<TesterController>();
    await testerController.loadFromPrefs();
    final locationCode = testerController.storeCode.value;
    
    if (locationCode.isEmpty) {
      Get.back(); // Pop the ScannerScreen
      Get.snackbar('No Location', 'Please select a store location first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    
    // Call the tester flow navigation logic which handles product fetching and navigation
    await testerController.fetchProductAndNavigate(code, locationCode, isScanner: true);
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loader while the scanner is being presented
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00A8A8),
        ),
      ),
    );
  }
}
