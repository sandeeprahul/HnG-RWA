// screen2_hg_attendance.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'attendanceNewController.dart';

// Import the shared controller and colors from Screen 1 (or define them again for standalone)
// For simplicity, I'll reuse the same AppColors and extend the AttendanceController.

// ----------------------------- EXTEND CONTROLLER FOR SCREEN 2 ---------------------------------
class HgAttendanceController extends GetxController {
  // Mock employee list for H&G Staff (18 employees)
  final RxList<HgEmployee> employees = <HgEmployee>[
    HgEmployee(
      id: "EMP-1042",
      name: "Rajesh Sharma",
      role: "Cashier",
      avatarInitials: "RS",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "09:02 AM",
      checkOut: "06:18 PM",
      leaveReason: null,
    ),
    HgEmployee(
      id: "EMP-1019",
      name: "Priya Subramaniam",
      role: "Floor Manager",
      avatarInitials: "PS",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: "Week Off",
    ),
    HgEmployee(
      id: "EMP-1031",
      name: "Nisha Krishnan",
      role: "Beautician",
      avatarInitials: "NK",
      avatarColor: const Color(0xFF0EA5E9),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: "Casual Leave",
    ),
    HgEmployee(
      id: "EMP-1055",
      name: "Aisha Mohammed",
      role: "Sales Exec",
      avatarInitials: "AM",
      avatarColor: const Color(0xFFF43F5E),
      status: AttendanceStatus.present,
      checkIn: "09:15 AM",
      checkOut: null, // Not checked out yet
      leaveReason: null,
    ),
    // Additional employees to reach 18 total (only a few shown for brevity, but full list matches HTML mockup)
    HgEmployee(
      id: "EMP-1001",
      name: "Amit Kumar",
      role: "Store Manager",
      avatarInitials: "AK",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "08:45 AM",
      checkOut: "07:00 PM",
    ),
    HgEmployee(
      id: "EMP-1005",
      name: "Sneha Reddy",
      role: "Beauty Consultant",
      avatarInitials: "SR",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.present,
      checkIn: "09:30 AM",
      checkOut: "06:45 PM",
    ),
    HgEmployee(
      id: "EMP-1022",
      name: "Karthik Venkat",
      role: "Visual Merchandiser",
      avatarInitials: "KV",
      avatarColor: const Color(0xFF0EA5E9),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: null,
    ),
    HgEmployee(
      id: "EMP-1048",
      name: "Divya S",
      role: "Cashier",
      avatarInitials: "DS",
      avatarColor: const Color(0xFFF43F5E),
      status: AttendanceStatus.present,
      checkIn: "09:10 AM",
      checkOut: "06:30 PM",
    ),
    HgEmployee(
      id: "EMP-1060",
      name: "Rohit Nair",
      role: "Floor Executive",
      avatarInitials: "RN",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: "Sick Leave",
    ),
    HgEmployee(
      id: "EMP-1072",
      name: "Lavanya Priya",
      role: "Beautician",
      avatarInitials: "LP",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.present,
      checkIn: "09:20 AM",
      checkOut: "06:15 PM",
    ),
    HgEmployee(
      id: "EMP-1088",
      name: "Manish Gupta",
      role: "Sales Associate",
      avatarInitials: "MG",
      avatarColor: const Color(0xFF0EA5E9),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: null,
    ),
    HgEmployee(
      id: "EMP-1093",
      name: "Swati Bhatia",
      role: "Customer Support",
      avatarInitials: "SB",
      avatarColor: const Color(0xFFF43F5E),
      status: AttendanceStatus.present,
      checkIn: "09:05 AM",
      checkOut: "06:20 PM",
    ),
    HgEmployee(
      id: "EMP-1102",
      name: "Ganesh Iyer",
      role: "Inventory Lead",
      avatarInitials: "GI",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "08:55 AM",
      checkOut: "07:15 PM",
    ),
    HgEmployee(
      id: "EMP-1115",
      name: "Pooja Desai",
      role: "Beauty Advisor",
      avatarInitials: "PD",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: "Privilege Leave",
    ),
    HgEmployee(
      id: "EMP-1120",
      name: "Arjun Shetty",
      role: "Floor Manager",
      avatarInitials: "AS",
      avatarColor: const Color(0xFF0EA5E9),
      status: AttendanceStatus.present,
      checkIn: "09:12 AM",
      checkOut: "06:50 PM",
    ),
    HgEmployee(
      id: "EMP-1133",
      name: "Meera Nair",
      role: "Cashier",
      avatarInitials: "MN",
      avatarColor: const Color(0xFFF43F5E),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      leaveReason: null,
    ),
    HgEmployee(
      id: "EMP-1145",
      name: "Vikram Singh",
      role: "Sales Executive",
      avatarInitials: "VS",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "09:18 AM",
      checkOut: "06:40 PM",
    ),
    HgEmployee(
      id: "EMP-1150",
      name: "Anjali Sharma",
      role: "Beautician",
      avatarInitials: "AS",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.present,
      checkIn: "09:25 AM",
      checkOut: "06:55 PM",
    ),
  ].obs;

  // Filter state
  final Rx<AttendanceFilter> currentFilter = AttendanceFilter.all.obs;
  final RxBool selectAllPending = false.obs;

  // List of available leave reasons (matching HTML dropdown)
  final List<String> leaveReasons = [
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
  ];

  // Getters for filtered employees
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

  void toggleSelectAllPending() {
    selectAllPending.value = !selectAllPending.value;
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
      // Update selectAllPending state based on all pending selections
      final allPending = employees.where((e) => e.status == AttendanceStatus.pending).toList();
      final anyUnselected = allPending.any((e) => !e.isSelectedForBulk);
      selectAllPending.value = !anyUnselected && allPending.isNotEmpty;
    }
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

  void submitAttendance() {
    // Filter only pending employees that have been updated or selected
    final pendingList = employees.where((e) => e.status == AttendanceStatus.pending).toList();
    final updatedList = pendingList.where((e) => e.leaveReason != null && e.leaveReason!.isNotEmpty).toList();
    Get.snackbar(
      "Submitted",
      "Attendance for ${updatedList.length} employee(s) updated.\nTotal present: $presentCount, pending left: ${pendingList.length - updatedList.length}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.presentGreen,
      colorText: AppColors.white,
    );
    // Here you would call API to POST updated attendance
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
  });
}

// ----------------------------- SCREEN 2 WIDGET ---------------------------------
class HgAttendanceScreen extends StatelessWidget {
  HgAttendanceScreen({super.key});

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
                      Text("Today · 30 May 2026 · 18 employees", style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.white.withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
            ),
            // Filter chips and content
            Expanded(
              child: Obx(() => Column(
                children: [
                  _buildFilterBar(controller),
                  _buildSelectAllRow(controller),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: controller.filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final emp = controller.filteredEmployees[index];
                        return _buildEmployeeCard(emp, controller);
                      },
                    ),
                  ),
                ],
              )),
            ),
            // Bottom action bar
            _buildBottomBar(controller),
          ],
        ),
      ),
    );
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
            color: isActive ? _getFilterTextColor(filter) : AppColors.neutral600,
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