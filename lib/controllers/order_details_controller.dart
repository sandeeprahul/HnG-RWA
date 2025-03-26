import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/order_model.dart';

class OrderDetailsController extends GetxController {
  final RxMap<String, Color> borderColors = <String, Color>{}.obs;
  var selectedMRP = "".obs; // Selected MRP
  var selectedStockNo = "".obs; // Selected Stock Number
  var quantityController = TextEditingController(); // Quantity input
  final RxMap<String, dynamic> selectedProductData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    borderColors.clear();
    super.onInit();
  }

  Future<void> scanProduct(String skuCode) async {
    // borderColors[skuCode] = Colors.red; // Error case, keep red
    // borderColors.refresh();
    try {
      final response = await http.get(
        Uri.parse(
            "http://36.255.252.199/selfcheck_uat/api/checkout/geteandetail?location=106&ean_code=$skuCode"),
        // Replace with actual API URL
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode({"sku_code": skuCode}),
      );

      print("scanned product data: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // {"statusCode":"201","Status":"Failure","Message":"Product detail not found.."}

        if (responseData["statusCode"] == "201") {
          borderColors[skuCode] = Colors.red; // Keep border red
          Get.snackbar(
            "${responseData["Status"]}",
            "${responseData["Message"]}",
            snackPosition: SnackPosition.TOP,
            // Position at the top
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.only(top: 200, left: 20, right: 20),
            // Center-like effect
            animationDuration: const Duration(milliseconds: 500),
            forwardAnimationCurve: Curves.easeInOut,
            // Smooth animation
            overlayBlur: 2, // No background blur
          );
          borderColors.assignAll({...borderColors}); // ✅ Forces UI update
        } else {
          bool isProductFound = responseData["product"]
              .any((product) => product["SKU_CODE"] == skuCode);
          borderColors[skuCode] =
              isProductFound ? Colors.green : Colors.transparent;
          if (isProductFound) {
            List batchList = responseData["batch"];
            if (batchList.isNotEmpty) {
              showMRPSelectionDialog(batchList, skuCode); // Show MRP popup
            }
          }

          //
          // if (isProductFound) {
          //
          //   borderColors[skuCode] = Colors.green;
          //   borderColors.refresh();// Change border to green
          //
          // } else {
          //   borderColors[skuCode] = Colors.red;
          //   borderColors.refresh();// Keep border red
          // }
        }

        borderColors.assignAll({...borderColors}); // ✅ Forces UI update
        // update();
      } else {
        borderColors[skuCode] = Colors.red; // Error case, keep red
        // borderColors.refresh(); // ✅ Forces UI update
        borderColors.assignAll({...borderColors}); // ✅ Forces UI update
      }
    } catch (e) {
      borderColors[skuCode] = Colors.red; // Handle error
      // borderColors.refresh();
      borderColors.assignAll({...borderColors}); // ✅ Forces UI update
    }
  }

  void showMRPSelectionDialog(List batchList, String skuCode) {
    selectedMRP.value = "";
    selectedStockNo.value = "";
    quantityController.clear();
    Get.dialog(
      AlertDialog(
        title: const Text("Select MRP & Quantity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => DropdownButton<String>(
              hint: const Text("Select MRP"),
              value: selectedMRP.value.isEmpty ? null : selectedMRP.value,
              isExpanded: true,
              items: batchList.map<DropdownMenuItem<String>>((batch) {
                return DropdownMenuItem<String>(
                  value: batch["MRP"],
                  child: Text(
                      "₹${batch["MRP"]} (Stock No: ${batch["STORE_SKU_LOC_STOCK_NO"]})"),
                );
              }).toList(),
              onChanged: (value) {
                selectedMRP.value = value!;
                selectedStockNo.value = batchList
                    .firstWhere((batch) => batch["MRP"] == value)["STORE_SKU_LOC_STOCK_NO"];
              },
            )),
            const SizedBox(height: 10),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Quantity",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (selectedMRP.value.isEmpty) {
                showErrorSnackbar("Error", "Please select an MRP");
                return;
              }

              int? quantity = int.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                showErrorSnackbar("Error", "Quantity must be greater than zero");
                return;
              }

              selectedProductData[skuCode] = {
                "mrp": selectedMRP.value,
                "stockNo": selectedStockNo.value,
                "quantity": quantity,
              };

              // Find and update the item in the order
              // OrderItem? item = order.items.firstWhereOrNull((item) => item.skuCode == skuCode);
              // if (item != null) {
              //   item.updateItem(double.parse(selectedMRP.value), quantity);
              //   order.updateOrderSummary(); // Update totals
              // }

              Get.back();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.only(top: 200, left: 20, right: 20),
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeInOut,
      overlayBlur: 2,
    );
  }
}
