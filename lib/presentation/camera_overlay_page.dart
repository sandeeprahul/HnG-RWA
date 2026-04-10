import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../controllers/cam_overlay_controller.dart';
import '../helper/image_timestamp_helper.dart';
import 'camera_preview_page.dart';

class CameraOverlayPage extends StatefulWidget {
  final String floorBay;
  final String storeName;
  final String mallName;

  const CameraOverlayPage({
    Key? key,
    required this.floorBay,
    required this.storeName,
    required this.mallName,
  }) : super(key: key);

  @override
  State<CameraOverlayPage> createState() => _CameraOverlayPageState();
}

class _CameraOverlayPageState extends State<CameraOverlayPage> {
  final CamOverlayController controller = Get.put(CamOverlayController());
  
  // Location & Time state (from cam_help_page)
  String _locationString = "Fetching location...";
  StreamSubscription<Position>? _positionStream;
  String _currentDateTime = "";
  final int _currentStep = 4;
  final int _totalSteps = 138;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _initLocationService();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    _currentDateTime = DateFormat("dd MMM yyyy, hh:mm a").format(now);
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now());
        });
      }
    });
  }

  Future<void> _initLocationService() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _locationString = "${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E";
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        return Stack(
          children: [
            // 1. Full Camera Preview
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: controller.cameraController!.value.aspectRatio,
                child: CameraPreview(controller.cameraController!),
              ),
            ),

            // 2. UI Overlay (Copied and adapted from cam_help_page)
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const Spacer(),
                  _buildViewfinderBrackets(),
                  const Spacer(),
                  _buildBottomInfo(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _RequirementChip(
                          icon: Icons.check_circle_outline,
                          label: "Ensure full fixture visible",
                        ),
                        _RequirementChip(
                          icon: Icons.wb_sunny_outlined,
                          label: "Good lighting",
                        ),
                        _RequirementChip(
                          icon: Icons.blur_off,
                          label: "No blur",
                        ),
                      ],
                    ),
                  ),

                  _buildCaptureControls(),
                ],
              ),
            ),
            
            // Loading Overlay when capturing
            if (controller.isCapturing.value)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16,right: 16),
      child: Column(
        children: [
          Row(
            children: [

              CustomCircleButton(
                icon: Icons.close,
                onPressed: () => Get.back(),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      "${widget.floorBay} — Cosmetics",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Step $_currentStep of $_totalSteps · Cosmetics",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => CustomCircleButton(
                icon: _getFlashIcon(controller.flashMode.value),
                onPressed: () => controller.toggleFlash(),
                iconColor: const Color(0xffFFD700),
              )),

            ],
          ),


        ],
      ),
    );
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.auto:
        return Icons.flash_auto;
      default:
        return Icons.flash_off;
    }
  }

  Widget _buildViewfinderBrackets() {
    return Container(
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // Corner brackets
          Positioned(top: 0, left: 0, child: _bracket(top: 2, left: 2)),
          Positioned(top: 0, right: 0, child: _bracket(top: 2, right: 2)),
          Positioned(bottom: 0, left: 0, child: _bracket(bottom: 2, left: 2)),
          Positioned(bottom: 0, right: 0, child: _bracket(bottom: 2, right: 2)),


          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.shelves,
                  size: 28,
                  color: Colors.white.withOpacity(0.3),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Point camera at\n",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      TextSpan(
                        text: "${widget.floorBay} — Cosmetics",
                        style: const TextStyle(
                          color: Colors.white, // Highlight the variable with full opacity
                          fontSize: 18,        // Optionally make it slightly larger
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bracket({double? top, double? bottom, double? left, double? right}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          bottom: bottom != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          left: left != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          right: right != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 14),
              const SizedBox(width: 8),
              Text(
                "Auto-stamp: ${widget.storeName} · ${widget.mallName}",
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 14),
              const SizedBox(width: 8),
              Text(_locationString, style: const TextStyle(color: Colors.white, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.access_time, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(_currentDateTime, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32,horizontal: 16),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() => CustomCircleButton(
            icon: _getFlashIcon(controller.flashMode.value),
            onPressed: () => controller.toggleFlash(),
            iconColor: const Color(0xffFFD700),
          )),

          Expanded(
            child: GestureDetector(
              onTap: () async {
                XFile? photo = await controller.capturePhoto();

                if (photo != null) {
                  // Add the permanent timestamp to the image file
                  String? stampedPath = await ImageTimestampHelper.addTimestampToImage(
                    imagePath: photo.path,
                    storeName: widget.storeName,
                    mallName: widget.mallName,
                    locationCoords: _locationString,
                  );

                  // Navigate to the Preview & Save screen
                  final result = await Get.to(() => CameraPreviewPage(
                    imagePath: stampedPath ?? photo.path,
                    storeName: widget.storeName,
                    mallName: widget.mallName,
                    locationCoords: _locationString,
                    dateTime: _currentDateTime,
                    floorBay: widget.floorBay,
                  ));

                  // If user clicked "Save & Next" in the preview screen, return the result
                  if (result != null) {
                    Get.back(result: result);
                  }
                }
              },
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          CustomCircleButton(
            icon: Icons.refresh,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
class _RequirementChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RequirementChip({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.6),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class CustomCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final double iconSize;
  final Color backgroundColor;

  const CustomCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.iconSize = 26.0,
    this.backgroundColor = const Color(0x4EFFFFFF), // Equivalent to white70 with alpha 78
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
