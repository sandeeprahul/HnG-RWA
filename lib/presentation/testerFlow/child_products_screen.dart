// child_products_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/store_dashboard_screen.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_new_screen.dart';
import 'package:http/http.dart' as http;
import 'success_screen.dart';
import 'tester_models.dart';

class ChildProductsScreen extends StatefulWidget {
  final String scannedSku;
  final List<Map<String, dynamic>>? productList;
  final List<Option> options;

  const ChildProductsScreen({
    super.key,
    required this.scannedSku,
    this.productList,
    required this.options,
  });

  @override
  State<ChildProductsScreen> createState() => _ChildProductsScreenState();
}

class _ChildProductsScreenState extends State<ChildProductsScreen>
    with WidgetsBindingObserver {
  late ChildProductsController controller;
  late List<Option> _options;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _options = widget.options;
    controller = Get.put(
      ChildProductsController(widget.scannedSku, widget.productList, _options),
      tag: widget.scannedSku,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clear the controller when leaving the screen so it's fresh when revisited
    Get.delete<ChildProductsController>(tag: widget.scannedSku);
    super.dispose();
  }

  /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app is resumed
      _refreshData();
    }
  }*/

  // Future<void> _refreshData() async {
  //   final newOptions = await controller.refresh();
  //   if (newOptions != null && mounted) {
  //     setState(() {
  //       _options = newOptions;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Make status bar transparent to show gradient
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
                                style: GoogleFonts.outfit(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "",
                        style: GoogleFonts.outfit(
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
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "SKU: ${controller.scannedSku.toString()}",
                                        style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color:
                                                Colors.white.withOpacity(0.8)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller.parentName.value,
                                        style: GoogleFonts.outfit(
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
                                              color: controller
                                                          .availability.value ==
                                                      'Available'
                                                  ? Colors.green
                                                      .withOpacity(0.8)
                                                  : controller.availability
                                                              .value ==
                                                          'Pending'
                                                      ? Colors.orange
                                                          .withOpacity(0.8)
                                                      : Colors.red
                                                          .withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              controller.availability.value,
                                              style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (controller
                                              .rangeStatus.value.isNotEmpty)
                                            Text(
                                              controller.rangeStatus.value,
                                              style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.7)),
                                            ),
                                        ],
                                      ),
                                      if (controller
                                          .daysOfSale.value.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'Stock: ${controller.daysOfSale.value} days',
                                            style: GoogleFonts.outfit(
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
                                      style: GoogleFonts.outfit(
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
                              "${controller.availableCount.value} Available, ${controller.pendingCount.value} Pending, ${controller.unavailableCount.value} Not Available",
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: const Color(0xFF475569))),
                          GestureDetector(
                            onTap: controller.markAllAvailable,
                            child: Row(
                              children: [
                                const Icon(Icons.done_all,
                                    size: 16, color: Color(0xFF00A8A8)),
                                const SizedBox(width: 4),
                                Text(
                                  "Mark All Available",
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF00A8A8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                // Child products list
                Expanded(
                  child: Obx(() => RefreshIndicator(
                        onRefresh: () async {
                          final newOptions = await controller.refresh();
                          if (newOptions != null && mounted) {
                            setState(() {
                              _options = newOptions;
                            });
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.childProducts.length,
                          itemBuilder: (context, index) {
                            final child = controller.childProducts[index];
                            return _buildChildCard(
                                child, index, controller, _options);
                          },
                        ),
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
                        onPressed: () => controller.confirmAvailability(
                            context, widget.scannedSku),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A8A8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text("✓ SUBMIT",
                            style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: Text("Confirm",
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold)),
                              content: Text(
                                  "Are you sure you want to scan another product? Your current progress will be lost.",
                                  style: GoogleFonts.outfit()),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text("Cancel",
                                      style: GoogleFonts.outfit(
                                          color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back(); // Close dialog
                                    Get.back(); // Close ChildProductsScreen
                                  },
                                  child: Text("Continue",
                                      style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text("Scan Another Product",
                            style: GoogleFonts.outfit(
                                fontSize: 13, color: const Color(0xFF64748B))),
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

  Widget _buildChildCard(ChildProduct child, int index,
      ChildProductsController controller, List<Option> options) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.sku,
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: const Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text(child.name,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B))),
                    if (child.remarks.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        child.remarks,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.edit, size: 18, color: Color(0xFF64748B)),
                onPressed: () => controller.showRemarksDialog(context, index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status Selector
          Row(
            children: [
              _buildStatusOption(
                  "Not Available",
                  AvailabilityStatus.unavailable,
                  const Color(0xFFDC2626),
                  index,
                  controller),
              const SizedBox(width: 8),
              _buildStatusOption("Pending", AvailabilityStatus.pending,
                  const Color(0xFFD97706), index, controller),
              const SizedBox(width: 8),
              _buildStatusOption("Available", AvailabilityStatus.available,
                  const Color(0xFF16A34A), index, controller),
            ],
          ),
          if (options.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: child.availableOption,
                  isExpanded: true,
                  items: _buildDropdownItems(child.availableOption, options),
                  onChanged: (value) {
                    controller.updateAvailableOption(index, value ?? '');
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      String currentValue, List<Option> options) {
    final List<DropdownMenuItem<String>> items = [];

    // 1. Add the default placeholder
    items.add(
      DropdownMenuItem<String>(
        value: "",
        child: Text(
          "Select an option",
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );

    final Set<String> addedValues = {""};

    // 2. Crucial Senior Dev Logic: Always ensure the currentValue is in the list
    // This prevents the "There should be exactly one item with [DropdownButton]'s value" crash
    // if the value from the data isn't in the options list.
    if (currentValue.isNotEmpty && !addedValues.contains(currentValue)) {
      items.add(
        DropdownMenuItem<String>(
          value: currentValue,
          child: Text(
            currentValue,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w600, // Highlight current value
            ),
          ),
        ),
      );
      addedValues.add(currentValue);
    }

    // 3. Add available options from API, avoiding duplicates
    for (var option in options) {
      if (option.optionValue.isNotEmpty &&
          !addedValues.contains(option.optionValue)) {
        items.add(
          DropdownMenuItem<String>(
            value: option.optionValue,
            child: Text(
              option.optionValue,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        );
        addedValues.add(option.optionValue);
      }
    }

    return items;
  }

  Widget _buildStatusOption(String label, AvailabilityStatus status,
      Color color, int index, ChildProductsController controller) {
    final isSelected = controller.childProducts[index].status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.updateStatus(index, status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------- CONTROLLER FOR CHILD PRODUCTS ---------------------------------
class ChildProductsController extends GetxController {
  final String scannedSku;
  final List<Map<String, dynamic>>? productList;
  final List<Option> initialOptions;

  final parentSku = ''.obs;
  final parentName = ''.obs;
  final productImageUrl = ''.obs;
  final availability = ''.obs;
  final rangeStatus = ''.obs;
  final daysOfSale = ''.obs;
  final promotion = ''.obs;

  final RxList<Option> options = <Option>[].obs;
  final RxList<ChildProduct> childProducts = <ChildProduct>[].obs;
  RxInt selectedCount = 0.obs;
  RxInt availableCount = 0.obs;
  RxInt pendingCount = 0.obs;
  RxInt unavailableCount = 0.obs;
  RxBool isAllSelected = false.obs;

  ChildProductsController(
      this.scannedSku, this.productList, this.initialOptions) {
    options.assignAll(initialOptions);
    _loadFromProductData();
  }

  void _loadFromProductData() {
    final list = productList;
    if (list != null && list.isNotEmpty) {
      // Try to find a product where PARENT_SKU_CODE or SKU_CODE matches the scanned SKU as parent
      Map<String, dynamic>? parentProduct;

      // First check for a product where PARENT_SKU_CODE == scannedSku
      parentProduct = list.firstWhereOrNull(
          (p) => p['PARENT_SKU_CODE']?.toString() == scannedSku);

      // If not found, check for product where SKU_CODE == scannedSku
      parentProduct ??=
          list.firstWhereOrNull((p) => p['SKU_CODE']?.toString() == scannedSku);

      // If still not found, just use the first product
      parentProduct ??= list.first;

      // Set parent product details
      parentSku.value = parentProduct['SKU_CODE']?.toString() ?? scannedSku;
      parentName.value = parentProduct['Product_Group_name']?.toString() ??
          parentProduct['SKU_NAME']?.toString() ??
          'Unknown Product';
      productImageUrl.value =
          parentProduct['productImageUrl']?.toString() ?? '';

      // Update availability logic: Y=Available, N=Not available, other=Pending
      String availabilityValue = parentProduct['AVAILABLE']?.toString() ?? '';
      if (availabilityValue == 'Y') {
        availability.value = 'Available';
      } else if (availabilityValue == 'N') {
        availability.value = 'Not available';
      } else {
        availability.value = 'Pending';
      }

      rangeStatus.value = parentProduct['BRAND_NAME']?.toString() ?? '';
      daysOfSale.value = parentProduct['daysOfSale']?.toString() ?? '';
      promotion.value = parentProduct['EXEC_CAT_NAME']?.toString() ?? '';

      // Load all products as child products with proper status logic
      childProducts.assignAll(list.map((p) {
        String available = p['AVAILABLE']?.toString() ?? '';
        AvailabilityStatus status;
        if (available == 'Y') {
          status = AvailabilityStatus.available;
        } else if (available == 'N') {
          status = AvailabilityStatus.unavailable;
        } else {
          status = AvailabilityStatus.pending;
        }

        String opt = p['Available_Option']?.toString() ?? '';
        // If opt is an ID, find the corresponding value
        final matchingOption =
            options.firstWhereOrNull((o) => o.optionId.toString() == opt);
        if (matchingOption != null) {
          opt = matchingOption.optionValue;
        }

        return ChildProduct(
          sku: p['SKU_CODE']?.toString() ?? '',
          name: p['SKU_NAME']?.toString() ?? 'Unknown',
          status: status,
          isSelected: status == AvailabilityStatus.available,
          remarks: p['REMARKS']?.toString() ?? '',
          availableOption: opt,
        );
      }).toList());
    } else {
      parentSku.value = scannedSku;
      parentName.value = 'Unknown Product';

      // Fallback to single product
      childProducts.assignAll([
        ChildProduct(
          sku: parentSku.value,
          name: parentName.value,
          status: AvailabilityStatus.pending,
          isSelected: true,
        ),
      ]);
    }

    _updateSelectionStatus();
  }

  Future<List<Option>?> refresh() async {
    // Re-fetch the product data
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    final testerController = Get.find<TesterController>();
    await testerController.loadFromPrefs();
    await testerController.loadUserCode();
    final locationCode = testerController.storeCode.value;

    if (locationCode.isEmpty) {
      Get.snackbar('No Location', 'Please select a store location first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return null;
    }

    try {
      final searchUrl = Uri.parse(
          'https://rwaweb.healthandglowonline.co.in/Tester_sku/api/store-soh/search?location_code=$locationCode&sku=$scannedSku');

      print("Refresh Search URL: $searchUrl");
      final searchResponse =
          await http.get(searchUrl).timeout(const Duration(seconds: 30));
      final searchData = json.decode(searchResponse.body);

      if (searchResponse.statusCode == 200 &&
          searchData['status'] == true &&
          searchData['data'] != null &&
          (searchData['data'] as List).isNotEmpty) {
        final newProductList = (searchData['data'] as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        final newOptions = (searchData['options'] as List<dynamic>?)
                ?.map((item) => Option.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        options.assignAll(newOptions);

        final list = newProductList;
        Map<String, dynamic>? parentProduct;
        parentProduct = list.firstWhereOrNull(
            (p) => p['PARENT_SKU_CODE']?.toString() == scannedSku);
        parentProduct ??= list
            .firstWhereOrNull((p) => p['SKU_CODE']?.toString() == scannedSku);
        parentProduct ??= list.first;

        parentSku.value = parentProduct['SKU_CODE']?.toString() ?? scannedSku;
        parentName.value = parentProduct['Product_Group_name']?.toString() ??
            parentProduct['SKU_NAME']?.toString() ??
            'Unknown Product';
        productImageUrl.value =
            parentProduct['productImageUrl']?.toString() ?? '';

        String availabilityValue = parentProduct['AVAILABLE']?.toString() ?? '';
        if (availabilityValue == 'Y') {
          availability.value = 'Available';
        } else if (availabilityValue == 'N') {
          availability.value = 'Not available';
        } else {
          availability.value = 'Pending';
        }

        rangeStatus.value = parentProduct['BRAND_NAME']?.toString() ?? '';
        daysOfSale.value = parentProduct['daysOfSale']?.toString() ?? '';
        promotion.value = parentProduct['EXEC_CAT_NAME']?.toString() ?? '';

        childProducts.assignAll(list.map((p) {
          String available = p['AVAILABLE']?.toString() ?? '';
          AvailabilityStatus status;
          if (available == 'Y') {
            status = AvailabilityStatus.available;
          } else if (available == 'N') {
            status = AvailabilityStatus.unavailable;
          } else {
            status = AvailabilityStatus.pending;
          }

          String opt = p['Available_Option']?.toString() ?? '';
          // If opt is an ID, find the corresponding value using newOptions
          final matchingOption =
              newOptions.firstWhereOrNull((o) => o.optionId.toString() == opt);
          if (matchingOption != null) {
            opt = matchingOption.optionValue;
          }

          return ChildProduct(
            sku: p['SKU_CODE']?.toString() ?? '',
            name: p['SKU_NAME']?.toString() ?? 'Unknown',
            status: status,
            isSelected: status == AvailabilityStatus.available,
            remarks: p['REMARKS']?.toString() ?? '',
            availableOption: opt,
          );
        }).toList());
        _updateSelectionStatus();
        return newOptions;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
    return null;
  }

  void updateStatus(int index, AvailabilityStatus status) {
    childProducts[index].status = status;
    childProducts[index].isSelected = status == AvailabilityStatus.available;
    childProducts.refresh();
    _updateSelectionStatus();
  }

  void updateAvailableOption(int index, String value) {
    childProducts[index].availableOption = value;
    childProducts.refresh();
  }

  void markAllAvailable() {
    for (var child in childProducts) {
      child.status = AvailabilityStatus.available;
      child.isSelected = true;
    }
    childProducts.refresh();
    _updateSelectionStatus();
  }

  void _updateSelectionStatus() {
    availableCount.value = childProducts
        .where((c) => c.status == AvailabilityStatus.available)
        .length;
    pendingCount.value = childProducts
        .where((c) => c.status == AvailabilityStatus.pending)
        .length;
    unavailableCount.value = childProducts
        .where((c) => c.status == AvailabilityStatus.unavailable)
        .length;
    selectedCount.value = availableCount.value;
    isAllSelected.value = availableCount.value == childProducts.length &&
        childProducts.isNotEmpty;
  }

  void showRemarksDialog(BuildContext context, int index) {
    final TextEditingController remarksController =
        TextEditingController(text: childProducts[index].remarks);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Remarks'),
          content: TextField(
            controller: remarksController,
            decoration: InputDecoration(hintText: "Enter remarks"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                childProducts[index].remarks = remarksController.text;
                childProducts.refresh();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmAvailability(
      BuildContext context, String scannedSku) async {
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    final testerController = Get.find<TesterController>();
    await testerController.loadFromPrefs();
    await testerController.loadUserCode();
    final locationCode = testerController.storeCode.value;
    final userCode = testerController.userCode.value;

    if (locationCode.isEmpty) {
      Get.snackbar('No Location', 'Please select a store location first.',
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
      final List<Map<String, String>> skuDetails = childProducts.map((child) {
        String availableValue;
        switch (child.status) {
          case AvailabilityStatus.available:
            availableValue = "Y";
            break;
          case AvailabilityStatus.unavailable:
            availableValue = "N";
            break;
          case AvailabilityStatus.pending:
          default:
            availableValue = "P";
            break;
        }

        return {
          "sku_code": child.sku,
          "available": availableValue,
          "remarks": child.remarks.isEmpty
              ? (child.status == AvailabilityStatus.available
                  ? "Confirmed via App"
                  : child.status == AvailabilityStatus.unavailable
                      ? "Marked as unavailable"
                      : "Pending review")
              : child.remarks,
          "available_option": child.availableOption
        };
      }).toList();
      final requestPayload = {
        "location_code": locationCode,
        "created_by": userCode,
        "sku_details": skuDetails
      };

      print(
          "Sending Payload to store-soh/update: ${json.encode(requestPayload)}");
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
      final resDataaa = json.decode(response.body);

      print("store-soh/update : response: $resDataaa");

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        print("store-soh/update : response: $resData");

        if (resData['status'] == true) {
          for (var child in childProducts) {
            child.status = child.isSelected
                ? AvailabilityStatus.available
                : AvailabilityStatus.unavailable;
          }
          testerController.productsUpdated.value += childProducts.length;
          // Use the original typed/scanned SKU for recent scans
          testerController.addScan(scannedSku, parentName.value);

          Get.off(() => SuccessScreen(
                updatedProducts: childProducts,
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
