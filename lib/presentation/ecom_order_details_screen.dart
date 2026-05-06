import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/controllers/ecom_order_details_controller.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../data/order_model.dart';
import '../widgets/payment_card_widget.dart';

class EcomOrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String selectedLocationCode;

  const EcomOrderDetailsScreen(
      {super.key, required this.order, required this.selectedLocationCode});

  @override
  State<EcomOrderDetailsScreen> createState() => _EcomOrderDetailsScreenState();
}

class _EcomOrderDetailsScreenState extends State<EcomOrderDetailsScreen> {
  Order? orderDetails;
  bool isLoading = true;
  String? errorMessage;
  final EcomOrderDetailsController orderController =
      Get.put(EcomOrderDetailsController());

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final String apiUrl =
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/StoreOrderDetailslist_ECOM/${widget.order['orderId']}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            orderDetails = Order.fromJson(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? "Failed to load details";
          });
        }
      } else if (response.statusCode == 404) {
        String msg = "Record not found (404)";
        try {
          final data = json.decode(response.body);
          msg = data['message'] ?? data['Message'] ?? msg;
        } catch (_) {}
        setState(() {
          isLoading = false;
          errorMessage = msg;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          'Order ID: ${widget.order['orderId']}',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : errorMessage != null
              ? Center(child: Text("Error: $errorMessage", style: GoogleFonts.outfit()))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderHeader(),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                                itemCount: orderDetails!.items.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == orderDetails!.items.length) {
                                    return PaymentSummary(
                                      order: orderDetails!,
                                      orderController: orderController,
                                    );
                                  }

                                  final item = orderDetails!.items[index];

                                  return Obx(() {
                                    final selectedData = orderController
                                        .selectedProductData[item.skuCode];

                                    return _buildProductCard(item, selectedData);
                                  });
                                }),
                          ),
                          const SizedBox(height: 60), // Space for bottom button
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildActionButton(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              Text(widget.order['status']?.toUpperCase() ?? 'N/A', 
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Date', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              Text('${widget.order['date']}', 
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(OrderItem item, dynamic selectedData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 2,
          color: orderController.borderColors[item.skuCode] ?? Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80, width: 80, color: Colors.grey[100], 
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.skuName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Code: ${item.skuCode}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            selectedData != null ? '₹${selectedData["mrp"]}' : '₹${item.listPrice}',
                            style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                          const Spacer(),
                          Text('Qty: ', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              selectedData != null ? '${selectedData["quantity"]}' : '${item.quantity}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showEnterCodeDialog(context, item.skuCode, item.quantity, widget.selectedLocationCode),
                    icon: const Icon(Icons.keyboard_outlined, size: 18),
                    label: Text("Enter Code", style: GoogleFonts.outfit(fontSize: 13)),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey[300]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _scanProduct(item.skuCode, item.quantity, widget.selectedLocationCode, 1),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: Text("Scan Code", style: GoogleFonts.outfit(fontSize: 13)),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Obx(() => SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: orderController.isLoading.value ? null : _submitReadyToShip,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: orderController.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'READY TO SHIP',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    ));
  }

  void _showEnterCodeDialog(BuildContext context, String skuCode, int quantity, String locationCode) {
    TextEditingController codeController = TextEditingController();
    Get.defaultDialog(
      title: "Manual Entry",
      titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: "Product Code",
            hintText: "Enter SKU code",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          String enteredCode = codeController.text.trim();
          if (enteredCode.isNotEmpty) {
            _scanProduct(enteredCode, quantity, locationCode, 0);
            Get.back();
          } else {
            Fluttertoast.showToast(msg: "Please enter a valid code");
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: Text("Submit", style: GoogleFonts.outfit(color: Colors.white)),
      ),
    );
  }

  Future<void> _scanProduct(String skuCode, int quantity, String selectedLocationCode, int fromTextOrScan) async {
    if (fromTextOrScan == 0) {
      orderController.scanProduct(skuCode, quantity, selectedLocationCode);
    } else {
      String? scannedCode = await _goToQrPage();
      if (scannedCode != null) {
        if (skuCode == scannedCode) {
          orderController.scanProduct(scannedCode, quantity, selectedLocationCode);
        } else {
          Fluttertoast.showToast(
            msg: "Scanned SKU does not match this item.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          orderController.borderColors[skuCode] = Colors.red;
        }
      }
    }
  }

  Future<String?> _goToQrPage() async {
    return await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Scan Product',
        centerTitle: true,
        enableBackButton: true,
      ),
      isShowFlashIcon: true,
      cameraFace: CameraFace.back,
    );
  }

  void _submitReadyToShip() async {
    bool success = await orderController.submitReadyToShip(widget.order['orderId']);
    if (success) {
      Get.back(result: true);
    }
  }
}
