import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/scanner_screen.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_models.dart';

class TesterNewScreen extends StatelessWidget {
  TesterNewScreen({super.key});

  final TesterController controller = Get.put(TesterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // App Header (gradient)
            Container(
              // color: Colors.deepOrange,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(10, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Menu icon (three lines)
                      BackButton(
                        color: Colors.white,
                      ),
                      // const SizedBox(width: 12),
                      Text(
                        "Tester Availability",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: Color(0xFF00A8A8), shape: BoxShape.circle),
                    child: const Center(
                        child: Text("JS",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  ),
                ],
              ),
            ),
            // Home Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Store badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(20)),
                      child: Obx(() => Text(
                          "📍 Store: ${controller.storeCode.value}",
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0369A1)))),
                    ),
                    const SizedBox(height: 20),
                    // Scan Button (navigates to Scanner)
                    GestureDetector(
                      onTap: () => Get.to(() => const ScannerScreen()),
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
                    // Manual input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Enter EAN Code",
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
                          onPressed: () {
                            // Manual entry logic – for now, navigate to scanner or show snackbar
                            Get.snackbar("Manual Entry", "Feature coming soon",
                                snackPosition: SnackPosition.BOTTOM);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: Text("Go",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Recent scans section
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
                    Obx(() => SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.recentScans.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final item = controller.recentScans[index];
                              return Container(
                                width: 100,
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
                    // Stats row
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
    );
  }
}
