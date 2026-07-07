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

class ChildProduct {
  final String sku;
  final String name;
  AvailabilityStatus status;
  bool isSelected;

  ChildProduct({
    required this.sku,
    required this.name,
    this.status = AvailabilityStatus.pending,
    this.isSelected = false,
  });
}

enum AvailabilityStatus { available, unavailable, pending }

class ScanHistoryItem {
  final String sku;
  final String name;
  final DateTime timestamp;

  ScanHistoryItem({required this.sku, required this.name, required this.timestamp});
}

class TesterController extends GetxController {
  var storeCode = ''.obs;
  var locationName = ''.obs;
  var userCode = ''.obs;
  var todayScans = 0.obs;
  var productsUpdated = 0.obs;
  var recentScans = <ScanHistoryItem>[].obs;
  bool _prefsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    if (_prefsLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    storeCode.value = prefs.getString('tester_location_code') ?? '';
    locationName.value = prefs.getString('tester_location_name') ?? '';
    userCode.value = prefs.getString('userCode') ?? '';
    _prefsLoaded = true;
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
      final response = await http.get(
        Uri.parse(
            'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/GetLocation/${userCode.value}'),
      ).timeout(const Duration(seconds: 15));

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
    recentScans.insert(0, ScanHistoryItem(sku: sku, name: name, timestamp: DateTime.now()));
    todayScans.value++;
  }

  Future<void> fetchProductAndNavigate(String code, String locationCode,
      {bool isScanner = false, Function(bool)? setLoading}) async {
    final user = userCode.value;

    if (locationCode.isEmpty) {
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
        final enquiryResponse = await http.get(enquiryUrl).timeout(
            const Duration(seconds: 30), onTimeout: () {
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

      final searchResponse = await http.get(searchUrl).timeout(
          const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Search request timed out.');
      });
      final forlogSearch = json.decode(searchResponse.body);
      print("Search Response: $forlogSearch");

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        if (searchData['status'] == true &&
            searchData['data'] != null &&
            (searchData['data'] as List).isNotEmpty) {
          final product = searchData['data'][0] as Map<String, dynamic>;

          Get.off(() => ChildProductsScreen(
                scannedSku: extractedSku,
                productData: product,
              ));
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
        Get.snackbar(
            'Error', 'Search API error: ${searchResponse.statusCode}',
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
