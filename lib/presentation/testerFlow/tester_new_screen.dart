import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/barcode_scanner_screen.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_models.dart';

class TesterNewScreen extends StatefulWidget {
  final bool showBackButton;
  const TesterNewScreen({super.key, this.showBackButton = true});

  @override
  State<TesterNewScreen> createState() => _TesterNewScreenState();
}

class _TesterNewScreenState extends State<TesterNewScreen> {
  late TesterController controller;
  final TextEditingController _eanController = TextEditingController();
  bool _isSearching = false;

  String _formatScanTime(DateTime timestamp) {
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    controller = Get.find<TesterController>();
    controller.refreshRecentScansForToday();
  }

  @override
  void dispose() {
    _eanController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndNavigate(String code, {bool isScanner = false}) async {
    final locationCode = controller.storeCode.value;
    if (locationCode.isEmpty) {
      Get.snackbar('Error', 'Please select a store location first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    await controller.fetchProductAndNavigate(code, locationCode,
        isScanner: isScanner, setLoading: (loading) {
      if (mounted) setState(() => _isSearching = loading);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
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
                          Expanded(
                            child: Row(
                              children: [
                                if (widget.showBackButton)
                                  const BackButton(
                                    color: Colors.white,
                                  ),
                                if (!widget.showBackButton)
                                  const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tester Availability",
                                        style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(() => Text(
                                            controller.locationName.value
                                                        .isNotEmpty ||
                                                    controller.storeCode.value
                                                        .isNotEmpty
                                                ? "${controller.locationName.value}${controller.locationName.value.isNotEmpty && controller.storeCode.value.isNotEmpty ? " " : ""}${controller.storeCode.value.isNotEmpty ? "(${controller.storeCode.value})" : ""}"
                                                : "No store selected",
                                            style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: Colors.white
                                                    .withOpacity(0.8)),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () async {
                                if (controller.storeCode.value.isEmpty) {
                                  Get.snackbar('Error',
                                      'Please select a store location first',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                  return;
                                }
                                // Navigate to scanner and handle result directly
                                final scannedCode = await Get.to<String>(() =>
                                    const BarcodeScannerScreen(
                                        title: 'Scan Product'));
                                if (scannedCode != null &&
                                    scannedCode.isNotEmpty) {
                                  // Show a loading dialog immediately to avoid seeing TesterNewScreen
                                  Get.dialog(
                                    const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF00A8A8),
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );
                                  // Instead of returning to TesterNewScreen, fetch and navigate directly
                                  await controller.fetchProductAndNavigate(
                                    scannedCode,
                                    controller.storeCode.value,
                                    isScanner: true,
                                    setLoading: (loading) {
                                      // We can't update state here since this screen might be in background
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF00A8A8),
                                    Color(0xFF00C9C9)
                                  ]),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFF00A8A8)
                                            .withOpacity(0.4),
                                        blurRadius: 30,
                                        offset: const Offset(0, 8))
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("📷",
                                        style: TextStyle(fontSize: 40)),
                                    const SizedBox(height: 5),
                                    Text("SCAN",
                                        style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _eanController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (val) async {
                                      if (val.trim().isNotEmpty) {
                                        _fetchAndNavigate(val.trim());
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Enter EAN / SKU Code",
                                      hintStyle: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: const Color(0xFF94A3B8)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0))),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0))),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isSearching
                                      ? null
                                      : () async {
                                          final val =
                                              _eanController.text.trim();
                                          if (val.isNotEmpty) {
                                            _eanController.clear();
                                            _fetchAndNavigate(val);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A5F),
                                    disabledBackgroundColor:
                                        const Color(0xFF1E3A5F)
                                            .withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  child: _isSearching
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : Text("Go",
                                          style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Visibility(
                                visible: true,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Recent Scans",
                                            style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF64748B),
                                                letterSpacing: 0.5)),
                                        Obx(() => Text(
                                            "Today: ${controller.todayScans.value}",
                                            style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    const Color(0xFF00A8A8)))),
                                      ],
                                    ),
                                    // const SizedBox(height: 12),
                                    Obx(() => controller.recentScans.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Text('No scans for today.',
                                                style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: const Color(
                                                        0xFF94A3B8))),
                                          )
                                        : ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                controller.recentScans.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 6),
                                            itemBuilder: (context, index) {
                                              final item =
                                                  controller.recentScans[index];
                                              // Get product name initials
                                              String getInitials(String name) {
                                                if (name.isEmpty) return '';
                                                final words = name
                                                    .trim()
                                                    .split(RegExp(r'\s+'));
                                                final initials = words
                                                    .take(2)
                                                    .map((word) => word
                                                            .isNotEmpty
                                                        ? word[0].toUpperCase()
                                                        : '')
                                                    .join('');
                                                return initials.isNotEmpty
                                                    ? initials
                                                    : 'N/A';
                                              }

                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color:
                                                              Color(0x0F000000),
                                                          blurRadius: 8,
                                                          offset: Offset(0, 2))
                                                    ]),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFF00A8A8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                          getInitials(
                                                              item.name),
                                                          style: GoogleFonts
                                                              .outfit(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          )),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(item.sku,
                                                              style: GoogleFonts.outfit(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: const Color(
                                                                      0xFF1E3A5F))),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(item.name,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.outfit(
                                                                  fontSize: 12,
                                                                  color: const Color(
                                                                      0xFF64748B))),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                              'Scanned at ${_formatScanTime(item.timestamp)}',
                                                              style: GoogleFonts.outfit(
                                                                  fontSize: 11,
                                                                  color: const Color(
                                                                      0xFF94A3B8))),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )),
                                    const SizedBox(height: 8),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
