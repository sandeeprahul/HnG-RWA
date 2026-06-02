// child_products_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_new_screen.dart';
import 'success_screen.dart';
import 'tester_models.dart';

class ChildProductsScreen extends StatefulWidget {
  final String scannedSku;

  const ChildProductsScreen({super.key, required this.scannedSku});

  @override
  State<ChildProductsScreen> createState() => _ChildProductsScreenState();
}

class _ChildProductsScreenState extends State<ChildProductsScreen> {
  late ChildProductsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChildProductsController(widget.scannedSku));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient (matches the design)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text("Back", style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Child Products",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Parent card (semi-transparent)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Parent SKU: ${controller.parentSku.value}",
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                        const SizedBox(height: 4),
                        Text(controller.parentName.value,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(controller.parentMeta.value,
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.7))),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            // Selection bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${controller.selectedCount.value} of ${controller.childProducts.length} selected",
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569))),
                  GestureDetector(
                    onTap: controller.toggleSelectAll,
                    child: Text(
                      controller.isAllSelected.value ? "Deselect All" : "☑ Select All",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF00A8A8)),
                    ),
                  ),
                ],
              )),
            ),
            // Child products list
            Expanded(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.childProducts.length,
                itemBuilder: (context, index) {
                  final child = controller.childProducts[index];
                  return _buildChildCard(child, index, controller);
                },
              )),
            ),
            // Bottom action bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => controller.confirmAvailability(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A8A8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      shadowColor: const Color(0xFF00A8A8).withOpacity(0.3),
                    ),
                    child: Text("✓ Confirm All Available", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Get.offAll(() =>  TesterNewScreen()), // Navigate back to home/scanner
                    child: Text("Scan Another Product", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(ChildProduct child, int index, ChildProductsController controller) {
    Color statusColor;
    String statusText;
    switch (child.status) {
      case AvailabilityStatus.available:
        statusColor = const Color(0xFF16A34A);
        statusText = "Available";
        break;
      case AvailabilityStatus.unavailable:
        statusColor = const Color(0xFFDC2626);
        statusText = "Unavailable";
        break;
      case AvailabilityStatus.pending:
        statusColor = const Color(0xFFD97706);
        statusText = "Pending";
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => controller.toggleSelection(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: child.isSelected ? const Color(0xFF00A8A8) : Colors.white,
                border: Border.all(color: child.isSelected ? const Color(0xFF00A8A8) : const Color(0xFFCBD5E1), width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: child.isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.sku, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(child.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B))),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(statusText,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- CONTROLLER FOR CHILD PRODUCTS ---------------------------------
class ChildProductsController extends GetxController {
  final String scannedSku;
  final parentSku = "506150".obs;
  final parentName = "LAK ROSE POWDER".obs;
  final parentMeta = "LAKME | COSMETICS".obs;

  final RxList<ChildProduct> childProducts = <ChildProduct>[
    ChildProduct(sku: "301114", name: "Soft Pink", status: AvailabilityStatus.pending),
    ChildProduct(sku: "301115", name: "Rose Blush", status: AvailabilityStatus.pending),
    ChildProduct(sku: "301116", name: "Coral Dream", status: AvailabilityStatus.pending),
    // Additional mock child products (if needed)
    ChildProduct(sku: "301117", name: "Peachy Keen", status: AvailabilityStatus.pending),
    ChildProduct(sku: "301118", name: "Berry Crush", status: AvailabilityStatus.pending),
  ].obs;

  RxInt selectedCount = 0.obs;
  RxBool isAllSelected = false.obs;

  ChildProductsController(this.scannedSku) {
    // In a real app, you'd fetch parent and child data from API using scannedSku
    // For now, we map based on scannedSku (mock)
    _loadDataForSku(scannedSku);
    _updateSelectionStatus();
  }

  void _loadDataForSku(String sku) {
    // Mock mapping: in production, call API
    if (sku == "506150") {
      parentSku.value = "506150";
      parentName.value = "LAK ROSE POWDER";
      parentMeta.value = "LAKME | COSMETICS";
      childProducts.assignAll([
        ChildProduct(sku: "301114", name: "Soft Pink", status: AvailabilityStatus.pending),
        ChildProduct(sku: "301115", name: "Rose Blush", status: AvailabilityStatus.pending),
        ChildProduct(sku: "301116", name: "Coral Dream", status: AvailabilityStatus.pending),
        ChildProduct(sku: "301117", name: "Peachy Keen", status: AvailabilityStatus.pending),
        ChildProduct(sku: "301118", name: "Berry Crush", status: AvailabilityStatus.pending),
      ]);
    } else if (sku == "573829") {
      parentSku.value = "573829";
      parentName.value = "LIP STACK";
      parentMeta.value = "NYX | LIPSTICK";
      childProducts.assignAll([
        ChildProduct(sku: "401001", name: "Red Velvet", status: AvailabilityStatus.pending),
        ChildProduct(sku: "401002", name: "Nude Beige", status: AvailabilityStatus.pending),
      ]);
    } else {
      // Default generic
      parentSku.value = sku;
      parentName.value = "GENERIC PRODUCT";
      parentMeta.value = "BRAND | CATEGORY";
      childProducts.assignAll([
        ChildProduct(sku: "999001", name: "Variant 1", status: AvailabilityStatus.pending),
        ChildProduct(sku: "999002", name: "Variant 2", status: AvailabilityStatus.pending),
      ]);
    }
    // Initially, all selected
    for (var child in childProducts) {
      child.isSelected = true;
    }
    _updateSelectionStatus();
  }

  void toggleSelection(int index) {
    childProducts[index].isSelected = !childProducts[index].isSelected;
    childProducts.refresh();
    _updateSelectionStatus();
  }

  void toggleSelectAll() {
    bool newSelectState = !isAllSelected.value;
    for (var child in childProducts) {
      child.isSelected = newSelectState;
    }
    childProducts.refresh();
    _updateSelectionStatus();
  }

  void _updateSelectionStatus() {
    int selected = childProducts.where((c) => c.isSelected).length;
    selectedCount.value = selected;
    isAllSelected.value = selected == childProducts.length && childProducts.isNotEmpty;
  }

  void confirmAvailability(BuildContext context) {
    // Mark selected products as available (or update their status)
    for (var child in childProducts) {
      if (child.isSelected) {
        child.status = AvailabilityStatus.available;
      } else {
        // Unselected remain as they were (e.g., pending/unavailable) – in real use, you might mark as unavailable
        if (child.status == AvailabilityStatus.pending) {
          child.status = AvailabilityStatus.unavailable;
        }
      }
    }
    // Update the global controller stats (Home screen)
    final TesterController testerController = Get.find<TesterController>();
    testerController.productsUpdated.value += selectedCount.value;
    testerController.addScan(parentSku.value, parentName.value);

    // Navigate to success screen with updated products list
    // Get.to(() => SuccessScreen(updatedProducts: childProducts.where((c) => c.isSelected).toList()));

    Get.to(() => SuccessScreen(
      updatedProducts: childProducts.where((c) => c.isSelected).toList().cast<ChildProduct>(),
    ));
  }
}

