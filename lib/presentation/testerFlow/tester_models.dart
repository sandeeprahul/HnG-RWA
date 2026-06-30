import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    storeCode.value = prefs.getString('locationCode') ?? '';
    locationName.value = prefs.getString('location_name') ?? '';
    userCode.value = prefs.getString('userCode') ?? '';
  }

  Future<void> updateLocation(String code, String name) async {
    final prefs = await SharedPreferences.getInstance();
    storeCode.value = code;
    locationName.value = name;
    await prefs.setString('locationCode', code);
    await prefs.setString('location_name', name);
  }

  void addScan(String sku, String name) {
    recentScans.insert(0, ScanHistoryItem(sku: sku, name: name, timestamp: DateTime.now()));
    todayScans.value++;
  }
}