// screen3_ba_attendance.dart
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendanceNewController.dart';
import 'record_attendance_new_screen.dart';
import 'success_confirmation.dart';

// ----------------------------- CONTROLLER FOR BA STAFF (API-backed) ---------------------------------
class BaAttendanceController extends GetxController {
  BaAttendanceController({
    required this.attendanceDate,
    required this.initialLocationCode,
    this.initialLocationName,
  });

  // yyyy-MM-dd, supplied by the screen (from the dashboard's selected day).
  final String attendanceDate;

  // Location code selected on the DashboardScreen.
  final String initialLocationCode;
  final String? initialLocationName;

  static const String _baseUrl =
      'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api';

  final RxBool isLoading = false.obs;
  final RxList<BaEmployee> employees = <BaEmployee>[].obs;
  final RxList<BaLeaveType> leaveTypes = <BaLeaveType>[].obs;
  final Rx<AttendanceFilter> currentFilter = AttendanceFilter.all.obs;

  // Page meta from API
  final RxString locationName = ''.obs;
  final RxString locationCode = ''.obs;
  final RxInt totalCount = 0.obs;
  final RxInt presentTotal = 0.obs;
  final RxInt pendingTotal = 0.obs;

  // Resolved logged-in user id (used in fetch + submit payloads).
  int? userId;

  static const List<Color> _avatarPalette = [
    AppColors.brandBlue,
    Color(0xFF8B5CF6),
    Color(0xFF0EA5E9),
    Color(0xFFF43F5E),
  ];

  @override
  void onInit() {
    super.onInit();
    locationName.value = initialLocationName ?? '';
    locationCode.value = initialLocationCode;
    fetchData();
  }

  // ----------------------------- FETCH PAGE (POST) ---------------------------------
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

      userId = int.tryParse(userCode);

      if (initialLocationCode.isEmpty) {
        isLoading.value = false;
        Fluttertoast.showToast(msg: 'Location not selected.');
        return;
      }

      // Send LocationCode as a number when possible (API expects an int),
      // otherwise fall back to the raw string.
      final Map<String, dynamic> payload = {
        // "LocationCode": 106,
        "LocationCode":
            int.tryParse(initialLocationCode) ?? initialLocationCode,
        "attendanceDate": attendanceDate,
      };

      final url = '$_baseUrl/Login/GetBAAttendancePagebylocation';
      print("BA ATTENDANCE FETCH: $url  payload: ${jsonEncode(payload)}");

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          locationName.value = (data['locationName'] ?? '').toString();
          locationCode.value = (data['locationCode'] ?? '').toString();
          totalCount.value = _toInt(data['total']);
          presentTotal.value = _toInt(data['present']);
          pendingTotal.value = _toInt(data['pending']);

          final List<dynamic> rawTypes =
              (data['leaveTypes'] as List<dynamic>?) ?? [];
          leaveTypes.assignAll(rawTypes
              .map((e) =>
                  BaLeaveType.fromJson((e as Map<String, dynamic>?) ?? {}))
              .toList());

          final List<dynamic> rawEmps =
              (data['employees'] as List<dynamic>?) ?? [];
          final parsed = <BaEmployee>[];
          for (var i = 0; i < rawEmps.length; i++) {
            final e = (rawEmps[i] as Map<String, dynamic>?) ?? {};
            parsed.add(BaEmployee.fromApi(
                e, _avatarPalette[i % _avatarPalette.length]));
          }
          employees.assignAll(parsed);
        } else {
          Fluttertoast.showToast(
            msg: (data['message'] ?? 'Failed to fetch data.').toString(),
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to load data. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      print("Error fetching BA attendance: $e");
      Fluttertoast.showToast(
        msg: 'Error fetching data. Please try again.',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------- FETCH RELIEVER LIST (GET) ---------------------------------
  Future<void> fetchRelieverList(BaEmployee emp) async {
    if (emp.relieverOptions.isNotEmpty || emp.relieverLoading) return;
    try {
      emp.relieverLoading = true;
      employees.refresh();

      final url = '$_baseUrl/Login/GetBARelieverEmployeeList/${emp.id}';
      print("BA RELIEVER FETCH: $url");

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> raw =
              (data['relieverEmployees'] as List<dynamic>?) ?? [];
          emp.relieverOptions = raw
              .map((e) => BaRelieverEmployee.fromJson(
                  (e as Map<String, dynamic>?) ?? {}))
              .toList();
        } else {
          Fluttertoast.showToast(
              msg: (data['message'] ?? 'No relievers found.').toString());
        }
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to load relievers (${response.statusCode}).');
      }
    } catch (e) {
      print("Error fetching reliever list: $e");
      Fluttertoast.showToast(msg: 'Error loading relievers.');
    } finally {
      emp.relieverLoading = false;
      employees.refresh();
    }
  }

  // ----------------------------- DERIVED / FILTERS ---------------------------------
  List<BaEmployee> get filteredEmployees {
    switch (currentFilter.value) {
      case AttendanceFilter.all:
        return employees;
      case AttendanceFilter.present:
        return employees
            .where((e) => e.status == AttendanceStatus.present)
            .toList();
      case AttendanceFilter.absent:
        return employees
            .where((e) => e.status == AttendanceStatus.absent)
            .toList();
      case AttendanceFilter.pending:
        return employees
            .where((e) => e.status == AttendanceStatus.pending)
            .toList();
    }
  }

  int get presentCount =>
      employees.where((e) => e.status == AttendanceStatus.present).length;

  int get pendingCount =>
      employees.where((e) => e.status == AttendanceStatus.pending).length;

  int get absentCount =>
      employees.where((e) => e.status == AttendanceStatus.absent).length;

  void setFilter(AttendanceFilter filter) {
    currentFilter.value = filter;
  }

  // Returns the full leave type (with sub types) currently selected for an employee.
  BaLeaveType? selectedLeaveTypeFor(BaEmployee emp) {
    if (emp.leaveTypeId == null) return null;
    return leaveTypes.firstWhereOrNull((t) => t.id == emp.leaveTypeId);
  }

  // True when the selected reason is the manual "Reliever BA without ID" case.
  bool isRelieverWithoutId(BaEmployee emp) {
    return (emp.absenceReason ?? '').toLowerCase().contains('without');
  }

  // True when the selected reason needs a system reliever employee (with ID).
  bool needsRelieverWithId(BaEmployee emp) {
    final name = (emp.absenceReason ?? '').toLowerCase();
    return name.contains('reliever') &&
        name.contains('with id') &&
        !name.contains('without');
  }

  // ----------------------------- UPDATE HELPERS ---------------------------------
  void updateAbsenceReason(String employeeId, String? reasonName) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index == -1) return;
    final emp = employees[index];
    emp.absenceReason = reasonName;
    final type = leaveTypes.firstWhereOrNull((t) => t.name == reasonName);
    emp.leaveTypeId = type?.id;
    // Reset dependent fields whenever the reason changes.
    emp.missedReason = null;
    emp.subTypeId = null;
    emp.relieverId = null;
    emp.relieverEmployeeCode = null;
    employees.refresh();

    // Pre-load the reliever list when needed.
    if (needsRelieverWithId(emp)) {
      fetchRelieverList(emp);
    }
  }

  void updateSubType(String employeeId, BaLeaveSubType? subType) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].missedReason = subType?.name;
      employees[index].subTypeId = subType?.id;
      employees.refresh();
    }
  }

  void updateReliever(String employeeId, BaRelieverEmployee? reliever) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].relieverId = reliever?.displayName;
      employees[index].relieverEmployeeCode = reliever?.employeeCode;
      employees.refresh();
    }
  }

  void updateCustomTimes(String employeeId, String? checkIn, String? checkOut) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      // Store only; no refresh so the text field keeps focus while typing.
      if (checkIn != null) employees[index].customCheckIn = checkIn;
      if (checkOut != null) employees[index].customCheckOut = checkOut;
    }
  }

  // Sets a time picked from the time picker (stored as 24h "HH:mm") and
  // refreshes so the field reflects the new value.
  void setCustomTime(String employeeId, bool isCheckIn, String value) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      if (isCheckIn) {
        employees[index].customCheckIn = value;
      } else {
        employees[index].customCheckOut = value;
      }
      employees.refresh();
    }
  }

  void saveDraft() {
    Get.snackbar("Draft Saved", "BA attendance changes saved locally.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.neutral800,
        colorText: AppColors.white);
  }

  void updateRelieverWithoutId(
      String employeeId, String? name, String? mobile, String? source) {
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      employees[index].nameWithoutId = name;
      employees[index].mobileWithoutId = mobile;
      employees[index].sourceWithoutId = source;
      employees.refresh();
    }
  }

  String? nullOrValue(dynamic value) {
    if (value == null) return null;
    return nullIfEmpty(value.toString());
  }

  String? nullIfEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  // ----------------------------- PER-EMPLOYEE SUBMIT (POST) ---------------------------------
  Future<void> submitEmployee(BaEmployee emp) async {
    // Validation
    if (emp.absenceReason == null || emp.absenceReason!.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a reason for ${emp.name}.');
      return;
    }
    final isWithout = isRelieverWithoutId(emp);
    final selectedType = selectedLeaveTypeFor(emp);
    // Sub-type is required only for normal leave types. The "Reliever BA
    // without ID" case captures its source via the popup (sourceWithoutId),
    // so we skip the generic sub-type check here.
    if (!isWithout &&
        (selectedType?.subTypes.isNotEmpty ?? false) &&
        emp.subTypeId == null) {
      Fluttertoast.showToast(msg: 'Please select a detail for ${emp.name}.');
      return;
    }
    if (needsRelieverWithId(emp) &&
        (emp.relieverEmployeeCode == null ||
            emp.relieverEmployeeCode!.isEmpty)) {
      Fluttertoast.showToast(msg: 'Please select a reliever for ${emp.name}.');
      return;
    }
    if (isWithout &&
        ((emp.nameWithoutId ?? '').trim().isEmpty ||
            (emp.mobileWithoutId ?? '').trim().isEmpty)) {
      Fluttertoast.showToast(
          msg: 'Please add reliever details for ${emp.name}.');
      return;
    }

    // String? nullIfEmpty(String? v) =>
    //     (v == null || v.trim().isEmpty) ? null : v.trim();
// Optimized to convert any dynamic object to a trimmed string or return null if empty

    String emptyIfNull(dynamic value) => value?.toString() ?? '';

    // final relieverCode = nullIfEmpty(emp.relieverEmployeeCode);
    final relieverCode = nullIfEmpty(emp.relieverEmployeeCode);
    final Map<String, dynamic> payload = {
      "userId": nullOrValue(userId),
      "employeeCode": nullOrValue(emp.id),
      "attendanceDate": nullOrValue(attendanceDate),
      "reasonId": nullOrValue(emp.leaveTypeId),
      // Replaced empty string fallback with null
      "reason": nullOrValue(emp.absenceReason),
      "subTypeReasonId": nullOrValue(emp.subTypeId),
      // Replaced empty string fallback with null
      "subTypeReason": nullOrValue(emp.missedReason),
      "relieverEmpId": nullOrValue(relieverCode),
      "nameWithoutId": nullOrValue(emp.nameWithoutId),
      "mobileWithoutId": nullOrValue(emp.mobileWithoutId),
      "sourceWithoutId": nullOrValue(emp.sourceWithoutId),
      "inTime": nullOrValue(emp.customCheckIn),
      "outTime": nullOrValue(emp.customCheckOut),
    };

    // final Map<String, dynamic> payload = {
    //   "userId": userId,
    //   "employeeCode": emptyIfNull(emp.id),
    //   "attendanceDate": emptyIfNull(attendanceDate),
    //   "reasonId": emp.leaveTypeId ?? "",
    //   "reason": emptyIfNull(emp.absenceReason),
    //   "subTypeReasonId": emp.subTypeId ?? "",
    //   "subTypeReason": emptyIfNull(emp.missedReason),
    //   "relieverEmpId": emptyIfNull(relieverCode),
    //   "nameWithoutId": emptyIfNull(emp.nameWithoutId),
    //   "mobileWithoutId": emptyIfNull(emp.mobileWithoutId),
    //   "sourceWithoutId": emptyIfNull(emp.sourceWithoutId),
    //   "inTime": emptyIfNull(emp.customCheckIn),
    //   "outTime": emptyIfNull(emp.customCheckOut),
    // };
    // final Map<String, dynamic> payload = {
    //   "userId": userId,
    //   "employeeCode": emp.id,
    //   "attendanceDate": attendanceDate,
    //   "reasonId": emp.leaveTypeId,
    //   "reason": emp.absenceReason,
    //   "subTypeReasonId": emp.subTypeId,
    //   "subTypeReason": nullIfEmpty(emp.missedReason),
    //   "relieverEmpId":
    //       relieverCode == null ? null : (int.tryParse(relieverCode) ?? relieverCode),
    //   "nameWithoutId": nullIfEmpty(emp.nameWithoutId),
    //   "mobileWithoutId": nullIfEmpty(emp.mobileWithoutId),
    //   "sourceWithoutId": nullIfEmpty(emp.sourceWithoutId),
    //   "inTime": nullIfEmpty(emp.customCheckIn),
    //   "outTime": nullIfEmpty(emp.customCheckOut),
    // };

    final url = '$_baseUrl/Login/SaveBAAttendanceException';
    print("BA SUBMIT: $url  payload: ${jsonEncode(payload)}");

    try {
      emp.submitting = true;
      employees.refresh();

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          Fluttertoast.showToast(
            msg: (data['message'] ?? 'Attendance submitted for ${emp.name}.')
                .toString(),
          );
          await fetchData();
        } else {
          Fluttertoast.showToast(
            msg: (data['message'] ?? 'Failed to submit attendance.').toString(),
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to submit. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      print("Error submitting BA attendance: $e");
      Fluttertoast.showToast(
        msg: 'Error submitting attendance. Please try again.',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      emp.submitting = false;
      employees.refresh();
    }
  }

  void submitAttendance() {
    // Global submit retained for now; navigates to the success screen.
    Get.to(() => SuccessConfirmationScreen());
  }

  // For popup: when "Reliever BA without ID" is selected, show a modal.
  void showRelieverWithoutIdPopup(BuildContext context, BaEmployee emp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _RelieverWithoutIdPopup(employee: emp, controller: this),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class _RelieverWithoutIdPopup extends StatefulWidget {
  final BaEmployee employee;
  final BaAttendanceController controller;

  const _RelieverWithoutIdPopup(
      {required this.employee, required this.controller});

  @override
  State<_RelieverWithoutIdPopup> createState() =>
      _RelieverWithoutIdPopupState();
}

class _RelieverWithoutIdPopupState extends State<_RelieverWithoutIdPopup> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late List<String> _sources;
  String? _selectedSource;

  // Reliever check-in / check-out (24h "HH:mm"), sent as inTime / outTime.
  String? _checkIn;
  String? _checkOut;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _nameCtrl = TextEditingController(text: emp.nameWithoutId ?? '');
    _mobileCtrl = TextEditingController(text: emp.mobileWithoutId ?? '');
    _checkIn = emp.customCheckIn;
    _checkOut = emp.customCheckOut;
    // Source options come from the selected leave type's sub types.
    final type = widget.controller.selectedLeaveTypeFor(emp);
    _sources = (type?.subTypes ?? const <BaLeaveSubType>[])
        .map((s) => s.name)
        .toList();
    if (_sources.isEmpty) {
      _sources = const ["Brand – GT Counter", "Brand – Reliever Pool"];
    }
    _selectedSource =
        (emp.sourceWithoutId != null && _sources.contains(emp.sourceWithoutId))
            ? emp.sourceWithoutId
            : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    if (name.isEmpty || mobile.isEmpty || _selectedSource == null) {
      Fluttertoast.showToast(msg: 'Please fill all reliever details.');
      return;
    }
    if ((_checkIn ?? '').isEmpty || (_checkOut ?? '').isEmpty) {
      Fluttertoast.showToast(msg: 'Please select check-in and check-out time.');
      return;
    }
    widget.controller.updateRelieverWithoutId(
        widget.employee.id, name, mobile, _selectedSource);
    // Persist the captured times so they are sent as inTime / outTime.
    widget.controller
        .updateCustomTimes(widget.employee.id, _checkIn, _checkOut);
    Get.back();
    Fluttertoast.showToast(msg: 'Reliever details saved.');
  }

  // Opens an iOS-style 24-hour time spinner and stores the value as "HH:mm".
  Future<void> _pickTime(bool isCheckIn) async {
    final now = DateTime.now();
    final current = (isCheckIn ? _checkIn : _checkOut) ?? '';
    DateTime initial =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final parts = current.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim().split(' ').first);
      if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
        initial = DateTime(now.year, now.month, now.day, h, m);
      }
    }

    DateTime selected = initial;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: AppColors.neutral200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("Cancel",
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: AppColors.neutral500)),
                      ),
                      Text(isCheckIn ? "Check In" : "Check Out",
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900)),
                      CupertinoButton(
                        onPressed: () {
                          final formatted =
                              "${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}";
                          setState(() {
                            if (isCheckIn) {
                              _checkIn = formatted;
                            } else {
                              _checkOut = formatted;
                            }
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Done",
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandOrange)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: initial,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text("Reliever Details",
                style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900)),
            const SizedBox(height: 4),
            Text(
                "Enter details of the reliever who reported without a system ID",
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.neutral500),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _field("Full Name *", "e.g. Kavya Reddy", _nameCtrl),
            const SizedBox(height: 12),
            _field("Mobile Number *", "10-digit mobile number", _mobileCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _sourceDropdown(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _timeField(
                        "Check In *", _checkIn, () => _pickTime(true))),
                const SizedBox(width: 10),
                Expanded(
                    child: _timeField(
                        "Check Out *", _checkOut, () => _pickTime(false))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                            child: Text("Cancel",
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutral600)))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _save,
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: AppColors.brandOrange,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x59F47B20), blurRadius: 12)
                            ]),
                        child: Center(
                            child: Text("Confirm & Save",
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white)))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.dmSans(fontSize: 12, color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.neutral200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.neutral200)),
          ),
        ),
      ],
    );
  }

  Widget _sourceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Source *",
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.neutral50),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSource,
              hint: const Text("— Choose source —",
                  style: TextStyle(fontSize: 12)),
              isExpanded: true,
              items: _sources
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSource = value),
            ),
          ),
        ),
      ],
    );
  }

  // Tappable field that opens the 24-hour time picker for the reliever.
  Widget _timeField(String label, String? value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600)),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.neutral400),
                const SizedBox(width: 6),
                Text(
                  (value == null || value.isEmpty) ? "--:--" : value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (value == null || value.isEmpty)
                        ? AppColors.neutral400
                        : AppColors.neutral900,
                  ),
                ),
              ],
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

class BaLeaveSubType {
  final int id;
  final String name;

  BaLeaveSubType({required this.id, required this.name});

  factory BaLeaveSubType.fromJson(Map<String, dynamic> json) => BaLeaveSubType(
        id: BaAttendanceController._toInt(json['leaveSubTypeId']),
        name: (json['leaveSubTypeName'] ?? '').toString(),
      );
}

class BaLeaveType {
  final int id;
  final String name;
  final List<BaLeaveSubType> subTypes;

  BaLeaveType({required this.id, required this.name, required this.subTypes});

  factory BaLeaveType.fromJson(Map<String, dynamic> json) {
    final raw = (json['subTypes'] as List<dynamic>?) ?? [];
    return BaLeaveType(
      id: BaAttendanceController._toInt(json['leaveTypeId']),
      name: (json['leaveTypeName'] ?? '').toString(),
      subTypes: raw
          .map((e) =>
              BaLeaveSubType.fromJson((e as Map<String, dynamic>?) ?? {}))
          .toList(),
    );
  }
}

class BaRelieverEmployee {
  final String employeeCode;
  final String employeeName;
  final String brandName;
  final String displayName;

  BaRelieverEmployee({
    required this.employeeCode,
    required this.employeeName,
    required this.brandName,
    required this.displayName,
  });

  factory BaRelieverEmployee.fromJson(Map<String, dynamic> json) {
    final code = (json['employeeCode'] ?? '').toString();
    final name = (json['employeeName'] ?? '').toString();
    final brand = (json['brandName'] ?? '').toString();
    final display = (json['displayName'] ?? '').toString();
    return BaRelieverEmployee(
      employeeCode: code,
      employeeName: name,
      brandName: brand,
      displayName: display.isNotEmpty ? display : "$name ($code)",
    );
  }
}

class BaEmployee {
  final String id; // employeeCode
  final String name;
  final String brand; // brandName
  final String role;
  final String avatarInitials;
  final Color avatarColor;
  final AttendanceStatus status;
  final String? checkIn; // inTime
  final String? checkOut; // outTime
  final String phoneNumber;
  final String reliever; // "Y" / "N"

  // Editable / selection state
  String? absenceReason; // selected leave type name
  int? leaveTypeId;
  String? missedReason; // selected sub type name
  int? subTypeId;
  String? relieverId; // selected reliever displayName
  String? relieverEmployeeCode;
  String? customCheckIn;
  String? customCheckOut;

  // Manual reliever details (when "Reliever BA without ID" is chosen)
  String? nameWithoutId;
  String? mobileWithoutId;
  String? sourceWithoutId;

  // Reliever list fetch state (per row)
  List<BaRelieverEmployee> relieverOptions;
  bool relieverLoading;
  bool submitting;

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
    this.phoneNumber = "",
    this.reliever = "N",
    this.absenceReason,
    this.leaveTypeId,
    this.missedReason,
    this.subTypeId,
    this.relieverId,
    this.relieverEmployeeCode,
    this.customCheckIn,
    this.customCheckOut,
    List<BaRelieverEmployee>? relieverOptions,
    this.relieverLoading = false,
    this.submitting = false,
  }) : relieverOptions = relieverOptions ?? <BaRelieverEmployee>[];

  factory BaEmployee.fromApi(Map<String, dynamic> json, Color avatarColor) {
    final String code = (json['employeeCode'] ?? '').toString();
    final String empName = (json['employeeName'] ?? '').toString().trim();
    final String brandName = (json['brandName'] ?? '').toString();
    final String statusStr =
        (json['attendanceStatus'] ?? '').toString().trim().toUpperCase();
    final String inTime = (json['inTime'] ?? '').toString().trim();
    final String outTime = (json['outTime'] ?? '').toString().trim();

    AttendanceStatus status;
    switch (statusStr) {
      case 'PRESENT':
        status = AttendanceStatus.present;
        break;
      case 'ABSENT':
        status = AttendanceStatus.absent;
        break;
      default:
        status = AttendanceStatus.pending;
    }

    // A 12:00 AM in-time means the BA never really checked in, so it must be
    // treated as absent regardless of the status returned by the API.
    final String normalizedIn = inTime.replaceAll(' ', '').toUpperCase();
    if (normalizedIn == '12:00AM') {
      status = AttendanceStatus.absent;
    }

    return BaEmployee(
      id: code,
      name: empName,
      brand: brandName,
      role: "Brand Advisor",
      avatarInitials: _initials(empName),
      avatarColor: avatarColor,
      status: status,
      checkIn: inTime.isEmpty ? null : inTime,
      checkOut: outTime.isEmpty ? null : outTime,
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      reliever: (json['reliever'] ?? 'N').toString(),
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

// ----------------------------- SCREEN 3 WIDGET ---------------------------------
class BaAttendanceScreen extends StatelessWidget {
  BaAttendanceScreen({
    super.key,
    this.attendanceDay,
    this.staffCount,
    this.locationName,
    this.locationCode = '',
  });

  // Data passed from the dashboard card so it can be used on this screen.
  final AttendanceDay? attendanceDay;
  final StaffCount? staffCount;
  final String? locationName;

  // Location code selected on the DashboardScreen.
  final String locationCode;

  late final BaAttendanceController controller = _initController();

  BaAttendanceController _initController() {
    // Replace any cached controller so the date/location match this screen.
    if (Get.isRegistered<BaAttendanceController>()) {
      Get.delete<BaAttendanceController>();
    }
    return Get.put(BaAttendanceController(
      attendanceDate: _resolveDate(),
      initialLocationCode: locationCode,
      initialLocationName: locationName,
    ));
  }

  // yyyy-MM-dd date used for the GetBAAttendancePagebylocation request.
  String _resolveDate() {
    final date = attendanceDay?.date ?? DateTime.now();
    return DateFormat('yyyy-MM-dd').format(date);
  }

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
                          decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: const Center(
                              child: Text("←",
                                  style: TextStyle(
                                      fontSize: 16, color: AppColors.white))))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BA Staff Attendance",
                              style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white)),
                          const SizedBox(height: 2),
                          Obx(() => Text(_headerSubtitle(),
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.white.withOpacity(0.8))))
                        ]),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.brandOrange));
                }
                return Column(
                  children: [
                    _buildFilterBar(controller),
                    const SizedBox(
                      height: 6,
                    ),
                    Expanded(
                      child: controller.filteredEmployees.isEmpty
                          ? Center(
                              child: Text("No employees found.",
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppColors.neutral500)))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: controller.filteredEmployees.length,
                              itemBuilder: (context, index) {
                                final emp = controller.filteredEmployees[index];
                                return _buildEmployeeCard(
                                    emp, controller, context);
                              },
                            ),
                    ),
                  ],
                );
              }),
            ),
            // _buildBottomBar(controller),
          ],
        ),
      ),
    );
  }

  String _headerSubtitle() {
    final parts = <String>[];
    if (controller.locationName.value.isNotEmpty)
      parts.add(controller.locationName.value);
    final date = attendanceDay?.date;
    if (date != null) {
      final dayType = attendanceDay?.dayType;
      final pretty = DateFormat("dd MMM yyyy").format(date);
      parts.add(dayType != null && dayType.isNotEmpty
          ? "${dayType[0].toUpperCase()}${dayType.substring(1).toLowerCase()} · $pretty"
          : pretty);
    }
    parts.add("${controller.employees.length} employees");
    return parts.join(" · ");
  }

  Widget _buildFilterBar(BaAttendanceController controller) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip("All (${controller.employees.length})",
                AttendanceFilter.all, controller),
            const SizedBox(width: 8),
            _filterChip("Present (${controller.presentCount})",
                AttendanceFilter.present, controller),
            const SizedBox(width: 8),
            _filterChip("Absent (${controller.absentCount})",
                AttendanceFilter.absent, controller),
            const SizedBox(width: 8),
            _filterChip("Pending (${controller.pendingCount})",
                AttendanceFilter.pending, controller),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, AttendanceFilter filter,
      BaAttendanceController controller) {
    final isActive = controller.currentFilter.value == filter;
    return GestureDetector(
      onTap: () => controller.setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? _getFilterActiveColor(filter) : AppColors.white,
          border: Border.all(
              color: isActive
                  ? _getFilterActiveColor(filter)
                  : AppColors.neutral200,
              width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.neutral600)),
        // child: Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? _getFilterTextColor(filter) : AppColors.neutral600)),
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

  Widget _buildEmployeeCard(
      BaEmployee emp, BaAttendanceController controller, BuildContext context) {
    final isPresent = emp.status == AttendanceStatus.present;
    final isPending = emp.status == AttendanceStatus.pending;

    // Senior Developer Note: Prioritize the reliever status check.
    // If reliever is "N", we show a red border.
    final Color borderColor = emp.reliever == "N"
        ? AppColors.absentRed.withOpacity(0.3)
        : (isPresent
            ? AppColors.presentGreen.withOpacity(0.3)
            : (isPending
                ? AppColors.brandOrange.withOpacity(0.35)
                : AppColors.neutral200));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 2)
          ]),
      child: Column(
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          emp.avatarColor,
                          emp.avatarColor.withBlue(emp.avatarColor.blue - 20)
                        ]),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(emp.avatarInitials,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white)))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.name,
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral800)),
                        const SizedBox(height: 2),
                        Row(children: [
                          Text("${emp.role} · ${emp.brand}",
                              style: GoogleFonts.dmSans(
                                  fontSize: 11, color: AppColors.neutral500)),
                          const SizedBox(width: 6),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: AppColors.neutral200)),
                              child: Text(emp.id,
                                  style: GoogleFonts.dmMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.neutral500))),
                        ]),
                      ]),
                ),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: isPresent
                            ? AppColors.presentBg
                            : (isPending
                                ? AppColors.brandOrangeLight
                                : AppColors.absentBg),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                        isPresent
                            ? "Present"
                            : (isPending ? "Pending" : "Absent"),
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isPresent
                                ? AppColors.presentGreen
                                : (isPending
                                    ? AppColors.brandOrange
                                    : AppColors.absentRed)))),
              ],
            ),
          ),
          if (isPresent)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                border:
                    const Border(top: BorderSide(color: AppColors.neutral100)),
                color: const Color(0xFFFEF0E6).withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(children: [
                  Row(children: [
                    const Text("🟢", style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    const Text("In: ",
                        style: TextStyle(
                            fontSize: 11, color: AppColors.neutral600)),
                    Text(emp.checkIn ?? "--",
                        style: GoogleFonts.dmMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral800))
                  ]),
                  const SizedBox(width: 16),
                  Row(children: [
                    const Text("🔴", style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    const Text("Out: ",
                        style: TextStyle(
                            fontSize: 11, color: AppColors.neutral600)),
                    Text(emp.checkOut ?? "--",
                        style: GoogleFonts.dmMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral800))
                  ]),
                ]),
              ),
            ),
          if (isPending) _buildPendingSection(emp, controller, context),
        ],
      ),
    );
  }

  Widget _buildPendingSection(
      BaEmployee emp, BaAttendanceController controller, BuildContext context) {
    final selectedType = controller.selectedLeaveTypeFor(emp);
    final subTypes = selectedType?.subTypes ?? const <BaLeaveSubType>[];
    final hasReason =
        emp.absenceReason != null && emp.absenceReason!.isNotEmpty;
    final isRelieverWithout = controller.isRelieverWithoutId(emp);

    // Add this logic to identify if time should be hidden
    final String reason = emp.absenceReason?.toLowerCase() ?? "";
    final bool hideTime =
        reason.contains("week off") || reason.contains("planned leave");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: AppColors.neutral100)),
          color: const Color(0xFFFEF0E6).withOpacity(0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editable check-in / check-out times for pending rows.
          // Wrap Attendance Time in a conditional check
          if (!hideTime) ...[
            Text("⏱ Attendance Time",
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                    child:
                        _timeField(emp, controller, context, isCheckIn: true)),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _timeField(emp, controller, context, isCheckIn: false)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Reason dropdown (data-driven from API leaveTypes).
          Row(children: [
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.brandOrange, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text("Reason for Absence",
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600))
          ]),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutral200)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: hasReason ? emp.absenceReason : null,
                hint: const Text("— Choose reason —",
                    style: TextStyle(fontSize: 12)),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                items: controller.leaveTypes
                    .map((t) => DropdownMenuItem(
                        value: t.name,
                        child:
                            Text(t.name, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (value) =>
                    controller.updateAbsenceReason(emp.id, value),
              ),
            ),
          ),
          // Sub-type dropdown (leave types with sub types, except the
          // "without ID" case whose source is captured in the popup).
          if (subTypes.isNotEmpty && !isRelieverWithout)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📋 Select Detail",
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neutral200)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: emp.subTypeId,
                        hint: const Text("— Choose —",
                            style: TextStyle(fontSize: 12)),
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        items: subTypes
                            .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name,
                                    style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (value) {
                          final sub =
                              subTypes.firstWhereOrNull((s) => s.id == value);
                          controller.updateSubType(emp.id, sub);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Reliever employee dropdown (loaded on demand for "Reliever (with ID)").
          if (controller.needsRelieverWithId(emp))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🔁 Select Reliever Employee",
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  if (emp.relieverLoading)
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.brandOrange)))
                  else if (emp.relieverOptions.isEmpty)
                    Text("No relievers available.",
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: AppColors.neutral500))
                  else
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neutral200)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: emp.relieverEmployeeCode,
                          hint: const Text("— Choose reliever —",
                              style: TextStyle(fontSize: 12)),
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          items: emp.relieverOptions
                              .map((r) => DropdownMenuItem(
                                  value: r.employeeCode,
                                  child: Text(r.displayName,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (value) {
                            final r = emp.relieverOptions.firstWhereOrNull(
                                (x) => x.employeeCode == value);
                            controller.updateReliever(emp.id, r);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Reliever BA without ID -> manual details popup.
          if (isRelieverWithout)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () =>
                    controller.showRelieverWithoutIdPopup(context, emp),
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.brandOrangeLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.brandOrange.withOpacity(0.3))),
                    child: Center(
                        child: Text(
                            (emp.nameWithoutId != null &&
                                    emp.nameWithoutId!.isNotEmpty)
                                ? "✓ ${emp.nameWithoutId} · ${emp.sourceWithoutId ?? ''}"
                                : "+ Add Reliever Details",
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandOrange)))),
              ),
            ),
          // Per-row submit button.
          const SizedBox(height: 12),
          GestureDetector(
            onTap: emp.submitting ? null : () => controller.submitEmployee(emp),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: emp.submitting
                    ? AppColors.neutral300
                    : AppColors.brandBlueDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: emp.submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.white))
                    : Text("Submit",
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tappable time field that opens a 24-hour time picker. The value is stored
  // and displayed as 24h "HH:mm".
  Widget _timeField(
      BaEmployee emp, BaAttendanceController controller, BuildContext context,
      {required bool isCheckIn}) {
    final value = isCheckIn
        ? (emp.customCheckIn ?? emp.checkIn ?? "")
        : (emp.customCheckOut ?? emp.checkOut ?? "");
    final hasValue = value.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isCheckIn ? "CHECK IN" : "CHECK OUT",
            style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral500)),
        const SizedBox(height: 3),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickTime(emp, controller, context,
              isCheckIn: isCheckIn, current: value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue
                        ? value
                        : (isCheckIn ? "Select time" : "Select time"),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: hasValue
                          ? AppColors.neutral900
                          : AppColors.neutral400,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.neutral500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Opens an iOS-style (Cupertino) 24-hour time spinner in a bottom sheet and
  // stores the selected value as "HH:mm".
  Future<void> _pickTime(
      BaEmployee emp, BaAttendanceController controller, BuildContext context,
      {required bool isCheckIn, required String current}) async {
    final now = DateTime.now();
    DateTime initial =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final parts = current.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim().split(' ').first);
      if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
        initial = DateTime(now.year, now.month, now.day, h, m);
      }
    }

    DateTime selected = initial;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Cancel / title / Done
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: AppColors.neutral200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("Cancel",
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: AppColors.neutral500)),
                      ),
                      Text(isCheckIn ? "Check In" : "Check Out",
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900)),
                      CupertinoButton(
                        onPressed: () {
                          final formatted =
                              "${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}";
                          controller.setCustomTime(
                              emp.id, isCheckIn, formatted);
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Done",
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandOrange)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: initial,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BaAttendanceController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.neutral200))),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: controller.saveDraft,
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text("Save Draft",
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutral600)))))),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: GestureDetector(
                onTap: controller.submitAttendance,
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                        color: AppColors.brandBlueDeep,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x4D2563EB),
                              blurRadius: 12,
                              offset: Offset(0, 4))
                        ]),
                    child: Center(
                        child: Text("Submit Attendance",
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white))))),
          ),
        ],
      ),
    );
  }
}
