import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../data/order_model.dart';

class EcomOrderDetailsController extends GetxController {
  final RxMap<String, Color> borderColors = <String, Color>{}.obs;
  final RxMap<String, dynamic> selectedProductData = <String, dynamic>{}.obs;

  var selectedMRP = "".obs;
  var selectedStockNo = "".obs;
  var quantityController = TextEditingController();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    borderColors.clear();
    selectedProductData.clear();
  }

  Future<String?> scanProduct(
      String skuCode, int originalQuantity, String locationCode) async
  {
    skuCode = skuCode.trim();
    try {
      final response = await http.get(
        Uri.parse(
            "https://rwaweb.healthandglowonline.co.in/mposgetean/api/checkout/geteandetail?location=$locationCode&ean_code=$skuCode"),
        headers: {"Content-Type": "application/json"},
      );

      print("After Scann CONTROLLER ->>ean_code=$skuCode");
      print(
          "https://rwaweb.healthandglowonline.co.in/mposgetean/api/checkout/geteandetail?location=$locationCode&ean_code=$skuCode");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);

        if (responseData["statusCode"] == "201") {
          borderColors[skuCode] = Colors.red;
          borderColors.refresh();
          showErrorSnackbar(
              "Error",
              responseData["Message"] ??
                  responseData["message"] ??
                  "Product not found");
        } else if (responseData["statusCode"] == "401") {
          showErrorSnackbar(
              "Unauthorized",
              responseData["Message"] ??
                  responseData["message"] ??
                  "Access denied");
        } else {
          var product = responseData["product"]?.firstWhere(
              (p) =>
                  p["SKU_CODE"].toString() == skuCode ||
                  p["ean_code"].toString() == skuCode,
              orElse: () => null);

          if (product != null) {
            // Inside scanProduct method
            if (product != null) {// Use the scanned skuCode (the one used as key in UI)
              // rather than the one returned by the API if they differ
              String actualSkuCode = product["SKU_CODE"].toString();
              List batchList = responseData["batch"] ?? [];
              if (batchList.isNotEmpty) {
                // Pass the original scanned skuCode to the dialog
                showMRPSelectionDialog(batchList, actualSkuCode, originalQuantity);
                return skuCode;
              } else {
                showErrorSnackbar("Error", "No batches found for this product");
              }
            }
          } else {
            borderColors[skuCode] = Colors.red;
            borderColors.refresh();
            showErrorSnackbar("Error", "Product detail not found");
          }
        }
      } else if (response.statusCode == 404) {
        borderColors[skuCode] = Colors.red;
        borderColors.refresh();
        try {
          var responseBody = jsonDecode(response.body);
          showErrorSnackbar(
              "Not Found",
              responseBody['message'] ??
                  responseBody['Message'] ??
                  "Product not found (404)");
        } catch (e) {
          showErrorSnackbar("Not Found", "Product not found (404)");
        }
      } else {
        borderColors[skuCode] = Colors.red;
        borderColors.refresh();
        showErrorSnackbar("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      borderColors[skuCode] = Colors.red;
      borderColors.refresh();
      showErrorSnackbar("Error", "Failed to scan product: $e");
    }
    return null;
  }

  void showMRPSelectionDialog(
      List batchList, String skuCode, int originalQuantity)
  {
    selectedMRP.value = "";
    selectedStockNo.value = "";
    quantityController.clear();

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: const Text("Select MRP & Quantity"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => DropdownButton<String>(
                      hint: const Text("Select MRP"),
                      value: selectedStockNo.value.isEmpty
                          ? null
                          : selectedStockNo.value,
                      isExpanded: true,
                      items: batchList.map<DropdownMenuItem<String>>((batch) {
                        final stockNo =
                            batch["STORE_SKU_LOC_STOCK_NO"].toString();
                        return DropdownMenuItem<String>(
                          value: stockNo,
                          child: Text("₹${batch["MRP"]} (Stock: $stockNo)"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedStockNo.value = value!;
                        final selectedBatch = batchList.firstWhere((batch) =>
                            batch["STORE_SKU_LOC_STOCK_NO"].toString() ==
                            value);
                        selectedMRP.value = selectedBatch["MRP"].toString();
                      },
                    )),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter Quantity (Max $originalQuantity)",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (selectedMRP.value.isEmpty) {
                showErrorSnackbar("Error", "Please select an MRP");
                return;
              }
              int? quantity = int.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                showErrorSnackbar("Error", "Enter a valid quantity");
                return;
              }
              if (quantity > originalQuantity) {
                showErrorSnackbar("Error", "Quantity exceeds available stock");
                return;
              }

              // selectedProductData[skuCode] = {
              //   "mrp": double.parse(selectedMRP.value),
              //   "quantity": quantity,
              //   "stockNo": selectedProductData.value,
              // };


              selectedProductData[skuCode] = {
                "mrp": double.parse(selectedMRP.value),
                "quantity": quantity,
                "stockNo": selectedStockNo.value, // FIXED: Use the specific observable for Stock No
              };

              borderColors[skuCode] = Colors.green;
              selectedProductData.refresh();
              borderColors.refresh();

              print('DONE SELCTING QTY $selectedProductData');
              // Get.back();/
              Navigator.of(Get.context!).pop();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<bool> submitReadyToShip(String orderId,{String orderTypeName=''}) async {
    if (selectedProductData.isEmpty) {
      showErrorSnackbar("Action Required", "Please scan items before shipping");
      return false;
    }

    try {
      isLoading.value = true;
      List<Map<String, dynamic>> pickedItems = [];

      selectedProductData.forEach((skuCode, data) {
        pickedItems.add({
          "Order_id": orderId,
          "Sku_code": skuCode,
          "Picked_MRP": data["mrp"],
          "Picked_Qty": data["quantity"],
          "sku_batch_no": data["stockNo"],
        });
      });
      // SEPARATE URL LOGIC BASED ON ORDER TYPE
      String url;
      if (orderTypeName.toLowerCase().contains("click & collect")) {
        // Endpoint for Click and Collect (Ready for Pick)
        url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/UpdateRFP';
      } else {
        // Endpoint for Standard/Express (Ready to Ship)
        url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/UpdateRTS_ECOM';
      }

      print('Submitting to: $url');
      print('Payload: ${jsonEncode(pickedItems)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pickedItems),
      );
      print('submitReadyToShip->');
      print('$url $pickedItems');
      print(' ${response.statusCode}');
      print(' ${response.body}');
      print(' ${jsonEncode(selectedProductData)}');

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print('submitReadyToShip->response $responseBody');

        if (responseBody['status'] == "ok") {
          Fluttertoast.showToast(
              msg: '${responseBody['message']}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 14.0);
          return true;
        } else {
          showErrorSnackbar(
              "Error",
              responseBody['message'] ??
                  responseBody['Message'] ??
                  'Failed to update');
        }
      } else if (response.statusCode == 404) {
        try {
          var responseBody = jsonDecode(response.body);
          showErrorSnackbar(
              "Not Found",
              responseBody['message'] ??
                  responseBody['Message'] ??
                  "Record not found (404)");
        } catch (e) {
          showErrorSnackbar("Not Found", "Record not found (404)");
        }
      } else {
        showErrorSnackbar("Error", "Server returned ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackbar("Error", "Submission failed: $e");
      print(e);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> updateHandedOverToCustomer(String orderId, String orderType,  {String name = '', String mobile = ''} )// Added optional named parameters)
   async {
    try {
      isLoading.value = true;
      //"Standard", "Express" = order type
      String url;
      Map<String, dynamic> requestBody;
      // Control logic for API selection based on Order Type
      // UpdateHandedOverToCustomer = Only for Click and Collect
      // UpdateDeliveryStatus = For Standard & Express
      if (orderType.toLowerCase().contains("click & collect")) {
        url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/UpdateHandedOverToCustomer';
        requestBody = {"Order_id": orderId};
      } else {
        url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/UpdateDeliveryStatus_ECOM';
        requestBody = {
          "order_id": orderId,
          "Delivered_To_Person_Name": name,
          "Delivered_To_Mobile_No": mobile,
          "latitude": '0.0',
          "IMG_URL": '',
          "longitude": '0.0',
        };
      }

      print('Handover Process -> OrderType: $orderType');
      print('Submitting to: $url');
      print('Payload: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),      );
      var responseBody = jsonDecode(response.body);

      print("RESPONSE $responseBody");

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "ok") {
          Fluttertoast.showToast(
            msg: responseBody['message'] ?? '',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          return true;
        } else {
          showErrorSnackbar(
              "Error", responseBody['message'] ?? 'Failed to update status');
        }
      } else {
        showErrorSnackbar("Error", "Server returned ${ responseBody['message']}");
      }
    } catch (e) {
      showErrorSnackbar("Error", "Update failed: $e");
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void showErrorSnackbar(String title, String message) {
    // Get.snackbar(title, message,backgroundColor: Colors.red,colorText: Colors.white);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0);
  }
}
