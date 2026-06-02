import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ----------------------------- MOCK DATA CONTROLLER ---------------------------------
class AttendanceNewController extends GetxController {
  // Yesterday's data (29 May)
  final hgYesterdayTotal = 18.obs;
  final hgYesterdayPresent = 15.obs;
  final hgYesterdayAbsent = 3.obs;

  final baYesterdayTotal = 24.obs;
  final baYesterdayPresent = 20.obs;
  final baYesterdayAbsent = 4.obs;

  // Today's data (30 May)
  final hgTodayTotal = 18.obs;
  final hgTodayPresent = 11.obs;
  final hgTodayPending = 7.obs;

  final baTodayTotal = 24.obs;
  final baTodayPresent = 18.obs;
  final baTodayPending = 6.obs;

  // Future API methods will be added here
  void fetchYesterdayData() {
    // Placeholder for GET API
  }

  void submitAttendance() {
    // Placeholder for POST API
  }
}

// ----------------------------- CUSTOM COLOR PALETTE ---------------------------------
class AppColors {
  static const brandOrange = Color(0xFFF47B20);
  static const brandOrangeLight = Color(0xFFFEF0E6);
  static const brandBlue = Color(0xFF4A90D9);
  static const brandBlueDeep = Color(0xFF2563EB);
  static const brandBlueLight = Color(0xFFEBF4FF);
  static const presentGreen = Color(0xFF16A34A);
  static const presentBg = Color(0xFFDCFCE7);
  static const absentRed = Color(0xFFDC2626);
  static const absentBg = Color(0xFFFEE2E2);
  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral700 = Color(0xFF374151);
  static const neutral800 = Color(0xFF1F2937);
  static const neutral900 = Color(0xFF111827);
  static const white = Color(0xFFFFFFFF);
}




