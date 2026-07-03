// scanner_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'child_products_screen.dart';
import 'tester_models.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isTorchOn = false;
  bool _isPermissionGranted = false;
  bool _isScanning = true;
  bool _isPaused = false;
  bool _showSuccess = false;
  String _scannedValue = '';
  Timer? _autoStopTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInitialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isPaused && _isScanning && mounted) {
        _controller?.start();
      }
    } else if (state == AppLifecycleState.paused) {
      _controller?.stop();
    }
  }

  Future<void> _resumeScanning() async {
    if (_controller == null) return;
    setState(() {
      _isPaused = false;
      _isScanning = true;
    });
    try {
      await _controller?.start();
    } catch (e) {
      debugPrint('Resume scanner error: $e');
    }
    // Restart auto-stop timer
    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(const Duration(seconds: 15), () {
      if (_isScanning && mounted) {
        _controller?.stop();
        _isScanning = false;
        _isPaused = true;
        setState(() {});
      }
    });
  }

  Future<void> _checkPermissionAndInitialize() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _isPermissionGranted = true);
      _controller = MobileScannerController(
        autoStart: false,
        detectionSpeed: DetectionSpeed.normal,
        formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA],
      );
      // Auto-stop after 15 seconds of no scan to save battery
      _autoStopTimer = Timer(const Duration(seconds: 15), () {
        if (_isScanning && mounted) {
          _controller?.stop();
          _isScanning = false;
          _isPaused = true;
          setState(() {});
        }
      });
      // Start once after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted && _controller != null) {
          try {
            await _controller?.start();
          } catch (e) {
            debugPrint("Scanner start error: $e");
          }
        }
      });
    } else {
      // Permission denied – show error
      Get.snackbar(
          'Camera Permission', 'Camera access is required to scan barcodes.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      Future.delayed(const Duration(seconds: 2), () => Get.back());
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcode = capture.barcodes.first;
    final scannedValue = barcode.rawValue;
    if (scannedValue != null && scannedValue.isNotEmpty) {
      _isScanning = false;
      _autoStopTimer?.cancel();
      _controller?.stop();
      HapticFeedback.lightImpact();
      setState(() {
        _scannedValue = scannedValue;
        _showSuccess = true;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _fetchProductAndNavigate(scannedValue);
        }
      });
    }
  }

  Future<void> _fetchProductAndNavigate(String code) async {
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    final testerController = Get.find<TesterController>();
    await testerController.loadFromPrefs();
    final locationCode = testerController.storeCode.value;
    if (locationCode.isEmpty) {
      Get.back();
      Get.snackbar('No Location', 'Please select a store location first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    await testerController.fetchProductAndNavigate(code, locationCode, isScanner: true);
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  void _closeScanner() {
    _autoStopTimer?.cancel();
    try {
      _controller?.stop();
    } catch (e) {
      debugPrint('Scanner stop error: $e');
    }
    Get.back();
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Camera permission required',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissionAndInitialize,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8A8)),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _autoStopTimer?.cancel();
          try {
            _controller?.stop();
          } catch (e) {
            debugPrint('Scanner pop stop error: $e');
          }
        }
      },
      child: Scaffold(
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          // Scanning overlay frame
          _buildScannerOverlay(),
          // Top buttons: close and flashlight
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: _closeScanner,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: _toggleTorch,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle),
                child: Icon(
                  _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Instruction text at bottom
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: () {},
              child: Text(
                'Position barcode within frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54)
                    ]),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Supports EAN-13, EAN-8, UPC-A',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ),
          if (_isPaused && !_showSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pause_circle_filled,
                          color: Colors.white, size: 64),
                      const SizedBox(height: 16),
                      Text('Scanner paused to save battery',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _resumeScanning,
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text('Resume Scanning',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A8A8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Success overlay - API loading
          if (_showSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Product Found!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SKU: $_scannedValue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(
                        color: Color(0xFF00A8A8),
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  Widget _buildScannerOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(),
      child: Container(),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final scanWidth = 220.0;
    final scanHeight = 140.0;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanWidth,
      height: scanHeight,
    );
    // Draw dark overlay outside the scan area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, rect.top), paint);
    canvas.drawRect(Rect.fromLTWH(0, rect.top, rect.left, rect.height), paint);
    canvas.drawRect(
        Rect.fromLTWH(
            rect.right, rect.top, size.width - rect.right, rect.height),
        paint);
    canvas.drawRect(
        Rect.fromLTWH(0, rect.bottom, size.width, size.height - rect.bottom),
        paint);

    // Draw the corners
    final cornerPaint = Paint()
      ..color = const Color(0xFF00A8A8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const cornerLength = 30.0;
    // Top-left
    canvas.drawLine(Offset(rect.left, rect.top),
        Offset(rect.left + cornerLength, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.top),
        Offset(rect.left, rect.top + cornerLength), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(rect.right, rect.top),
        Offset(rect.right - cornerLength, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.top),
        Offset(rect.right, rect.top + cornerLength), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(rect.left, rect.bottom),
        Offset(rect.left + cornerLength, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom),
        Offset(rect.left, rect.bottom - cornerLength), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(rect.right, rect.bottom),
        Offset(rect.right - cornerLength, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom),
        Offset(rect.right, rect.bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
