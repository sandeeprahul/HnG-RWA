
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/attendance/attendanceNewController.dart';

import 'ba_attendance_screen.dart';
import 'staff_list_screen.dart';


// ----------------------------- DASHBOARD SCREEN (Screen 1) ---------------------------------
class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final AttendanceNewController controller = Get.find();

  // Hardcoded date to match HTML design: Saturday, 30 May 2026
  final String currentDate = "Saturday, 30 May 2026";
  final String yesterdayDate = "Yesterday · 29 May";
  final String todayLabel = "Today · 30 May";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFE8ECF0),
      body: SafeArea(
        child: Column(
          children: [

            // Main Header (Orange)
            Container(
              color: AppColors.brandOrange,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  // Back button placeholder
                  GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        "Back",
                        "Navigation will be available in next screens",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.neutral800,
                        colorText: AppColors.white,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "←",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Record Attendance",
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentDate,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Info Banner
                    _buildInfoBanner(),
                    const SizedBox(height: 8),
                    // YESTERDAY SECTION
                    _buildSectionLabel(yesterdayDate),
                    // H&G Card - Yesterday
                    Obx(() => _buildAttendanceCard(

                      cardType: CardType.hg,
                      dateType: DateType.yesterday,
                      total: controller.hgYesterdayTotal.value,
                      presentCount: controller.hgYesterdayPresent.value,
                      secondaryCount: controller.hgYesterdayAbsent.value,
                      secondaryLabel: "Absent",
                      actionText: "View Details →",
                      iconEmoji: "🏪",
                      title: "H&G Staff",
                      subtitle: "Store & Operations Team",
                    )),
                    const SizedBox(height: 8),
                    // BA Card - Yesterday
                    Obx(() => _buildAttendanceCard(
                      cardType: CardType.ba,
                      dateType: DateType.yesterday,
                      total: controller.baYesterdayTotal.value,
                      presentCount: controller.baYesterdayPresent.value,
                      secondaryCount: controller.baYesterdayAbsent.value,
                      secondaryLabel: "Absent",
                      actionText: "View Details →",
                      iconEmoji: "💄",
                      title: "BA Staff",
                      subtitle: "Brand Advisors",
                    )),
                    const SizedBox(height: 16),
                    // TODAY SECTION
                    _buildSectionLabel(todayLabel),
                    // H&G Card - Today
                    Obx(() => _buildAttendanceCard(
                      cardType: CardType.hg,
                      dateType: DateType.today,
                      total: controller.hgTodayTotal.value,
                      presentCount: controller.hgTodayPresent.value,
                      secondaryCount: controller.hgTodayPending.value,
                      secondaryLabel: "Pending",
                      actionText: "Record Now →",
                      iconEmoji: "🏪",
                      title: "H&G Staff",
                      subtitle: "Store & Operations Team",
                    )),
                    const SizedBox(height: 8),
                    // BA Card - Today
                    Obx(() => _buildAttendanceCard(
                      cardType: CardType.ba,
                      dateType: DateType.today,
                      total: controller.baTodayTotal.value,
                      presentCount: controller.baTodayPresent.value,
                      secondaryCount: controller.baTodayPending.value,
                      secondaryLabel: "Pending",
                      actionText: "Record Now →",
                      iconEmoji: "💄",
                      title: "BA Staff",
                      subtitle: "Brand Advisors",
                    )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Bottom Navigation Bar
            // _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // Info Banner Widget
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🕒", style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "Today's attendance can be recorded from ",
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E40AF),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "3 PM onwards",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                  const TextSpan(
                    text: ". You can view and update yesterday's records anytime.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section label (e.g., "Yesterday · 29 May")
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.neutral500,
            ),
          ),
          const Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral200,
              indent: 8,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Attendance Card
  Widget _buildAttendanceCard({
    required CardType cardType,
    required DateType dateType,
    required int total,
    required int presentCount,
    required int secondaryCount,
    required String secondaryLabel,
    required String actionText,
    required String iconEmoji,
    required String title,
    required String subtitle,
  }) {
    Color borderColor = (cardType == CardType.hg)
        ? AppColors.brandBlue.withOpacity(0.2)
        : AppColors.brandOrange.withOpacity(0.2);

    return GestureDetector(
      onTap: () {
        // Get.to(() => HgAttendanceScreen());
        Get.to(() => BaAttendanceScreen());

        // Get.snackbar(
        //   "Navigation",
        //   "Navigate to ${title} details (Screen 2/3 coming next)",
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: AppColors.neutral800,
        //   colorText: AppColors.white,
        // );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cardType == CardType.hg
                          ? AppColors.brandBlueLight
                          : AppColors.brandOrangeLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(iconEmoji, style: const TextStyle(fontSize: 14))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral800,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "›",
                    style: TextStyle(fontSize: 16, color: AppColors.neutral300),
                  ),
                ],
              ),
            ),
            // Stats Row
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.neutral100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _buildStatCell("$total", "Total", isSecondary: false),
                  _buildStatCell("$presentCount", "Present",
                      color: AppColors.presentGreen),
                  _buildStatCell("$secondaryCount", secondaryLabel,
                      color: dateType == DateType.yesterday
                          ? AppColors.absentRed
                          : AppColors.brandOrange),
                ],
              ),
            ),
            // Action Chip (View Details / Record Now)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.neutral100, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardType == CardType.hg
                          ? AppColors.brandBlue
                          : AppColors.brandOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actionText,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for stat cell
  Widget _buildStatCell(String number, String label, {Color? color, bool isSecondary = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.neutral100, width: 1),
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.neutral800,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar (exact match to HTML)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem("🏠", "Home", false),
          _buildNavItem("✅", "Ops", true, hasIconBg: true),
          _buildNavItem("🛍️", "Retail", false),
          _buildNavItem("👤", "Profile", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, bool isActive, {bool hasIconBg = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Get.snackbar(
            "Navigation",
            "$label section will be available soon",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.neutral800,
            colorText: AppColors.white,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasIconBg)
                Container(
                  width: 44,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.brandOrangeLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(
                        fontSize: 18,
                        color: isActive ? AppColors.brandOrange : AppColors.neutral400,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: isActive ? AppColors.brandOrange : AppColors.neutral400,
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.brandOrange : AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enums for type safety
enum CardType { hg, ba }
enum DateType { yesterday, today }