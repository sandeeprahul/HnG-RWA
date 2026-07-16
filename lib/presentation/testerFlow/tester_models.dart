import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'child_products_screen.dart';

class Product {
  final String sku;
  final String name;
  final String brand;
  final String category;

  Product({
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
  });
}

class Option {
  final int optionId;
  final String optionValue;

  Option({
    required this.optionId,
    required this.optionValue,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      optionId: json['Option_Id'] ?? 0,
      optionValue: json['Option_Value'] ?? '',
    );
  }
}

class ChildProduct {
  final String sku;
  final String name;
  AvailabilityStatus status;
  final AvailabilityStatus initialStatus;
  bool isSelected;
  String remarks;
  String
      availableOption; // This will hold the selected option's id or value? Let's check API: Available_Option is sent, so let's store the Option_Id? Or Option_Value? Let's check user's example: "Available_Option": ""

  ChildProduct({
    required this.sku,
    required this.name,
    this.status = AvailabilityStatus.pending,
    AvailabilityStatus? initialStatus,
    this.isSelected = false,
    this.remarks = '',
    this.availableOption = '',
  }) : initialStatus = initialStatus ?? status;
}

enum AvailabilityStatus { available, unavailable, pending }

class ScanHistoryItem {
  final String sku;
  final String name;
  final DateTime timestamp;

  ScanHistoryItem(
      {required this.sku, required this.name, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) =>
      ScanHistoryItem(
        sku: json['sku'],
        name: json['name'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class BrandSummary {
  final String brandName;
  final int totalCount;
  final int availableCount;
  final int notAvailableCount;
  final int pendingCount;

  BrandSummary({
    required this.brandName,
    required this.totalCount,
    required this.availableCount,
    required this.notAvailableCount,
    required this.pendingCount,
  });

  factory BrandSummary.fromJson(Map<String, dynamic> json) {
    return BrandSummary(
      brandName: json['BRAND_NAME'] ?? '',
      totalCount: json['Total_Count'] ?? 0,
      availableCount: json['Available_Count'] ?? 0,
      notAvailableCount: json['Not_Available_Count'] ?? 0,
      pendingCount: json['Pending_Count'] ?? 0,
    );
  }
}

class CategorySummary {
  final String execCatName;
  final int totalCount;
  final int availableCount;
  final int notAvailableCount;
  final int pendingCount;
  final int brandCount;
  final List<BrandSummary> brands;

  CategorySummary({
    required this.execCatName,
    required this.totalCount,
    required this.availableCount,
    required this.notAvailableCount,
    required this.pendingCount,
    required this.brandCount,
    required this.brands,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    List<BrandSummary> brandsList = [];
    if (json['brands'] != null) {
      brandsList = (json['brands'] as List)
          .map((item) => BrandSummary.fromJson(item))
          .toList();
    }
    return CategorySummary(
      execCatName: json['EXEC_CAT_NAME'] ?? '',
      totalCount: json['Total_Count'] ?? 0,
      availableCount: json['Available_Count'] ?? 0,
      notAvailableCount: json['Not_Available_Count'] ?? 0,
      pendingCount: json['Pending_Count'] ?? 0,
      brandCount: json['Brand_Count'] ?? 0,
      brands: brandsList,
    );
  }
}

class MasterSummary {
  final bool status;
  final String message;
  final String locationCode;
  final int categoryCount;
  final int totalCount;
  final int totalAvailableCount;
  final int totalNotAvailableCount;
  final int totalPendingCount;
  final List<CategorySummary> data;

  MasterSummary({
    required this.status,
    required this.message,
    required this.locationCode,
    required this.categoryCount,
    required this.totalCount,
    required this.totalAvailableCount,
    required this.totalNotAvailableCount,
    required this.totalPendingCount,
    required this.data,
  });

  factory MasterSummary.fromJson(Map<String, dynamic> json) {
    List<CategorySummary> dataList = [];
    if (json['data'] != null) {
      dataList = (json['data'] as List)
          .map((item) => CategorySummary.fromJson(item))
          .toList();
    }
    return MasterSummary(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      locationCode: json['location_code'] ?? '',
      categoryCount: json['category_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      totalAvailableCount: json['total_available_count'] ?? 0,
      totalNotAvailableCount: json['total_not_available_count'] ?? 0,
      totalPendingCount: json['total_pending_count'] ?? 0,
      data: dataList,
    );
  }
}

class TesterController extends GetxController {
  var storeCode = ''.obs;
  var locationName = ''.obs;
  var userCode = ''.obs;
  var todayScans = 0.obs;
  var productsUpdated = 0.obs;
  var recentScans = <ScanHistoryItem>[].obs;
  bool _prefsLoaded = false;
  var isLoadingMasterSummary = false.obs;
  var masterSummary = Rxn<MasterSummary>();

  @override
  void onInit() {
    super.onInit();
    loadFromPrefs();
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _applyTodayScanFilter(List<ScanHistoryItem> scans) {
    final now = DateTime.now();
    final validScans =
        scans.where((scan) => _isSameDay(scan.timestamp, now)).toList();
    recentScans.assignAll(validScans);
    todayScans.value = validScans.length;
  }

  Future<void> refreshRecentScansForToday() async {
    _applyTodayScanFilter(recentScans.toList());
    await _saveRecentScansToPrefs();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_prefsLoaded) {
      storeCode.value = prefs.getString('tester_location_code') ?? '';
      locationName.value = prefs.getString('tester_location_name') ?? '';
      userCode.value = prefs.getString('userCode') ?? '';
    }

    // Load recent scans and keep only scans from the current day.
    final scansJson = prefs.getString('tester_recent_scans');
    if (scansJson != null) {
      final List<dynamic> decoded = json.decode(scansJson);
      final allScans =
          decoded.map((item) => ScanHistoryItem.fromJson(item)).toList();

      _applyTodayScanFilter(allScans);

      // Update storage if we filtered anything out
      if (recentScans.length != allScans.length) {
        _saveRecentScansToPrefs();
      }
    } else {
      recentScans.clear();
      todayScans.value = 0;
    }
    _prefsLoaded = true;
  }

  Future<void> _saveRecentScansToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final scansJson =
        json.encode(recentScans.map((scan) => scan.toJson()).toList());
    await prefs.setString('tester_recent_scans', scansJson);
  }

  Future<void> updateLocation(String code, String name) async {
    // Persist using tester-specific keys so the main app location is untouched.
    storeCode.value = code;
    locationName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tester_location_code', code);
    await prefs.setString('tester_location_name', name);
  }

  Future<void> loadUserCode() async {
    if (userCode.value.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    userCode.value = prefs.getString('userCode') ?? '';
  }

  /// Fetches available locations and auto-selects if exactly one is returned.
  /// Returns true if a location is selected (already or auto-selected).
  Future<bool> fetchAndAutoSelectLocation() async {
    await loadFromPrefs();
    if (storeCode.value.isNotEmpty) return true;

    await loadUserCode();
    if (userCode.value.isEmpty) return false;

    try {
      final response = await http
          .get(
            Uri.parse(
                'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/GetLocation/${userCode.value}'),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final locations = (data['locations'] as List<dynamic>?) ?? [];
        if (locations.length == 1) {
          final location = locations.first;
          await updateLocation(
            location['locationCode']?.toString() ?? '',
            location['locationName']?.toString() ?? '',
          );
          return true;
        }
      }
    } catch (e) {
      debugPrint('Fetch locations error: $e');
    }
    return false;
  }

  void addScan(String sku, String name) {
    _applyTodayScanFilter(recentScans.toList());

    // Check for duplicates and remove old version
    recentScans.removeWhere((element) => element.sku == sku);

    recentScans.insert(
        0, ScanHistoryItem(sku: sku, name: name, timestamp: DateTime.now()));
    todayScans.value = recentScans.length;
    _saveRecentScansToPrefs();
  }

  Future<void> fetchMasterSummary() async {
    if (storeCode.value.isEmpty) return;

    isLoadingMasterSummary.value = true;
    try {
      final response = await http
          .get(
            Uri.parse(
                'https://rwaweb.healthandglowonline.co.in/Tester_sku/api/store-soh/master-summary?location_code=${storeCode.value}'),
          )
          .timeout(const Duration(seconds: 30));

      print('Master Summary Response: ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        masterSummary.value = MasterSummary.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('Error fetching master summary: $e');
    } finally {
      isLoadingMasterSummary.value = false;
    }
  }

  Future<void> fetchProductAndNavigate(String code, String locationCode,
      {bool isScanner = false, Function(bool)? setLoading}) async {
    final user = userCode.value;

    if (locationCode.isEmpty) {
      Get.back(); // Closes ScannerScreen
      Get.snackbar('No Location', 'Please select a store location first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    if (setLoading != null) setLoading(true);

    String extractedSku = code;

    try {
      // Resolve EAN to SKU via Enquiry API only when scanning.
      if (isScanner) {
        final enquiryUrl = Uri.parse(
            'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/Coupon/Newproductenquiry/$code/$locationCode/$user');
        final enquiryResponse = await http
            .get(enquiryUrl)
            .timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Enquiry request timed out.');
        });
        final forlog = json.decode(enquiryResponse.body);
        print("Enquiry Response: $forlog");

        if (enquiryResponse.statusCode == 200) {
          final enquiryData = json.decode(enquiryResponse.body);

          if (enquiryData['status'] == 'Success' &&
              enquiryData['product'] != null &&
              (enquiryData['product'] as List).isNotEmpty) {
            final firstProd = enquiryData['product'][0];
            final skuName = firstProd['skU_NAME']?.toString() ?? '';
            if (skuName.contains(' - ')) {
              extractedSku = skuName.split(' - ')[0].trim();
            }
          } else {
            if (isScanner) Get.back();
            Get.snackbar(
                'Not Found', enquiryData['status'] ?? 'Product not found.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white);
            return;
          }
        } else {
          if (isScanner) Get.back();
          Get.snackbar(
              'Error', 'Enquiry API error: ${enquiryResponse.statusCode}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          return;
        }
      }

      // Fetch tester-specific data from store-soh API
      final searchUrl = Uri.parse(
          'https://rwaweb.healthandglowonline.co.in/Tester_sku/api/store-soh/search?location_code=$locationCode&sku=$extractedSku');

      print("Search URL: $searchUrl");
      final searchResponse = await http
          .get(searchUrl)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Search request timed out.');
      });
      final forlogSearch = json.decode(searchResponse.body);
      print("Search Response: $forlogSearch");

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        if (searchData['status'] == true &&
            searchData['data'] != null &&
            (searchData['data'] as List).isNotEmpty) {
          final productList = (searchData['data'] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          // Parse options from API response
          final optionsList = (searchData['options'] as List<dynamic>?)
                  ?.map((item) => Option.fromJson(item as Map<String, dynamic>))
                  .toList() ??
              [];

          if (isScanner) {
            Get.off(() => ChildProductsScreen(
                  scannedSku: extractedSku,
                  productList: productList,
                  options: optionsList,
                ));
          } else {
            Get.to(() => ChildProductsScreen(
                  scannedSku: extractedSku,
                  productList: productList,
                  options: optionsList,
                ));
          }
        } else {
          if (isScanner) Get.back();
          Get.snackbar('Not Found',
              searchData['message'] ?? 'Product not found in tester database.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        if (isScanner) Get.back();
        Get.snackbar('Error', 'Search API error: ${searchResponse.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } on TimeoutException catch (e) {
      if (isScanner) Get.back();
      Get.snackbar('Timeout', e.message ?? 'Request timed out.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      if (isScanner) Get.back();
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      if (setLoading != null) setLoading(false);
    }
  }
}
