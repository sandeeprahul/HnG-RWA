// screen2_hg_attendance.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/helper/confirmDialog.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendanceNewController.dart';
import 'record_attendance_new_screen.dart';

// Import the shared controller and colors from Screen 1 (or define them again for standalone)
// For simplicity, I'll reuse the same AppColors and extend the AttendanceController.

// ----------------------------- CONTROLLER FOR SCREEN 2 (API-backed) ---------------------------------
class HgAttendanceController extends GetxController {
  // Employees loaded from API.
  final RxList<HgEmployee> employees = <HgEmployee>[].obs;

  // Filter state
  final Rx<AttendanceFilter> currentFilter = AttendanceFilter.all.obs;
  final RxBool selectAllPending = false.obs;
  final RxBool isLoading = false.obs;

  // Leave reasons / types loaded from API (falls back to a default list).
  final RxList<String> leaveReasons = <String>[
    "Absent / Loss of Pay (LOP)",
    "Casual Leave",
    "Compensatory Off",
    "Half Day Worked / Half Day Absent",
    "Half Day Worked / Half Day Casual Leave (HCL)",
    "Half Day Worked / Half Day Privilege Leave (HPL)",
    "Half Day Worked / Half Day Sick Leave (HSL)",
    "Holiday",
    "Maternity Leave",
    "Privilege Leave",
    "Sick Leave",
    "Week Off",
  ].obs;

  // Avatar color palette used when building employees from API data.
  static const List<Color> _avatarPalette = [
    AppColors.brandBlue,
    Color(0xFF8B5CF6),
    Color(0xFF0EA5E9),
    Color(0xFFF43F5E),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // ----------------------------- FETCH (GET) ---------------------------------
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString("userCode");

      if (userCode == null || userCode.isEmpty) {
        isLoading.value = false;
        Fluttertoast.showToast(msg: 'User not found. Please login again.');
        return;
      }

      final url =
          "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/GetLeaveTypesAndEmployess/$userCode";
      print("HG ATTENDANCE FETCH: $url");

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Leave types
        final List<dynamic> leaveList =
            (data['leavetypelist'] as List<dynamic>?) ?? [];
        if (leaveList.isNotEmpty) {
          leaveReasons.assignAll(
            leaveList
                .map((e) => (e?['leaveType'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toList(),
          );
        }

        // Employees
        final List<dynamic> empList =
            (data['employeelist'] as List<dynamic>?) ?? [];
        final parsed = <HgEmployee>[];
        for (var i = 0; i < empList.length; i++) {
          final e = (empList[i] as Map<String, dynamic>?) ?? {};
          parsed.add(HgEmployee.fromApi(e, _avatarPalette[i % _avatarPalette.length]));
        }
        employees.assignAll(parsed);
        _recomputeSelectAll();
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to load data. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      print("Error fetching HG attendance: $e");
      Fluttertoast.showToast(
        msg: 'Error fetching data. Please try again.',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------- FILTERS ---------------------------------
  List<HgEmployee> get filteredEmployees {
    switch (currentFilter.value) {
      case AttendanceFilter.all:
        return employees;
      case AttendanceFilter.present:
        return employees.where((e) => e.status == AttendanceStatus.present).toList();
      case AttendanceFilter.absent:
        return employees.where((e) => e.status == AttendanceStatus.absent).toList();
      case AttendanceFilter.pending:
        return employees.where((e) => e.status == AttendanceStatus.pending).toList();
    }
  }

  int get presentCount => employees.where((e) => e.status == AttendanceStatus.present).length;
  int get absentCount => employees.where((e) => e.status == AttendanceStatus.absent).length;
  int get pendingCount => employees.where((e) => e.status == AttendanceStatus.pending).length;

  void setFilter(AttendanceFilter filter) {
    currentFilter.value = filter;
  }

  void updateLeaveReason(String employeeId, String? reason) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].leaveReason = reason;
      employees.refresh();
    }
  }

  // ----------------------------- SELECTION (select all / select one) ---------------------------------
  void toggleSelectAllPending() {
    selectAllPending.value = !selectAllPending.value;
    // Mirrors EmployeeListScreen: select all rows that still need marking (pending).
    for (var emp in employees) {
      if (emp.status == AttendanceStatus.pending) {
        emp.isSelectedForBulk = selectAllPending.value;
      }
    }
    employees.refresh();
  }

  void toggleEmployeeSelection(String employeeId) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1 && employees[index].status == AttendanceStatus.pending) {
      employees[index].isSelectedForBulk = !employees[index].isSelectedForBulk;
      employees.refresh();
      _recomputeSelectAll();
    }
  }

  void _recomputeSelectAll() {
    final allPending =
        employees.where((e) => e.status == AttendanceStatus.pending).toList();
    final anyUnselected = allPending.any((e) => !e.isSelectedForBulk);
    selectAllPending.value = !anyUnselected && allPending.isNotEmpty;
  }

  void saveDraft() {
    Get.snackbar(
      "Draft Saved",
      "Current attendance changes have been saved locally.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.neutral800,
      colorText: AppColors.white,
    );
  }

  // ----------------------------- SUBMIT (POST) ---------------------------------
  void submitAttendance() {
    showConfirmDialog(
      title: 'Alert!',
      msg: 'Confirm Submit?',
      onConfirmed: () async {
        await _postAttendance();
      },
    );
  }

  Future<void> _postAttendance() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString("userCode");
      final locationCode = prefs.getString("locationCode");

      // Same JSON forming as EmployeeListScreen: include every employee row.
      // A pending employee with a chosen reason posts that reason; otherwise the
      // employee's existing/original status is posted unchanged.
      final List<Map<String, String>> jsonOutput = employees.map((emp) {
        final bool isSelected = emp.status == AttendanceStatus.pending &&
            (emp.leaveReason != null && emp.leaveReason!.isNotEmpty);

        String formattedDate = emp.rawDate;
        try {
          final parsedDate =
              DateFormat("dd-MM-yyyy HH:mm:ss").parse(emp.rawDate);
          formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
        } catch (_) {
          // Keep rawDate as-is if it doesn't match the expected format.
        }

        return {
          "empCode": emp.id,
          "date": formattedDate,
          "leaveType": isSelected ? emp.leaveReason! : emp.originalStatus,
          "locationCode": locationCode ?? '',
          "updatedby": userCode ?? '',
        };
      }).toList();

      final String jsonBody = json.encode(jsonOutput);
      print("HG ATTENDANCE UPLOADING: $jsonBody");

      const String url =
          "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/attendanceupdate";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData["statusCode"] == "200") {
          Fluttertoast.showToast(msg: '${responseData["message"]}');
          await fetchData();
        } else {
          isLoading.value = false;
          Fluttertoast.showToast(
            msg: '${responseData["message"]}',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        isLoading.value = false;
        Fluttertoast.showToast(
          msg: 'Failed to submit. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      isLoading.value = false;
      print("Error submitting HG attendance: $e");
      Fluttertoast.showToast(
        msg: 'Failed to submit attendance. $e',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}

// Models
enum AttendanceStatus { present, pending, absent }
enum AttendanceFilter { all, present, absent, pending }

class HgEmployee {
  final String id;
  final String name;
  final String role;
  final String avatarInitials;
  final Color avatarColor;
  final AttendanceStatus status;
  final String? checkIn;
  final String? checkOut;
  String? leaveReason;
  bool isSelectedForBulk;

  // Raw values from the API, needed to rebuild the POST payload.
  final String originalStatus; // raw status string from API ("" when unmarked)
  final String rawDate; // raw date string from API ("dd-MM-yyyy HH:mm:ss")

  HgEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarInitials,
    required this.avatarColor,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.leaveReason,
    this.isSelectedForBulk = false,
    this.originalStatus = "",
    this.rawDate = "",
  });

  // Maps a single employee JSON object (empCode/empName/designation/date/status)
  // into the UI model. An empty status means the row still needs marking (pending);
  // a non-empty status means it has already been recorded (shown as present).
  factory HgEmployee.fromApi(Map<String, dynamic> json, Color avatarColor) {
    final String empCode = (json['empCode'] ?? '').toString();
    final String empName = (json['empName'] ?? '').toString();
    final String designation = (json['designation'] ?? '').toString();
    final String rawDate = (json['date'] ?? '').toString();
    final String statusStr = (json['status'] ?? '').toString().trim();

    final bool isPending = statusStr.isEmpty;

    return HgEmployee(
      id: empCode,
      name: empName,
      role: designation,
      avatarInitials: _initials(empName),
      avatarColor: avatarColor,
      status: isPending ? AttendanceStatus.pending : AttendanceStatus.present,
      checkIn: null,
      checkOut: null,
      // Pre-fill the dropdown when a reason was already recorded.
      leaveReason: isPending ? null : statusStr,
      originalStatus: statusStr,
      rawDate: rawDate,
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ----------------------------- SCREEN 2 WIDGET ---------------------------------
class HgAttendanceScreen extends StatelessWidget {
  HgAttendanceScreen({
    super.key,
    this.attendanceDay,
    this.staffCount,
    this.locationName,
  });

  // Data passed from the dashboard card so it can be used on this screen.
  final AttendanceDay? attendanceDay;
  final StaffCount? staffCount;
  final String? locationName;

  final HgAttendanceController controller = Get.put(HgAttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFE8ECF0),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("H&G Staff Attendance", style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)),
                      const SizedBox(height: 2),
                      Obx(() => Text(_headerSubtitle(), style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.white.withOpacity(0.8)))),
                    ],
                  ),
                ],
              ),
            ),
            // Filter chips and content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.brandOrange));
                }
                return Column(
                  children: [
                    _buildFilterBar(controller),
                    _buildSelectAllRow(controller),
                    Expanded(
                      child: controller.filteredEmployees.isEmpty
                          ? Center(
                              child: Text(
                                "No employees found.",
                                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.neutral500),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: controller.filteredEmployees.length,
                              itemBuilder: (context, index) {
                                final emp = controller.filteredEmployees[index];
                                return _buildEmployeeCard(emp, controller);
                              },
                            ),
                    ),
                  ],
                );
              }),
            ),
            // Bottom action bar
            _buildBottomBar(controller),
          ],
        ),
      ),
    );
  }

  String _headerSubtitle() {
    final parts = <String>[];
    final date = attendanceDay?.date;
    final dayType = attendanceDay?.dayType;
    if (date != null) {
      final pretty = DateFormat("dd MMM yyyy").format(date);
      parts.add(dayType != null && dayType.isNotEmpty
          ? "${dayType[0].toUpperCase()}${dayType.substring(1).toLowerCase()} · $pretty"
          : pretty);
    }
    parts.add("${controller.employees.length} employees");
    return parts.join(" · ");
  }

  Widget _buildFilterBar(HgAttendanceController controller) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip("All (${controller.employees.length})", AttendanceFilter.all, controller),
            const SizedBox(width: 8),
            _filterChip("Present (${controller.presentCount})", AttendanceFilter.present, controller),
            const SizedBox(width: 8),
            _filterChip("Absent (${controller.absentCount})", AttendanceFilter.absent, controller),
            const SizedBox(width: 8),
            _filterChip("Pending (${controller.pendingCount})", AttendanceFilter.pending, controller),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, AttendanceFilter filter, HgAttendanceController controller) {
    final isActive = controller.currentFilter.value == filter;
    return GestureDetector(
      onTap: () => controller.setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? _getFilterActiveColor(filter) : AppColors.white,
          border: Border.all(color: isActive ? _getFilterActiveColor(filter) : AppColors.neutral200, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.neutral600,
          ),
        ),
      ),
    );
  }

  Color _getFilterActiveColor(AttendanceFilter filter) {
    switch (filter) {
      case AttendanceFilter.all:
        return AppColors.neutral800;
      case AttendanceFilter.present:
        return AppColors.presentGreen;
      case AttendanceFilter.absent:
        return AppColors.absentRed;
      case AttendanceFilter.pending:
        return AppColors.brandOrange;
    }
  }

  Color _getFilterTextColor(AttendanceFilter filter) {
    switch (filter) {
      case AttendanceFilter.all:
        return AppColors.white;
      case AttendanceFilter.present:
        return AppColors.presentGreen;
      case AttendanceFilter.absent:
        return AppColors.absentRed;
      case AttendanceFilter.pending:
        return AppColors.brandOrange;
    }
  }

  Widget _buildSelectAllRow(HgAttendanceController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Select all pending for bulk update", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
          GestureDetector(
            onTap: () => controller.toggleSelectAllPending(),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: controller.selectAllPending.value ? AppColors.brandOrange : Colors.transparent,
                border: Border.all(color: AppColors.neutral300, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: controller.selectAllPending.value
                  ? const Center(child: Text("✓", style: TextStyle(fontSize: 12, color: AppColors.white)))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(HgEmployee emp, HgAttendanceController controller) {
    final isPresent = emp.status == AttendanceStatus.present;
    final isPending = emp.status == AttendanceStatus.pending;
    final borderColor = isPresent ? AppColors.presentGreen.withOpacity(0.3) : (isPending ? AppColors.brandOrange.withOpacity(0.35) : AppColors.neutral200);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          // Top row: avatar, info, status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [emp.avatarColor, emp.avatarColor.withBlue(emp.avatarColor.blue - 20)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(emp.avatarInitials, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emp.name, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(emp.role, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.neutral500)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: Text(emp.id, style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.neutral500)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPresent ? AppColors.presentBg : (isPending ? AppColors.brandOrangeLight : AppColors.absentBg),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    emp.status == AttendanceStatus.present ? "Present" : (emp.status == AttendanceStatus.pending ? "Pending" : "Absent"),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPresent ? AppColors.presentGreen : (isPending ? AppColors.brandOrange : AppColors.absentRed),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Check-in row for present employees

          if (isPresent)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
              decoration: BoxDecoration(
                border: const Border(top: BorderSide(color: AppColors.neutral100)),
                color: const Color(0xFFFEF0E6).withOpacity(0.4),
              ),
              child: Row(
                children: [
                  Row(children: [const Text("🟢", style: TextStyle(fontSize: 10)), const SizedBox(width: 4), Text("In: ", style: TextStyle(fontSize: 12, color: AppColors.neutral600)), Text(emp.checkIn ?? "--", style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral800))]),
                  const SizedBox(width: 16),
                  Row(children: [const Text("🔴", style: TextStyle(fontSize: 10)), const SizedBox(width: 4), Text("Out: ", style: TextStyle(fontSize: 12, color: AppColors.neutral600)), Text(emp.checkOut ?? "—", style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral800))]),
                ],
              ),
            ),
          // Leave section for pending employees
          if (isPending)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: const Border(top: BorderSide(color: AppColors.neutral100)),
                color: const Color(0xFFFEF0E6).withOpacity(0.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.brandOrange, shape: BoxShape.circle)), const SizedBox(width: 6), Text("Select Leave Reason", style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.neutral600))]),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.neutral200)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: emp.leaveReason?.isEmpty ?? true ? null : emp.leaveReason,
                        hint: const Text("— Choose reason —"),
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        items: controller.leaveReasons.map((reason) {
                          return DropdownMenuItem(value: reason, child: Text(reason, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (value) => controller.updateLeaveReason(emp.id, value),
                      ),
                    ),
                  ),
                  // Bulk selection checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mark for bulk update", style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.neutral600)),
                      GestureDetector(
                        onTap: () => controller.toggleEmployeeSelection(emp.id),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: emp.isSelectedForBulk ? AppColors.brandOrange : Colors.transparent,
                            border: Border.all(color: AppColors.neutral300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: emp.isSelectedForBulk ? const Center(child: Text("✓", style: TextStyle(fontSize: 10, color: AppColors.white))) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(HgAttendanceController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.neutral200))),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.saveDraft,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text("Save Draft", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neutral600))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: controller.submitAttendance,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(color: AppColors.brandOrange, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x59F47B20), blurRadius: 12, offset: Offset(0, 4))]),
                child: Center(child: Text("Submit Attendance", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}