// lib/app/ui/widgets/camera_scanner_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'tester_scan_controller.dart';

class CameraScannerWidget extends StatefulWidget {
  const CameraScannerWidget({super.key});

  @override
  State<CameraScannerWidget> createState() => _CameraScannerWidgetState();
}

class _CameraScannerWidgetState extends State<CameraScannerWidget> {
  final ScanController scanController = Get.find<ScanController>();
  final MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA],
    detectionSpeed: DetectionSpeed.normal,
  );
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        hasPermission = true;
      });
      await cameraController.start();
    } else {
      setState(() {
        hasPermission = false;
      });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (hasPermission)
              MobileScanner(
                controller: cameraController,
                onDetect: scanController.onBarcodeDetected,
              )
            else
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white54, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Camera permission required',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            // Overlay frame
            CustomPaint(
              painter: ScannerOverlayPainter(),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Position barcode within frame',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top right info
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '15 42',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final boxWidth = size.width * 0.7;
    final boxHeight = size.height * 0.5;
    
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: boxWidth,
      height: boxHeight,
    );
    
    canvas.drawRect(rect, paint);
    
    // Draw corner accents
    const cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Top-left
    canvas.drawLine(Offset(rect.left, rect.top + cornerLength), Offset(rect.left, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLength, rect.top), cornerPaint);
    
    // Top-right
    canvas.drawLine(Offset(rect.right, rect.top + cornerLength), Offset(rect.right, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right - cornerLength, rect.top), cornerPaint);
    
    // Bottom-left
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLength), Offset(rect.left, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLength, rect.bottom), cornerPaint);
    
    // Bottom-right
    canvas.drawLine(Offset(rect.right, rect.bottom - cornerLength), Offset(rect.right, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - cornerLength, rect.bottom), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}