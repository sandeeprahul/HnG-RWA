// child_products_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_new_screen.dart';
import 'package:http/http.dart' as http;
import 'success_screen.dart';
import 'tester_models.dart';

class ChildProductsScreen extends StatefulWidget {
  final String scannedSku;
  final Map<String, dynamic>? productData;

  const ChildProductsScreen({
    super.key,
    required this.scannedSku,
    this.productData,
  });

  @override
  State<ChildProductsScreen> createState() => _ChildProductsScreenState();
}

class _ChildProductsScreenState extends State<ChildProductsScreen> {
  late ChildProductsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ChildProductsController(widget.scannedSku, widget.productData),
      tag: widget.scannedSku,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Make status bar transparent to show gradient
        statusBarIconBrightness: Brightness.light, // White icons
        statusBarBrightness: Brightness.dark, // For iOS
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1E3A5F),

        body: SafeArea(
          top: false, // Allows content to sit behind the status bar
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
                // Header with gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 4),
                            Text("Tester Confirmation",
                                style: GoogleFonts.inter(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      // Parent product card — real data from API
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Obx(() => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image from API
                                if (controller.productImageUrl.value.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      controller.productImageUrl.value,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Icon(Icons.broken_image,
                                            color: Colors.white54, size: 40),
                                      ),
                                    ),
                                  ),
                                if (controller.productImageUrl.value.isNotEmpty)
                                  const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "SKU: ${controller.parentSku.value}",
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color:
                                                Colors.white.withOpacity(0.8)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller.parentName.value,
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      // Availability badge
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: controller.availability
                                                          .value ==
                                                      'Available'
                                                  ? Colors.green.withOpacity(0.8)
                                                  : Colors.red.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              controller.availability.value,
                                              style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (controller.rangeStatus.value.isNotEmpty)
                                            Text(
                                              controller.rangeStatus.value,
                                              style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.7)),
                                            ),
                                        ],
                                      ),
                                      if (controller.daysOfSale.value.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'Stock: ${controller.daysOfSale.value} days',
                                            style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: Colors.white
                                                    .withOpacity(0.7)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ),
                      // Promotion banner from API
                      Obx(() => controller.promotion.value.isNotEmpty &&
                              controller.promotion.value != 'null'
                          ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      controller.promotion.value,
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox()),
                    ],
                  ),
                ),
                // Selection bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${controller.selectedCount.value} of ${controller.childProducts.length} selected",
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF475569))),
                          GestureDetector(
                            onTap: controller.toggleSelectAll,
                            child: Text(
                              controller.isAllSelected.value
                                  ? "Deselect All"
                                  : "☑ Select All",
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF00A8A8)),
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
                    border:
                        Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            controller.confirmAvailability(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A8A8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text("✓ Confirm Tester Available",
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Get.offAll(() => const TesterNewScreen()),
                        child: Text("Scan Another Product",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF64748B))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(
      ChildProduct child, int index, ChildProductsController controller) {
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
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.toggleSelection(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: child.isSelected
                    ? const Color(0xFF00A8A8)
                    : Colors.white,
                border: Border.all(
                    color: child.isSelected
                        ? const Color(0xFF00A8A8)
                        : const Color(0xFFCBD5E1),
                    width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: child.isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.sku,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(child.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(statusText,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- CONTROLLER FOR CHILD PRODUCTS ---------------------------------
class ChildProductsController extends GetxController {
  final String scannedSku;
  final Map<String, dynamic>? productData;

  final parentSku = ''.obs;
  final parentName = ''.obs;
  final productImageUrl = ''.obs;
  final availability = ''.obs;
  final rangeStatus = ''.obs;
  final daysOfSale = ''.obs;
  final promotion = ''.obs;

  final RxList<ChildProduct> childProducts = <ChildProduct>[].obs;
  RxInt selectedCount = 0.obs;
  RxBool isAllSelected = false.obs;

  ChildProductsController(this.scannedSku, this.productData) {
    _loadFromProductData();
  }

  void _loadFromProductData() {
    final data = productData;
    if (data != null) {
      parentSku.value = data['SKU_CODE']?.toString() ?? scannedSku;
      parentName.value = data['SKU_NAME']?.toString() ?? 'Unknown Product';
      productImageUrl.value = data['productImageUrl']?.toString() ?? '';
      availability.value = data['AVAILABLE'] == 'Y' ? 'Available' : 'Unavailable';
      rangeStatus.value = data['BRAND_NAME']?.toString() ?? '';
      daysOfSale.value = data['daysOfSale']?.toString() ?? '';
      promotion.value = data['EXEC_CAT_NAME']?.toString() ?? '';
    } else {
      parentSku.value = scannedSku;
      parentName.value = 'Unknown Product';
    }

    // Seed child list with the scanned product itself as the item to confirm
    childProducts.assignAll([
      ChildProduct(
        sku: parentSku.value,
        name: parentName.value,
        status: AvailabilityStatus.pending,
        isSelected: true,
      ),
    ]);
    _updateSelectionStatus();
  }

  void toggleSelection(int index) {
    childProducts[index].isSelected = !childProducts[index].isSelected;
    childProducts.refresh();
    _updateSelectionStatus();
  }

  void toggleSelectAll() {
    final newState = !isAllSelected.value;
    for (var child in childProducts) {
      child.isSelected = newState;
    }
    childProducts.refresh();
    _updateSelectionStatus();
  }

  void _updateSelectionStatus() {
    final selected = childProducts.where((c) => c.isSelected).length;
    selectedCount.value = selected;
    isAllSelected.value =
        selected == childProducts.length && childProducts.isNotEmpty;
  }

  Future<void> confirmAvailability(BuildContext context) async {
    final TesterController testerController = Get.find<TesterController>();
    final locationCode = testerController.storeCode.value;
    final userCode = testerController.userCode.value;

    List<ChildProduct> selected =
        childProducts.where((c) => c.isSelected).toList();

    if (selected.isEmpty) {
      Get.snackbar('No Selection', 'Please select at least one product.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    // Show loading dialog
    Get.dialog(
      const Center(
          child: CircularProgressIndicator(
        color: Color(0xFF00A8A8),
      )),
      barrierDismissible: false,
    );

    try {
      final List<Map<String, String>> skuDetails = selected.map((child) {
        return {
          "sku_code": child.sku,
          "available": "Y",
          "remarks": "Confirmed via App",
          "available_option": ">75% consumption"
        };
      }).toList();

      final response = await http
          .post(
            Uri.parse(
                'https://rwaweb.healthandglowonline.co.in/Tester_sku/api/store-soh/update'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "location_code": locationCode,
              "created_by": userCode,
              "sku_details": skuDetails
            }),
          )
          .timeout(const Duration(seconds: 30));

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        print("store-soh/update : response: $resData");

        if (resData['status'] == true) {
          for (var child in selected) {
            child.status = AvailabilityStatus.available;
          }
          testerController.productsUpdated.value += selected.length;
          testerController.addScan(parentSku.value, parentName.value);

          Get.to(() => SuccessScreen(
                updatedProducts: selected,
              ));
        } else {
          Get.snackbar('Update Failed',
              resData['message'] ?? 'Unable to update tester availability.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
