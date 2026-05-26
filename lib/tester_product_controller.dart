import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get/get.dart';

class ProductController extends GetxController {
  final Rx<ParentInfo> parentInfo = ParentInfo(
    storeId: '105060',
    parentSku: '506150',
    name: 'LAKROSEPOWDER',
    brand: 'LAKME|COSMETICS',
  ).obs;

  final RxList<ChildProduct> childProducts = <ChildProduct>[].obs;
  final RxList<ScanRecord> recentScans = <ScanRecord>[].obs;
  late RxInt todayScansCount = 0.obs;
  final RxString lastUpdated = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
    _updateLastUpdated();
  }

  void _loadDummyData() {
    childProducts.assignAll([
      ChildProduct(
        sku: '301114',
        shadeName: 'Soft Pink',
        status: ProductStatus.pending,
        isSelected: true,
      ),
      ChildProduct(
        sku: '301115',
        shadeName: 'RoseBlush',
        status: ProductStatus.available,
        isSelected: true,
      ),
      ChildProduct(
        sku: '301116',
        shadeName: 'Coral Dream',
        status: ProductStatus.unavailable,
        isSelected: true,
      ),
    ]);

    recentScans.assignAll([
      ScanRecord(
        barcode: '506150',
        productName: 'RosePowder',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ScanRecord(
        barcode: '573829',
        productName: 'LipStack',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ScanRecord(
        barcode: '574104',
        productName: 'Compact',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ]);
  }

  int get selectedCount => childProducts.where((p) => p.isSelected).length;
  String get selectedCountText => '$selectedCount of ${childProducts.length} selected';

  void toggleSelectAll() {
    final allSelected = selectedCount == childProducts.length;
    for (int i = 0; i < childProducts.length; i++) {
      childProducts[i] = childProducts[i].copyWith(isSelected: !allSelected);
    }
    childProducts.refresh();
  }

  void toggleSelection(int index) {
    childProducts[index] = childProducts[index].copyWith(
      isSelected: !childProducts[index].isSelected,
    );
    childProducts.refresh();
  }

  void confirmAllAvailable() {
    bool updated = false;
    for (int i = 0; i < childProducts.length; i++) {
      if (childProducts[i].isSelected && childProducts[i].status != ProductStatus.available) {
        childProducts[i] = childProducts[i].copyWith(status: ProductStatus.available);
        updated = true;
      }
    }
    if (updated) {
      childProducts.refresh();
      _updateLastUpdated();
      Get.snackbar(
        'Success',
        'Selected products marked as Available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  bool updateProductByBarcode(String barcode) {
    final index = childProducts.indexWhere((p) => p.sku == barcode);
    if (index != -1) {
      if (childProducts[index].status != ProductStatus.available) {
        childProducts[index] = childProducts[index].copyWith(status: ProductStatus.available);
        childProducts.refresh();
        _updateLastUpdated();
        return true;
      }
      return true;
    }
    return false;
  }

  void addScanRecord(String barcode, {String? productName}) {
    String name = productName ?? 'Unknown Product';
    final matched = childProducts.firstWhereOrNull((p) => p.sku == barcode);
    if (matched != null) name = matched.shadeName;

    // Avoid duplicate consecutive scans
    if (recentScans.isNotEmpty && recentScans.first.barcode == barcode) return;

    recentScans.insert(
      0,
      ScanRecord(
        barcode: barcode,
        productName: name,
        timestamp: DateTime.now(),
      ),
    );
    if (recentScans.length > 20) recentScans.removeLast();
    todayScansCount++;
    _updateLastUpdated();
  }

  void _updateLastUpdated() {
    final now = DateTime.now();
    lastUpdated.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String getLastUpdatedText() => 'Products Updated  •  ${lastUpdated.value}';
}

// lib/app/models/product_model.dart
enum ProductStatus { pending, available, unavailable }

extension ProductStatusExtension on ProductStatus {
  String get displayName {
    switch (this) {
      case ProductStatus.pending:
        return 'Pending';
      case ProductStatus.available:
        return 'Available';
      case ProductStatus.unavailable:
        return 'Unavailable';
    }
  }

  Color get color {
    switch (this) {
      case ProductStatus.pending:
        return Colors.orange;
      case ProductStatus.available:
        return Colors.green;
      case ProductStatus.unavailable:
        return Colors.red;
    }
  }
}

class ChildProduct {
  final String sku;
  final String shadeName;
  final ProductStatus status;
  final bool isSelected;

  ChildProduct({
    required this.sku,
    required this.shadeName,
    required this.status,
    this.isSelected = false,
  });

  ChildProduct copyWith({
    String? sku,
    String? shadeName,
    ProductStatus? status,
    bool? isSelected,
  }) {
    return ChildProduct(
      sku: sku ?? this.sku,
      shadeName: shadeName ?? this.shadeName,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ScanRecord {
  final String barcode;
  final String productName;
  final DateTime timestamp;

  ScanRecord({
    required this.barcode,
    required this.productName,
    required this.timestamp,
  });
}

class ParentInfo {
  final String storeId;
  final String parentSku;
  final String name;
  final String brand;

  ParentInfo({
    required this.storeId,
    required this.parentSku,
    required this.name,
    required this.brand,
  });
}