import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/data/UserLocations.dart';
import 'package:hng_flutter/presentation/attendance/attendanceNewController.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../checkInOutScreen_TEMP.dart' show LocationSelectionModal;
import 'ba_attendance_screen.dart';
import 'staff_list_screen.dart';

// ----------------------------- DASHBOARD SCREEN (Screen 1) ---------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Base url for the attendance (RWAMOBILEAPIOMS) endpoints.
  static const String _omsBaseUrl =
      'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api';

  bool _isLoading = true;
  String? _errorMessage;

  String _locationName = "";
  List<AttendanceDay> _attendanceData = [];

  // Location selection state.
  List<UserLocations> _userLocations = [];
  List<UserLocations> _filteredLocations = [];
  UserLocations? _selectedLocation;
  final TextEditingController _locationSearchController =
      TextEditingController();
  bool _isLoadingLocations = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchLocations(autoOpenPicker: true);
  }

  /// Fetches the locations available to the logged-in user.
  /// If only one location is returned it is auto-selected, otherwise the
  /// selection popup is shown (when [autoOpenPicker] is true).
  Future<void> _fetchLocations({bool autoOpenPicker = false}) async {
    setState(() {
      _isLoadingLocations = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userCode");

      if (userId == null || userId.isEmpty) {
        setState(() {
          _isLoadingLocations = false;
          _isLoading = false;
          _errorMessage = "User not found. Please login again.";
        });
        return;
      }

      final url = '${Constants.apiHttpsUrl}/Login/GetLocation/$userId';
      print("URL FETCH LOCATIONS: $url");

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            (jsonDecode(response.body) as Map<String, dynamic>?) ?? {};

        if (data['statusCode']?.toString() == "200" &&
            data['status']?.toString() == "success") {
          final List<dynamic> jsonList =
              (data['locations'] as List<dynamic>?) ?? [];

          final List<UserLocations> locations = jsonList
              .map((json) =>
                  UserLocations.fromJson((json as Map<String, dynamic>?) ?? {}))
              .toList();

          setState(() {
            _userLocations = locations;
            _filteredLocations = List<UserLocations>.from(locations);
            _isLoadingLocations = false;
          });

          if (locations.isEmpty) {
            setState(() {
              _isLoading = false;
              _errorMessage = "No locations assigned to your account.";
            });
            return;
          }

          // Auto-select if exactly one location, else let the user pick.
          if (locations.length == 1) {
            await _onLocationSelected(locations.first);
          } else if (autoOpenPicker && _selectedLocation == null) {
            setState(() => _isLoading = false);
            _showLocationPicker();
          } else if (_selectedLocation != null) {
            await _fetchAttendanceCount(_selectedLocation!.locationCode);
          } else {
            setState(() => _isLoading = false);
            _showLocationPicker();
          }
        } else {
          setState(() {
            _isLoadingLocations = false;
            _isLoading = false;
            _errorMessage =
                "Failed to fetch locations (${data['statusCode'] ?? '-'}).";
          });
        }
      } else {
        setState(() {
          _isLoadingLocations = false;
          _isLoading = false;
          _errorMessage = "Server error (${response.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocations = false;
        _isLoading = false;
        _errorMessage = Constants.networkIssue;
      });
    }
  }

  /// Opens the location selection popup. Can be called any time the user
  /// wants to switch the active location.
  void _showLocationPicker() {
    // Reset the search list each time the picker opens.
    _locationSearchController.clear();
    _filteredLocations = List<UserLocations>.from(_userLocations);

    showDialog(
      context: context,
      barrierDismissible: _selectedLocation != null,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return LocationSelectionModal(
              filteredLocations: _filteredLocations,
              searchController: _locationSearchController,
              onSearchChanged: (query) {
                setModalState(() {
                  _filteredLocations = _userLocations
                      .where((location) =>
                          location.locationName
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          location.locationCode
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                      .toList();
                });
              },
              onLocationSelected: (location) {
                Navigator.of(dialogContext).pop();
                _onLocationSelected(location);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onLocationSelected(UserLocations location) async {
    setState(() {
      _selectedLocation = location;
      _locationName = location.locationName;
    });
    await _fetchAttendanceCount(location.locationCode);
  }

  String? _bannerMessage; // Add this variable
  Future<void> _fetchAttendanceCount(String locationCode) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _bannerMessage = null; // Reset message on new fetch
    });

    try {
      if (locationCode.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Please select a location.";
        });
        return;
      }

      final url =
          '$_omsBaseUrl/Login/StoreAttendancecount_bylocation/$locationCode';

      print("URL FETCH ATTENDANCE: $url");
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true) {
          final List<dynamic> rawList =
              (data['attendanceData'] as List<dynamic>?) ?? [];

          setState(() {
            _bannerMessage = data['message'];
            final respLocation = (data['locationName'] ?? "").toString();
            // Prefer the API's location name, fall back to the selected one.
            _locationName = respLocation.isNotEmpty
                ? respLocation
                : (_selectedLocation?.locationName ?? _locationName);
            _attendanceData = rawList
                .map((e) =>
                    AttendanceDay.fromJson((e as Map<String, dynamic>?) ?? {}))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage =
                (data['message'] ?? "Failed to fetch attendance.").toString();
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Server error (${response.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  // Header date e.g. "Saturday, 07 June 2026" – derived from TODAY if present, else first available day.
  // String get _headerDate {
  //   final DateTime? date = (_findDay("TODAY") ?? _firstDay)?.date;
  //   if (date == null) return "";
  //   return DateFormat("EEEE, dd MMMM yyyy").format(date);
  // }
  // String get _headerDate {
  //   // Look for TODAY first. If null, look for YESTERDAY. Fallback to the first item if both are null.
  //   final dayObj = _findDay("TODAY") ?? _findDay("YESTERDAY") ?? _firstDay;
  //   final DateTime? date = dayObj?.date;
  //
  //   if (date == null) return "";
  //   return DateFormat("EEEE, dd MMMM yyyy").format(date);
  // }

  String get _headerDate {
    final today = _findDay("TODAY");
    final yesterday = _findDay("YESTERDAY");

    // Prioritize Today, then Yesterday
    final dayObj = today ?? yesterday ?? _firstDay;
    if (dayObj?.date == null) return "";

    String dateStr = DateFormat("EEEE, dd MMMM yyyy").format(dayObj!.date!);

    // Optional: Add the label if it's not today to avoid confusion
    if (today == null && yesterday != null) {
      return "Yesterday, ${DateFormat("dd MMM").format(dayObj.date!)}";
    }

    return dateStr;
  }

  /// 3. Helper to find a specific day type from your parsed data list
  AttendanceDay? _findDay(String dayType) {
    try {
      return _attendanceData
          .firstWhere((element) => element.dayType == dayType);
    } catch (_) {
      return null; // Returns null cleanly if dayType is not found
    }
  }

  // AttendanceDay? _findDay(String dayType) {
  //   for (final day in _attendanceData) {
  //     if ((day.dayType ?? "").toUpperCase() == dayType.toUpperCase()) {
  //       return day;
  //     }
  //   }
  //   return null;
  // }
  //
  // AttendanceDay? get _firstDay =>
  //     _attendanceData.isNotEmpty ? _attendanceData.first : null;
  /// 4. Fallback helper to get the first available item in the list
  AttendanceDay? get _firstDay {
    return _attendanceData.isNotEmpty ? _attendanceData.first : null;
  }

  // Section label e.g. "Today · 07 Jun" or fallback to dayType.
  String _sectionLabel(AttendanceDay day) {
    final String typeLabel = _prettyDayType(day.dayType);
    if (day.date != null) {
      return "$typeLabel · ${DateFormat("dd MMM").format(day.date!)}";
    }
    return typeLabel;
  }

  String _prettyDayType(String? dayType) {
    switch ((dayType ?? "").toUpperCase()) {
      case "TODAY":
        return "Today";
      case "YESTERDAY":
        return "Yesterday";
      default:
        return (dayType == null || dayType.isEmpty) ? "Attendance" : dayType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.brandOrange,
        // Set status bar color
        statusBarIconBrightness: Brightness.light,
        // For white icons (time, battery)
        statusBarBrightness: Brightness.dark, // For iOS white icons
      ),
      child: Scaffold(
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
                    // Back button
                    GestureDetector(
                      onTap: () => Get.back(),
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
                    Expanded(
                      child: Column(
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
                            _headerSubtitle(),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Change location button (user can switch any time).
                    if (_userLocations.length > 1)
                      GestureDetector(
                        onTap: _isLoadingLocations ? null : _showLocationPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 14, color: AppColors.white),
                              const SizedBox(width: 4),
                              Text(
                                "Change",
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: _buildBody(),
              ),
              // Bottom Navigation Bar
              // _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  String _headerSubtitle() {
    final parts = <String>[];
    if (_locationName.isNotEmpty) parts.add(_locationName);
    if (_headerDate.isNotEmpty) parts.add(_headerDate);
    // return parts.isEmpty ? "Attendance overview" : parts.join("  ·  ");
    return parts.isEmpty ? "Attendance overview" : parts.join("  ·  ");
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandOrange),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("⚠️", style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_selectedLocation != null) {
                    _fetchAttendanceCount(_selectedLocation!.locationCode);
                  } else {
                    _fetchLocations(autoOpenPicker: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                ),
                child: Text(
                  "Retry",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_attendanceData.isEmpty) {
      return Center(
        child: Text(
          "No attendance records found.",
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.neutral500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // _buildInfoBanner(),
          if (!_isLoading && _errorMessage == null) _buildInfoBanner(),
          const SizedBox(height: 8),
          // Build a section per available day (handles missing TODAY/YESTERDAY).
          ..._attendanceData.expand((day) => _buildDaySection(day)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Builds a section (label + H&G card + BA card) for a single day.
  List<Widget> _buildDaySection(AttendanceDay day) {
    final bool isToday = (day.dayType ?? "").toUpperCase() == "TODAY";
    final DateType dateType = isToday ? DateType.today : DateType.yesterday;
    final String secondaryLabel = isToday ? "Pending" : "Absent";
    final String actionText = isToday ? "Record Now →" : "View Details →";

    final StaffCount hg = day.staffFor(1);
    final StaffCount ba = day.staffFor(2);

    return [
      const SizedBox(height: 8),
      _buildSectionLabel(_sectionLabel(day)),
      _buildAttendanceCard(
        cardType: CardType.hg,
        dateType: dateType,
        total: hg.total,
        presentCount: hg.present,
        // secondaryCount: hg.absent,
        secondaryCount:hg.pending,
        absentCount: hg.absent,
        secondaryLabel: secondaryLabel,
        actionText: actionText,
        iconEmoji: "🏪",
        title: hg.staffName.isNotEmpty ? hg.staffName : "H&G Staff",
        subtitle: "Store & Operations Team",
        day: day,
        staff: hg,
      ),
      const SizedBox(height: 8),
      _buildAttendanceCard(
        cardType: CardType.ba,
        dateType: dateType,
        total: ba.total,
        presentCount: ba.present,
        // secondaryCount: ba.absent,
        secondaryCount:  ba.pending,
        absentCount: ba.absent,

        secondaryLabel: secondaryLabel,
        actionText: actionText,
        iconEmoji: "💄",
        title: ba.staffName.isNotEmpty ? ba.staffName : "BA Staff",
        subtitle: "Brand Advisors",
        day: day,
        staff: ba,
      ),
      const SizedBox(height: 8),
    ];
  }

  // Info Banner Widget
  Widget _buildInfoBannerOLD() {
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
                    text:
                        ". You can view and update yesterday's records anytime.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    if (_bannerMessage == null || _bannerMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You can view and update today’s attendance anytime before 11 PM',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
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
    required AttendanceDay day,
    required StaffCount staff,
    required int absentCount,
  }) {
    Color borderColor = (cardType == CardType.hg)
        ? AppColors.brandBlue.withOpacity(0.2)
        : AppColors.brandOrange.withOpacity(0.2);

    return GestureDetector(
      onTap: () async {
        // staffType 2 = BA Staff -> BaAttendanceScreen
        // staffType 1 = H&G Staff -> HgAttendanceScreen
        if (cardType == CardType.ba) {
          await  Get.to(() => BaAttendanceScreen(
                attendanceDay: day,
                staffCount: staff,
                locationName: _locationName,
                locationCode: _selectedLocation?.locationCode ?? '',
              ));
        } else {
          await    Get.to(() => HgAttendanceScreen(
                attendanceDay: day,
                staffCount: staff,
                locationName: _locationName,
                locationCode: _selectedLocation?.locationCode ?? '',
              ));
        }

        // This line runs ONLY after coming back from BaAttendanceScreen or HgAttendanceScreen
        if (_selectedLocation != null) {
          print("Refreshing attendance counts after return...");
          await _fetchAttendanceCount(_selectedLocation!.locationCode);
        }
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
                    child: Center(
                        child: Text(iconEmoji,
                            style: const TextStyle(fontSize: 14))),
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
                  _buildStatCell("$absentCount", "Absent",
                      color: AppColors.absentRed),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
  Widget _buildStatCell(String number, String label,
      {Color? color, bool isSecondary = false}) {
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

  Widget _buildNavItem(String icon, String label, bool isActive,
      {bool hasIconBg = false}) {
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
                        color: isActive
                            ? AppColors.brandOrange
                            : AppColors.neutral400,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  icon,
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        isActive ? AppColors.brandOrange : AppColors.neutral400,
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      isActive ? AppColors.brandOrange : AppColors.neutral400,
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

// ----------------------------- API MODELS (null-safe) ---------------------------------
class AttendanceDay {
  final DateTime? date;
  final String? dayType;
  final List<StaffCount> staffCounts;

  AttendanceDay({
    required this.date,
    required this.dayType,
    required this.staffCounts,
  });

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    final rawDate = json['attendanceDate']?.toString();
    DateTime? parsedDate;
    if (rawDate != null && rawDate.isNotEmpty) {
      // Take only the "2026-06-07" part to avoid timezone shifts
      parsedDate = DateTime.tryParse(rawDate.split('T')[0]);
    }

    final rawStaff = (json['staffCounts'] as List<dynamic>?) ?? [];

    return AttendanceDay(
      // date: rawDate == null ? null : DateTime.tryParse(rawDate),
      dayType: json['dayType']?.toString(),

      date: parsedDate,
      staffCounts: rawStaff
          .map((e) => StaffCount.fromJson((e as Map<String, dynamic>?) ?? {}))
          .toList(),
    );
  }

  // Returns the staff count for a given staffType, or an empty (zero) one if absent.
  StaffCount staffFor(int staffType) {
    for (final s in staffCounts) {
      if (s.staffType == staffType) return s;
    }
    return StaffCount.empty();
  }
}

class StaffCount {
  final int staffType;
  final String staffName;
  final int total;
  final int present;
  final int absent;
  final int pending; // 1. Add this field

  StaffCount({
    required this.staffType,
    required this.staffName,
    required this.total,
    required this.present,
    required this.absent,
    required this.pending, // 2. Add to constructor
  });

  factory StaffCount.empty() => StaffCount(
        staffType: 0,
        staffName: "",
        total: 0,
        present: 0,
        absent: 0,
        pending: 0, // 3. Update empty state
      );

  factory StaffCount.fromJson(Map<String, dynamic> json) {
    return StaffCount(
      staffType: _toInt(json['staffType']),
      staffName: json['staffName']?.toString() ?? "",
      total: _toInt(json['total']),
      present: _toInt(json['present']),
      absent: _toInt(json['absent']),
      pending: _toInt(json['pending']), // 4. Parse from JSON
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
