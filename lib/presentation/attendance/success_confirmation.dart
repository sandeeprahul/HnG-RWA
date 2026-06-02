// screen5_success_confirmation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'attendanceNewController.dart';

// Controller to hold submitted summary data (can be populated after API response)
class ConfirmationController extends GetxController {
  // H&G Staff summary
  final hgTotal = 18.obs;
  final hgPresent = 15.obs;
  final hgAbsent = 3.obs;

  // BA Staff summary
  final baTotal = 24.obs;
  final baPresent = 21.obs;
  final baAbsent = 3.obs;

  // Submitted by info
  final submittedByName = "Rohan Verma".obs;
  final submittedByRole = "Store Manager".obs;
  final storeName = "Koramangala".obs;

  // Submission timestamp
  final submissionTime = "10:50 AM".obs;
  final submissionDate = "Saturday, 30 May 2026".obs;

  // Method to update summary (call this after API success)
  void setSummary({
    required int hgTotalVal,
    required int hgPresentVal,
    required int hgAbsentVal,
    required int baTotalVal,
    required int baPresentVal,
    required int baAbsentVal,
    String? submittedByNameVal,
    String? storeNameVal,
  }) {
    hgTotal.value = hgTotalVal;
    hgPresent.value = hgPresentVal;
    hgAbsent.value = hgAbsentVal;
    baTotal.value = baTotalVal;
    baPresent.value = baPresentVal;
    baAbsent.value = baAbsentVal;
    if (submittedByNameVal != null) submittedByName.value = submittedByNameVal;
    if (storeNameVal != null) storeName.value = storeNameVal;
  }
}

class SuccessConfirmationScreen extends StatelessWidget {
  SuccessConfirmationScreen({super.key});

  final ConfirmationController controller = Get.put(ConfirmationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [

            // Header
            Container(
              color: AppColors.brandOrange,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Center(child: Text("←", style: TextStyle(fontSize: 16, color: AppColors.white))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("Attendance Submitted", style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    // Success animation / checkmark
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)]),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Color(0x3316A34A), blurRadius: 24, offset: Offset(0, 8))],
                      ),
                      child: const Center(child: Text("✅", style: TextStyle(fontSize: 40))),
                    ),
                    const SizedBox(height: 24),
                    Text("Attendance Recorded!", style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: AppColors.neutral900)),
                    const SizedBox(height: 6),
                    Obx(() => Text("${controller.submissionDate.value} · ${controller.submissionTime.value}", style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.neutral500, height: 1.6))),
                    const SizedBox(height: 28),
                    // Summary cards
                    _buildSummaryCard(
                      icon: "🏪",
                      title: "H&G Staff",
                      total: controller.hgTotal.value,
                      present: controller.hgPresent.value,
                      absent: controller.hgAbsent.value,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      icon: "💄",
                      title: "BA Staff",
                      total: controller.baTotal.value,
                      present: controller.baPresent.value,
                      absent: controller.baAbsent.value,
                    ),
                    const SizedBox(height: 20),
                    // Submitted by card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrangeLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brandOrange.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          const Text("👤", style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text("Submitted by ${controller.submittedByName.value}", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neutral800))),
                                Obx(() => Text("${controller.submittedByRole.value} · Store: ${controller.storeName.value}", style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.neutral500))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    GestureDetector(
                      onTap: () {
                        // Navigate back to dashboard (Screen 1) – you can define a clear route
                        Get.offAllNamed('/dashboard'); // or Get.offAll(() => DashboardScreen())
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0x59F47B20), blurRadius: 12, offset: Offset(0, 4))],
                        ),
                        child: Center(child: Text("Back to Dashboard", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white))),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Get.snackbar("Report", "Full report feature coming soon.", snackPosition: SnackPosition.BOTTOM);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text("View Full Report", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neutral600))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String icon, required String title, required int total, required int present, required int absent}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn("$total", "Total", AppColors.neutral800),
              _statColumn("$present", "Present", AppColors.presentGreen),
              _statColumn("$absent", "Absent", AppColors.absentRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.neutral500)),
      ],
    );
  }
}