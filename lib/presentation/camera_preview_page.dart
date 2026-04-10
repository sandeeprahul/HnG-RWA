import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraPreviewPage extends StatefulWidget {
  final String imagePath;
  final String storeName;
  final String mallName;
  final String locationCoords;
  final String dateTime;
  final String floorBay;

  const CameraPreviewPage({
    Key? key,
    required this.imagePath,
    required this.storeName,
    required this.mallName,
    required this.locationCoords,
    required this.dateTime,
    required this.floorBay,
  }) : super(key: key);

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  bool isCropMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          "Preview & Save",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: IconButton(
                icon: const Icon(Icons.content_cut, color: Colors.white, size: 18),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // The captured image
                  Positioned.fill(
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Viewfinder-like brackets
                  _buildBrackets(),

                  // Yellow Information Overlay (Exact Design)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.store, "${widget.storeName.toUpperCase()} — ${widget.mallName.toUpperCase()}"),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.location_on, widget.locationCoords),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.access_time, "${widget.dateTime}   |   ${widget.floorBay}"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Controls Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Auto-stamp applied",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Crop mode",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isCropMode,
                          onChanged: (val) => setState(() => isCropMode = val),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("↶ Retake", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Return final path or success
                          Get.back(result: widget.imagePath); // For now returning path
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Save & Next →", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontFamily: 'monospace', // To give it that technical/stamp look
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrackets() {
    return Stack(
      children: [
        Positioned(top: 20, left: 20, child: _bracket(top: true, left: true)),
        Positioned(top: 20, right: 20, child: _bracket(top: true, right: true)),
        Positioned(bottom: 120, left: 20, child: _bracket(bottom: true, left: true)),
        Positioned(bottom: 120, right: 20, child: _bracket(bottom: true, right: true)),
      ],
    );
  }

  Widget _bracket({bool top = false, bool bottom = false, bool left = false, bool right = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
          right: right ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        ),
      ),
    );
  }
}
