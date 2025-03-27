import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/controllers/order_details_controller.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../common/constants.dart';
import '../data/order_model.dart';
import '../widgets/payment_card_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String selectedLocationCode;

  const OrderDetailsScreen({super.key, required this.order,required this.selectedLocationCode});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? orderDetails;
  bool isLoading = true;
  String? errorMessage;
  final OrderDetailsController orderController =
      Get.put(OrderDetailsController());

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
    orderController.selectedProductData.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order ID: ${widget.order['orderId']}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text("Error: $errorMessage"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Status: ${widget.order['status']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${widget.order['date']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                                // shrinkWrap: true,
                                itemCount: orderDetails!.items.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == orderDetails!.items.length) {
                                    // Last item -> Show PaymentSummary
                                    return PaymentSummary(
                                      order: orderDetails!,
                                      orderController: orderController,
                                    );
                                  }

                                  final item = orderDetails!.items[index];

                                  return Obx(() {
                                    // final borderColor = orderController
                                    //         .borderColors[item.skuCode] ??
                                    //     Colors.red;
                                    final selectedData = orderController
                                        .selectedProductData[item.skuCode];

                                    return InkWell(
                                      onTap: () {
                                        _scanProduct(
                                            item.skuCode, item.quantity,widget.selectedLocationCode);
                                      },
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: orderController
                                                                  .borderColors[
                                                              item.skuCode] ??
                                                          Colors.transparent),
                                                  // Use dynamic color

                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade100,
                                                        spreadRadius: 2,
                                                        blurRadius: 2)
                                                  ]),
                                              margin: const EdgeInsets.only(
                                                  bottom: 6),
                                              child: Row(
                                                children: [
                                                  /*     Container(
                                                      height: 150,width: 4,
                                                      // color: Colors.red,
                                                    ),*/
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      height: 75,
                                                      width: 75,
                                                      child: Image.network(
                                                        item.imageUrl,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 12,
                                                              bottom: 12),
                                                      child: Column(
                                                        // mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,

                                                        children: [
                                                          Text(item.skuName,
                                                              // maxLines: 4,
                                                              // softWrap: true, // Enables word wrapping
                                                              // overflow: TextOverflow.visible, // Ensures text doesn't get truncated

                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                          const SizedBox(
                                                            height: 14,
                                                          ),
                                                          Text(
                                                              'Code: ${item.skuCode}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          const SizedBox(
                                                            height: 14,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  selectedData !=
                                                                          null
                                                                      ? '₹${selectedData["mrp"]}'
                                                                      : '₹${item.listPrice}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              const SizedBox(
                                                                width: 14,
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 2,
                                                                    horizontal:
                                                                        6),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6),
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey)),
                                                                child: Text(
                                                                    selectedData !=
                                                                            null
                                                                        ? '₹${selectedData["mrp"]}'
                                                                        : '₹${item.listPrice}',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12)),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              const Text('X'),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 2,
                                                                    horizontal:
                                                                        6),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6),
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey)),
                                                                child: Text(
                                                                    selectedData !=
                                                                            null
                                                                        ? '${selectedData["quantity"]}'
                                                                        : '${item.quantity}',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12)),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: IconButton(
                                                  onPressed: () {
                                                    _scanProduct(item.skuCode,
                                                        item.quantity,widget.selectedLocationCode);
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .document_scanner_outlined,
                                                    color: Colors.orange,
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  });
                                }),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 45,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitReadyToShip,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'READY TO SHIP',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

      /*  bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(), // Optional for better design
        child: SizedBox(height: 60), // Adjust height for spacing
      ),*/
    );
  }

  Future<void> fetchOrderDetails() async {
    final String apiUrl =
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/StoreOrderDetailslist/${widget.order['orderId']}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orderDetails = Order.fromJson(data['data']);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load order details\nStatusCode:${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  bool successOrderIdFlag = false;

  Future<void> _scanProduct(String skuCode, int quantity, String selectedLocationCode) async {
    // Replace this with your QR scanning function.
    String? scannedCode = await goToQrPage("your-phone-number");
    if (scannedCode != null) {
      if (skuCode == scannedCode) {
        orderController.scanProduct(scannedCode, quantity,selectedLocationCode);
      } else {
        Get.snackbar(
          "Error",
          "SKUCODE not matching",
          snackPosition: SnackPosition.BOTTOM,
          // Position at the top
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
          // Center-like effect
          animationDuration: const Duration(milliseconds: 500),
          forwardAnimationCurve: Curves.easeInOut,
          // Smooth animation
          overlayBlur: 2, // No background blur
        );
        orderController.borderColors[skuCode] = Colors.red;
      }
      // _codeController.text = scannedCode;

      // fetchProductDetails(scannedCode);
    }
  }

  void _submitReadyToShip() async {
    try {
      setState(() {
        isLoading = true;
      });
      List<Map<String, dynamic>> pickedItems = [];

      // Iterate through selectedProductData to prepare JSON payload
      orderController.selectedProductData.forEach((skuCode, data) {
        pickedItems.add({
          "Picked_MRP": data["mrp"] ?? 0.0,
          // Ensure fallback value
          "Picked_Qty": data["quantity"] ?? 0,
          // Ensure fallback value
          "Sku_code": skuCode,
          "Order_id": orderDetails?.orderId ?? "",
          // Ensure order ID is present
          "sku_batch_no": data["stockNo"] ?? "",
          // Fallback batch number
        });
      });

      // Ensure there is data to send
      if (pickedItems.isEmpty) {
        debugPrint("No items picked for shipping.");
        Get.snackbar("Failure", "No items picked for shipping.",
            overlayBlur: 2,
            backgroundColor: Colors.red,
            colorText: Colors.white);

        return;
      }


      // Define API endpoint
      const url =
          'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/UpdateRTS';

      // Make API request
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pickedItems),
      );
      print("_submitReadyToShip");
      print(url);
      print(jsonEncode(pickedItems));
      print(response.body);

      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "ok") {
          Navigator.pop(context);
          Get.snackbar('Success', responseBody['message'],
              overlayBlur: 2,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        }
        // debugPrint("Ready to Ship data submitted successfully!");
        debugPrint("Response: ${response.body}");

        // Optionally show a success message to the user
      } else {
        Get.snackbar('Failure', "${response.statusCode}",
            overlayBlur: 2,
            backgroundColor: Colors.red,
            colorText: Colors.white);

        debugPrint("Failed to submit data: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
      }
    } catch (e) {
      Get.snackbar('Error', "Error submitting Ready to Ship data: $e",
          overlayBlur: 2, backgroundColor: Colors.red, colorText: Colors.white);

      debugPrint("Error submitting Ready to Ship data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _scanOrderId(String orderId) async {
    // Replace this with your QR scanning function.
    String? scannedCode = await goToQrPage("your-phone-number");
    if (scannedCode != null) {
      if (scannedCode == orderId) {
        setState(() {
          successOrderIdFlag = true;
        });
      }
      // _codeController.text = scannedCode;

      // fetchProductDetails(scannedCode);
    }
  }

  Future<String?> goToQrPage(String phone) async {
    // Replace with your QR scanning logic
    // For example:
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'HnG RWA',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );

    return res; // Replace with scanned code.
  }
}
