// success_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_models.dart';

class SuccessScreen extends StatelessWidget {
  final List<ChildProduct> updatedProducts;

  const SuccessScreen({super.key, required this.updatedProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar placeholder (matches previous screens)
            const SizedBox(height: 8),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    // Animated success icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF22C55E).withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.check,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Success!",
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tester availability updated",
                      style: GoogleFonts.outfit(
                          fontSize: 14, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 10,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "UPDATED PRODUCTS",
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 10),
                          ...updatedProducts.map((product) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Color(0xFF22C55E), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${product.sku} - ${product.name}",
                                        style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            color: const Color(0xFF334155)),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          if (updatedProducts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "No products were updated",
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Pop back to TesterNewScreen
                      Get.back(); // Pop SuccessScreen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A5F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      shadowColor: const Color(0xFF1E3A5F).withOpacity(0.3),
                    ),
                    child: Text("📷 Scan Next Product",
                        style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Pop back to TesterNewScreen
                      Get.back(); // Pop SuccessScreen
                    },
                    child: Text("Return to Home",
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: const Color(0xFF64748B))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
