// screen3_ba_attendance.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'attendanceNewController.dart';
import 'success_confirmation.dart';



// ----------------------------- CONTROLLER FOR BA STAFF ---------------------------------
class BaAttendanceController extends GetxController {
  final RxList<BaEmployee> employees = <BaEmployee>[
    BaEmployee(
      id: "83108",
      name: "Hema Nalva",
      brand: "Sugar Cosmetics",
      role: "Brand Advisor",
      avatarInitials: "HN",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "10:05 AM",
      checkOut: "07:30 PM",
      absenceReason: null,
      relieverId: null,
      missedReason: null,
      customCheckIn: null,
      customCheckOut: null,
    ),
    BaEmployee(
      id: "84143",
      name: "Bahar Sultana",
      brand: "Revlon",
      role: "Brand Advisor",
      avatarInitials: "BS",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      absenceReason: "Reliever (with ID)",
      relieverId: "Manasa N P – Loreal (83744)",
      missedReason: null,
      customCheckIn: null,
      customCheckOut: null,
    ),
    BaEmployee(
      id: "83744",
      name: "Manasa N P",
      brand: "Loreal",
      role: "Brand Advisor",
      avatarInitials: "MN",
      avatarColor: const Color(0xFF0EA5E9),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      absenceReason: "Missed Marking Attendance",
      relieverId: null,
      missedReason: "Mobile Issue",
      customCheckIn: "09:30",
      customCheckOut: "18:30",
    ),
    BaEmployee(
      id: "84201",
      name: "Anusha Krishnaveni",
      brand: "Lakme",
      role: "Brand Advisor",
      avatarInitials: "AK",
      avatarColor: const Color(0xFFF43F5E),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      absenceReason: "Week Off",
      relieverId: null,
      missedReason: null,
      customCheckIn: null,
      customCheckOut: null,
    ),
    // Additional BA staff to match total 24 (only key ones shown, but design is consistent)
    BaEmployee(
      id: "83001",
      name: "Kavya S",
      brand: "MAC",
      role: "Brand Advisor",
      avatarInitials: "KS",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "09:45 AM",
      checkOut: "06:30 PM",
    ),
    BaEmployee(
      id: "83222",
      name: "Rahul Mehta",
      brand: "Clinique",
      role: "Brand Advisor",
      avatarInitials: "RM",
      avatarColor: const Color(0xFF8B5CF6),
      status: AttendanceStatus.present,
      checkIn: "10:15 AM",
      checkOut: "07:15 PM",
    ),
    BaEmployee(
      id: "83999",
      name: "Sonali Patil",
      brand: "Estée Lauder",
      role: "Brand Advisor",
      avatarInitials: "SP",
      avatarColor: const Color(0xFF0EA5E9),
      status: AttendanceStatus.present,
      checkIn: "09:30 AM",
      checkOut: "06:45 PM",
    ),
    BaEmployee(
      id: "84567",
      name: "Priyanka Rao",
      brand: "Bobbi Brown",
      role: "Brand Advisor",
      avatarInitials: "PR",
      avatarColor: const Color(0xFFF43F5E),
      status: AttendanceStatus.pending,
      checkIn: null,
      checkOut: null,
      absenceReason: null,
    ),
    BaEmployee(
      id: "84789",
      name: "Vinod Kumar",
      brand: "Sugar Cosmetics",
      role: "Brand Advisor",
      avatarInitials: "VK",
      avatarColor: AppColors.brandBlue,
      status: AttendanceStatus.present,
      checkIn: "09:55 AM",
      checkOut: "07:00 PM",
    ),
    // ... more employees can be added; for brevity we keep the key ones from design
  ].obs;

  final Rx<AttendanceFilter> currentFilter = AttendanceFilter.all.obs;

  List<BaEmployee> get filteredEmployees {
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
  int get pendingCount => employees.where((e) => e.status == AttendanceStatus.pending).length;

  void setFilter(AttendanceFilter filter) {
    currentFilter.value = filter;
  }

  void updateAbsenceReason(String employeeId, String? reason) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].absenceReason = reason;
      // Reset sub-fields when reason changes
      if (reason != "Reliever (with ID)") employees[index].relieverId = null;
      if (reason != "Missed Marking Attendance") {
        employees[index].missedReason = null;
        employees[index].customCheckIn = null;
        employees[index].customCheckOut = null;
      }
      employees.refresh();
    }
  }

  void updateRelieverId(String employeeId, String? reliever) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].relieverId = reliever;
      employees.refresh();
    }
  }

  void updateMissedReason(String employeeId, String? reason) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].missedReason = reason;
      employees.refresh();
    }
  }

  void updateCustomTimes(String employeeId, String? checkIn, String? checkOut) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].customCheckIn = checkIn;
      employees[index].customCheckOut = checkOut;
      employees.refresh();
    }
  }

  void saveDraft() {
    Get.snackbar("Draft Saved", "BA attendance changes saved locally.",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.neutral800, colorText: AppColors.white);
  }

  void submitAttendance() {
    // Here you would call API with updated attendance data
    Get.to(() => SuccessConfirmationScreen());

    // Get.snackbar("Submitted", "BA attendance has been submitted successfully.",
    //     snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.presentGreen, colorText: AppColors.white);
  }

  // For popup: when "Reliever BA without ID" is selected, we show a modal. We'll handle by showing a dialog.
  void showRelieverWithoutIdPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RelieverWithoutIdPopup(),
    );
  }
}

class _RelieverWithoutIdPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text("Reliever Details", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
          const SizedBox(height: 4),
          Text("Enter details of the reliever who reported without a system ID", style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.neutral500)),
          const SizedBox(height: 16),
          const _FormField(label: "Full Name *", hint: "e.g. Kavya Reddy", initialValue: "Kavya Reddy"),
          const SizedBox(height: 12),
          const _FormField(label: "Mobile Number *", hint: "10-digit mobile number", initialValue: "9876543210", keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          const _DropdownField(label: "Source *", items: ["Brand – GT Counter", "Brand – Reliever Pool"], initialValue: "Brand – GT Counter"),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(12)), child: Center(child: Text("Cancel", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neutral600)))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.snackbar("Saved", "Reliever details saved.", snackPosition: SnackPosition.BOTTOM);
                  },
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.brandOrange, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x59F47B20), blurRadius: 12)]), child: Center(child: Text("Confirm & Save", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final String initialValue;
  final TextInputType keyboardType;
  const _FormField({required this.label, required this.hint, required this.initialValue, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral600)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.neutral200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.neutral200)),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final String initialValue;
  const _DropdownField({required this.label, required this.items, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(border: Border.all(color: AppColors.neutral200), borderRadius: BorderRadius.circular(8), color: AppColors.neutral50),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: initialValue,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {},
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------- MODELS ---------------------------------
enum AttendanceStatus { present, pending, absent }
enum AttendanceFilter { all, present, absent, pending }

class BaEmployee {
  final String id;
  final String name;
  final String brand;
  final String role;
  final String avatarInitials;
  final Color avatarColor;
  final AttendanceStatus status;
  final String? checkIn;
  final String? checkOut;
  String? absenceReason;
  String? relieverId;
  String? missedReason;
  String? customCheckIn;
  String? customCheckOut;

  BaEmployee({
    required this.id,
    required this.name,
    required this.brand,
    required this.role,
    required this.avatarInitials,
    required this.avatarColor,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.absenceReason,
    this.relieverId,
    this.missedReason,
    this.customCheckIn,
    this.customCheckOut,
  });
}

// ----------------------------- SCREEN 3 WIDGET ---------------------------------
class BaAttendanceScreen extends StatelessWidget {
  BaAttendanceScreen({super.key});

  final BaAttendanceController controller = Get.put(BaAttendanceController());

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
                  GestureDetector(onTap: () => Get.back(), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Center(child: Text("←", style: TextStyle(fontSize: 16, color: AppColors.white))))),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("BA Staff Attendance", style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)), const SizedBox(height: 2), Text("Today · 30 May 2026 · 24 employees", style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.white.withOpacity(0.8)))]),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Obx(() => Column(
                children: [
                  _buildFilterBar(controller),
                  const SizedBox(height: 6,),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: controller.filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final emp = controller.filteredEmployees[index];
                        return _buildEmployeeCard(emp, controller, context);
                      },
                    ),
                  ),
                ],
              )),
            ),
            _buildBottomBar(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BaAttendanceController controller) {
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
            _filterChip("Absent (0)", AttendanceFilter.absent, controller),
            const SizedBox(width: 8),
            _filterChip("Pending (${controller.pendingCount})", AttendanceFilter.pending, controller),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, AttendanceFilter filter, BaAttendanceController controller) {
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
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? _getFilterTextColor(filter) : AppColors.neutral600)),
      ),
    );
  }

  Color _getFilterActiveColor(AttendanceFilter filter) {
    switch (filter) {
      case AttendanceFilter.all: return AppColors.neutral800;
      case AttendanceFilter.present: return AppColors.presentGreen;
      case AttendanceFilter.absent: return AppColors.absentRed;
      case AttendanceFilter.pending: return AppColors.brandOrange;
    }
  }

  Color _getFilterTextColor(AttendanceFilter filter) {
    switch (filter) {
      case AttendanceFilter.all: return AppColors.white;
      case AttendanceFilter.present: return AppColors.presentGreen;
      case AttendanceFilter.absent: return AppColors.absentRed;
      case AttendanceFilter.pending: return AppColors.brandOrange;
    }
  }

  Widget _buildEmployeeCard(BaEmployee emp, BaAttendanceController controller, BuildContext context) {
    final isPresent = emp.status == AttendanceStatus.present;
    final isPending = emp.status == AttendanceStatus.pending;
    final borderColor = isPresent ? AppColors.presentGreen.withOpacity(0.3) : (isPending ? AppColors.brandOrange.withOpacity(0.35) : AppColors.neutral200);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 1.5), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 2)]),
      child: Column(
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(gradient: LinearGradient(colors: [emp.avatarColor, emp.avatarColor.withBlue(emp.avatarColor.blue - 20)]), shape: BoxShape.circle), child: Center(child: Text(emp.avatarInitials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(emp.name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Text("${emp.role} · ${emp.brand}", style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.neutral500)),
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.neutral200)), child: Text(emp.id, style: GoogleFonts.dmMono(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.neutral500))),
                    ]),
                  ]),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: isPresent ? AppColors.presentBg : (isPending ? AppColors.brandOrangeLight : AppColors.absentBg), borderRadius: BorderRadius.circular(20)), child: Text(isPresent ? "Present" : (isPending ? "Pending" : "Absent"), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: isPresent ? AppColors.presentGreen : (isPending ? AppColors.brandOrange : AppColors.absentRed)))),
              ],
            ),
          ),
          if (isPresent)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                border: const Border(top: BorderSide(color: AppColors.neutral100)),
                color: const Color(0xFFFEF0E6).withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(children: [
                  Row(children: [const Text("🟢", style: TextStyle(fontSize: 10)), const SizedBox(width: 4), const Text("In: ", style: TextStyle(fontSize: 11, color: AppColors.neutral600)), Text(emp.checkIn ?? "--", style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neutral800))]),
                  const SizedBox(width: 16),
                  Row(children: [const Text("🔴", style: TextStyle(fontSize: 10)), const SizedBox(width: 4), const Text("Out: ", style: TextStyle(fontSize: 11, color: AppColors.neutral600)), Text(emp.checkOut ?? "--", style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neutral800))]),
                ]),
              ),
            ),
          if (isPending) _buildPendingSection(emp, controller, context),
        ],
      ),
    );
  }

  Widget _buildPendingSection(BaEmployee emp, BaAttendanceController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: const Border(top: BorderSide(color: AppColors.neutral100)), color: const Color(0xFFFEF0E6).withOpacity(0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.brandOrange, shape: BoxShape.circle)), const SizedBox(width: 6), Text("Reason for Absence", style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.neutral600))]),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.neutral200)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: emp.absenceReason?.isEmpty ?? true ? null : emp.absenceReason,
                hint: const Text("— Choose reason —"),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                items: const [
                  "Reliever (with ID)",
                  "Missed Marking Attendance",
                  "Week Off",
                  "Planned Leave",
                  "Reliever BA without ID"
                ].map((reason) => DropdownMenuItem(value: reason, child: Text(reason, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (value) => controller.updateAbsenceReason(emp.id, value),
              ),
            ),
          ),
          // Sub-form for Reliever (with ID)
          if (emp.absenceReason == "Reliever (with ID)")
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🔁 Select Reliever Employee", style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.neutral200)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: emp.relieverId ?? "Manasa N P – Loreal (83744)",
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        items: const ["Manasa N P – Loreal (83744)", "Hema Nalva – Sugar (83108)", "Anusha K – MAC (84201)"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) => controller.updateRelieverId(emp.id, value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Sub-form for Missed Marking Attendance
          if (emp.absenceReason == "Missed Marking Attendance")
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📋 Reason for Missed Marking", style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.neutral200)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: emp.missedReason ?? "Mobile Issue",
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        items: const ["Mobile Issue", "Login Issue", "New Mobile"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) => controller.updateMissedReason(emp.id, value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("⏱ Actual Attendance Time", style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("CHECK IN", style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.neutral500)),
                          const SizedBox(height: 3),
                          TextFormField(
                            initialValue: emp.customCheckIn ?? "09:30",
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.neutral200)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            onChanged: (val) => controller.updateCustomTimes(emp.id, val, emp.customCheckOut),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("CHECK OUT", style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.neutral500)),
                          const SizedBox(height: 3),
                          TextFormField(
                            initialValue: emp.customCheckOut ?? "18:30",
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.neutral200)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            onChanged: (val) => controller.updateCustomTimes(emp.id, emp.customCheckIn, val),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Special case: Reliever BA without ID triggers popup
          if (emp.absenceReason == "Reliever BA without ID")
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => controller.showRelieverWithoutIdPopup(context),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: AppColors.brandOrangeLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.brandOrange.withOpacity(0.3))), child: Center(child: Text("+ Add Reliever Details", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brandOrange)))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BaAttendanceController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.neutral200))),
      child: Row(
        children: [
          Expanded(child: GestureDetector(onTap: controller.saveDraft, child: Container(padding: const EdgeInsets.symmetric(vertical: 13), decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(12)), child: Center(child: Text("Save Draft", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neutral600)))))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: GestureDetector(onTap: controller.submitAttendance, child: Container(padding: const EdgeInsets.symmetric(vertical: 13), decoration: BoxDecoration(color: AppColors.brandBlueDeep, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x4D2563EB), blurRadius: 12, offset: Offset(0, 4))]), child: Center(child: Text("Submit Attendance", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white))))),
          ),
        ],
      ),
    );
  }
}