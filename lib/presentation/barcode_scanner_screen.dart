import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final String title;
  const BarcodeScannerScreen({super.key, this.title = 'Scan Barcode'});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  // Initialized the controller
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Torch Toggle
          ValueListenableBuilder(
            valueListenable: cameraController, // Fixed identifier
            builder: (context, state, child) {
              return IconButton(
                color: Colors.white,
                iconSize: 32.0,
                onPressed: () => cameraController.toggleTorch(),
                icon: Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: state == TorchState.on ? Colors.yellow : Colors.white,
                ),
              );
            },
          ),
          // Camera Facing Toggle
          ValueListenableBuilder(
            valueListenable: cameraController, // Fixed identifier
            builder: (context, state, child) {
              return IconButton(
                color: Colors.white,
                iconSize: 32.0,
                onPressed: () => cameraController.switchCamera(),
                icon: Icon(
                  state == CameraFacing.front ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            overlayBuilder: (context, constraints) {
              return ScanningAnimation(constraints: constraints);
            },
            onDetect: (capture) {
              if (isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    isScanned = true;
                  });
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          // Custom Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Align barcode within the frame',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ScanningAnimation extends StatefulWidget {
  final BoxConstraints constraints;
  const ScanningAnimation({super.key, required this.constraints});

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Moves line down, then back up
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the scanning area (e.g., 250x250)
    double scanAreaSize = 250.0;

    return Stack(
      children: [
        // 1. Semi-transparent background with a hole in the middle
        ColorFiltered(
          // overlayColor: Colors.black.withOpacity(0.5),
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut, // Use srcOut to "punch" a hole through the color
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
            child: Center(
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        // 2. The Animated Red Line
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (scanAreaSize * _controller.value) - (scanAreaSize / 2)),
                child: Container(
                  width: scanAreaSize,
                  height: 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        // 3. Border Frame
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class BarcodeScannerScreen extends StatefulWidget {
//   final String title;
//   const BarcodeScannerScreen({super.key, this.title = 'Scan Barcode'});
//
//   @override
//   State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
// }
//
// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController(
//     detectionSpeed: DetectionSpeed.noDuplicates,
//     facing: CameraFacing.back,
//     torchEnabled: false,
//   );
//
//   bool isScanned = false;
//
//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title, style: GoogleFonts.outfit(color: Colors.white)),
//         backgroundColor: Colors.orange,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             color: Colors.white,
//             icon: ValueListenableBuilder(
//               valueListenable: cameraController.,
//               builder: (context, state, child) {
//                 switch (state) {
//                   case TorchState.off:
//                     return const Icon(Icons.flash_off, color: Colors.white);
//                   case TorchState.on:
//                     return const Icon(Icons.flash_on, color: Colors.yellow);
//                 }
//               },
//             ),
//             iconSize: 32.0,
//             onPressed: () => cameraController.toggleTorch(),
//           ),
//           IconButton(
//             color: Colors.white,
//             icon: ValueListenableBuilder(
//               valueListenable: cameraController.facing,
//               builder: (context, state, child) {
//                 switch (state) {
//                   case CameraFacing.front:
//                     return const Icon(Icons.camera_front, color: Colors.white);
//                   case CameraFacing.back:
//                     return const Icon(Icons.camera_rear, color: Colors.white);
//                 }
//               },
//             ),
//             iconSize: 32.0,
//             onPressed: () => cameraController.switchCamera(),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (capture) {
//               if (isScanned) return;
//
//               final List<Barcode> barcodes = capture.barcodes;
//               for (final barcode in barcodes) {
//                 debugPrint('Barcode found! ${barcode.rawValue}');
//                 if (barcode.rawValue != null) {
//                   setState(() {
//                     isScanned = true;
//                   });
//                   Navigator.pop(context, barcode.rawValue);
//                   break;
//                 }
//               }
//             },
//           ),
//           // Custom Overlay
//           Center(
//             child: Container(
//               width: 250,
//               height: 250,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.orange, width: 4),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Align barcode within the frame',
//                   style: GoogleFonts.outfit(color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
