import 'package:get/get.dart';

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
  var storeCode = "105060".obs;
  var todayScans = 15.obs;
  var productsUpdated = 42.obs;
  var recentScans = <ScanHistoryItem>[
    ScanHistoryItem(sku: "506150", name: "Rose Powder", timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
    ScanHistoryItem(sku: "573829", name: "Lip Stack", timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
    ScanHistoryItem(sku: "574104", name: "Compact", timestamp: DateTime.now().subtract(const Duration(hours: 1))),
  ].obs;

  // Called after successful scan – will be used in Scanner screen
  void addScan(String sku, String name) {
    recentScans.insert(0, ScanHistoryItem(sku: sku, name: name, timestamp: DateTime.now()));
    todayScans.value++;
  }
}