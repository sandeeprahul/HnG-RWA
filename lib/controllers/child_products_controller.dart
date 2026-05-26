import 'package:get/get.dart';

class ChildProduct {
  final String id;
  final String name;
  final String sku;
  final String status;

  // Make this property reactive
  final RxBool rxIsSelected;

  ChildProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.status,
    bool isSelected = false,
  }) : rxIsSelected = isSelected.obs;

  // Shortcut getter/setter for cleaner code syntax
  bool get isSelected => rxIsSelected.value;
  set isSelected(bool val) => rxIsSelected.value = val;
}

class ChildProductsController extends GetxController {
  var childProducts = <ChildProduct>[].obs;
  var isLoading = false.obs;
  var selectedCount = 0.obs;
  var availableCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock data similar to the image
    childProducts.addAll([
      ChildProduct(id: '1', name: 'Child Product 1', sku: 'SKU001', status: 'pending'),
      ChildProduct(id: '2', name: 'Child Product 2', sku: 'SKU002', status: 'available'),
      ChildProduct(id: '3', name: 'Child Product 3', sku: 'SKU003', status: 'unavailable'),
      ChildProduct(id: '4', name: 'Child Product 4', sku: 'SKU004', status: 'pending'),
      ChildProduct(id: '5', name: 'Child Product 5', sku: 'SKU005', status: 'available'),
      ChildProduct(id: '6', name: 'Child Product 6', sku: 'SKU006', status: 'pending'),
      ChildProduct(id: '7', name: 'Child Product 7', sku: 'SKU007', status: 'available'),
      ChildProduct(id: '8', name: 'Child Product 8', sku: 'SKU008', status: 'unavailable'),
    ]);
    _updateCounts();
  }

  void toggleProductSelection(String id) {
    final index = childProducts.indexWhere((item) => item.id == id);
    if (index != -1) {
      // Create a copy of the object with the modified value
      // childProducts[index] = childProducts[index].copyWith(
      //   isSelected: !childProducts[index].isSelected,
      // );

      // Forces the outer Obx on the Screen to redraw the list
      childProducts.refresh();
    }
  }

  void selectAllAvailable() {
    for (var product in childProducts) {
      if (product.status == 'available') {
        product.isSelected = true;
      }
    }
    _updateCounts();
    childProducts.refresh();
  }

  // void updateProductStatus(String productId, String newStatus) {
  //   final product = childProducts.firstWhereOrNull((p) => p.id == productId);
  //   if (product != null) {
  //     product.status = newStatus;
  //     _updateCounts();
  //     childProducts.refresh();
  //   }
  // }

  void _updateCounts() {
    selectedCount.value = childProducts.where((p) => p.isSelected).length;
    availableCount.value = childProducts.where((p) => p.status == 'available').length;
  }

  void confirmAllAvailable() {
    selectAllAvailable();
    // Here you would typically make an API call to confirm the selection
    Get.snackbar('Success', 'All available products confirmed');
  }

  void scanAnotherProduct() {
    // Here you would typically navigate to a scanner screen
    Get.snackbar('Info', 'Scanning another product');
  }
}
