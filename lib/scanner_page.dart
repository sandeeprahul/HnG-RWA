import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/tester_scan_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ScanController scanController = Get.find();
  final MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA],
    detectionSpeed: DetectionSpeed.normal,
  );
  final TextEditingController eanController = TextEditingController();
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => hasPermission = true);
      await cameraController.start();
    } else {
      setState(() => hasPermission = false);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    eanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back())),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    if (hasPermission)
                      MobileScanner(controller: cameraController, onDetect: scanController.onBarcodeDetected)
                    else
                      Container(color: Colors.black87, child: const Center(child: Text('Camera permission needed', style: TextStyle(color: Colors.white)))),
                    CustomPaint(painter: ScannerOverlayPainter(), child: Container()),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Position barcode within frame', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                    const Positioned(top: 12, right: 12, child: Text('15 42', style: TextStyle(color: Colors.white54, fontSize: 10))),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: eanController,
                        decoration: const InputDecoration(hintText: 'Enter EAN Code', prefixIcon: Icon(Icons.qr_code)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: () => scanController.manualEANSubmit(eanController.text.trim()), child: const Text('Go')),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Supports EAN-13, EAN-8, UPC-A', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height / 2);
    final box = Rect.fromCenter(center: center, width: size.width * 0.7, height: size.height * 0.5);
    canvas.drawRect(box, paint);

    final cornerPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3;
    const cl = 20.0;
    canvas.drawLine(Offset(box.left, box.top + cl), Offset(box.left, box.top), cornerPaint);
    canvas.drawLine(Offset(box.left, box.top), Offset(box.left + cl, box.top), cornerPaint);
    canvas.drawLine(Offset(box.right, box.top + cl), Offset(box.right, box.top), cornerPaint);
    canvas.drawLine(Offset(box.right, box.top), Offset(box.right - cl, box.top), cornerPaint);
    canvas.drawLine(Offset(box.left, box.bottom - cl), Offset(box.left, box.bottom), cornerPaint);
    canvas.drawLine(Offset(box.left, box.bottom), Offset(box.left + cl, box.bottom), cornerPaint);
    canvas.drawLine(Offset(box.right, box.bottom - cl), Offset(box.right, box.bottom), cornerPaint);
    canvas.drawLine(Offset(box.right, box.bottom), Offset(box.right - cl, box.bottom), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}