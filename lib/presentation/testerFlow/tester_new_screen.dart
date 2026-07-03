import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/scanner_screen.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_models.dart';
import 'package:hng_flutter/widgets/location_search_dialog.dart';

class TesterNewScreen extends StatefulWidget {
  const TesterNewScreen({super.key});

  @override
  State<TesterNewScreen> createState() => _TesterNewScreenState();
}

class _TesterNewScreenState extends State<TesterNewScreen> {
  late TesterController controller;
  final TextEditingController _eanController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    controller = Get.find<TesterController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureLocationSelected();
    });
  }

  @override
  void dispose() {
    _eanController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndNavigate(String code) async {
    final locationCode = controller.storeCode.value;
    await controller.fetchProductAndNavigate(code, locationCode, setLoading: (loading) {
      if (mounted) setState(() => _isSearching = loading);
    });
  }

  Future<void> _showLocationDialog() async {
    await controller.loadUserCode();
    if (!mounted) return;
    final userCode = controller.userCode.value;
    final selectedLocation = await showDialog(
      context: context,
      builder: (context) => LocationSearchDialog(userId: userCode),
    );
    if (selectedLocation != null) {
      await controller.updateLocation(
        selectedLocation['locationCode'] ?? '',
        selectedLocation['locationName'] ?? '',
      );
    }
  }

  Future<bool> _ensureLocationSelected() async {
    await controller.loadFromPrefs();
    if (mounted && controller.storeCode.value.isEmpty) {
      // Attendance-style handling: auto-select if exactly one location is returned.
      if (await controller.fetchAndAutoSelectLocation()) {
        return true;
      }
      await _showLocationDialog();
    }
    return controller.storeCode.value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return  AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Make status bar transparent to show gradient
          statusBarIconBrightness: Brightness.light, // White icons
          statusBarBrightness: Brightness.dark, // For iOS
        ),
        child:Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(10, 56, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const BackButton(color: Colors.white),
                      Text(
                        "Tester Availability",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  // Obx(() {
                  //   final initials = controller.userCode.value.isNotEmpty
                  //       ? controller.userCode.value
                  //           .substring(
                  //               0, controller.userCode.value.length.clamp(0, 2))
                  //           .toUpperCase()
                  //       : '?';
                  //   return Container(
                  //     width: 32,
                  //     height: 32,
                  //     decoration: const BoxDecoration(
                  //         color: Color(0xFF00A8A8), shape: BoxShape.circle),
                  //     child: Center(
                  //         child: Text(initials,
                  //             style: const TextStyle(
                  //                 fontSize: 11,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: Colors.white))),
                  //   );
                  // }),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Location chip — tappable to change
                    GestureDetector(
                      onTap: _showLocationDialog,
                      child: Obx(() => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF0369A1)
                                        .withOpacity(0.3))),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xFF0369A1), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.locationName.value.isNotEmpty
                                        ? '${controller.locationName.value} (${controller.storeCode.value})'
                                        : 'Tap to select store location',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0369A1)),
                                  ),
                                ),
                                const Icon(Icons.edit,
                                    color: Color(0xFF0369A1), size: 16),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 20),
                    // Scan Button
                    GestureDetector(
                      onTap: () async {
                        if (await _ensureLocationSelected()) {
                          Get.to(() => const ScannerScreen());
                        }
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF00A8A8), Color(0xFF00C9C9)]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF00A8A8).withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 8))
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("📷", style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 5),
                            Text("SCAN",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Manual EAN entry
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _eanController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (val) async {
                              if (val.trim().isNotEmpty) {
                                if (await _ensureLocationSelected()) {
                                  _fetchAndNavigate(val.trim());
                                }
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Enter EAN / SKU Code",
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 14, color: const Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0))),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSearching
                              ? null
                              : () async {
                                  final val = _eanController.text.trim();
                                  if (val.isNotEmpty) {
                                    if (await _ensureLocationSelected()) {
                                      _fetchAndNavigate(val);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            disabledBackgroundColor:
                                const Color(0xFF1E3A5F).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: _isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text("Go",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Recent Scans
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Recent Scans",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() => controller.recentScans.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('No scans yet today.',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF94A3B8))),
                          )
                        : SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.recentScans.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final item = controller.recentScans[index];
                                return Container(
                                  width: 110,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0x14000000),
                                            blurRadius: 8)
                                      ]),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(item.sku,
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1E3A5F))),
                                      const SizedBox(height: 3),
                                      Text(item.name,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFF64748B))),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 120),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 8)
                      ]),
                  child: Column(
                    children: [
                      Obx(() => Text("${controller.todayScans.value}",
                          style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3A5F)))),
                      const SizedBox(height: 2),
                      Text("Today's Scans",
                          style: GoogleFonts.inter(
                              fontSize: 10, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 8)
                      ]),
                  child: Column(
                    children: [
                      Obx(() => Text("${controller.productsUpdated.value}",
                          style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3A5F)))),
                      const SizedBox(height: 2),
                      Text("Products Updated",
                          style: GoogleFonts.inter(
                              fontSize: 10, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
