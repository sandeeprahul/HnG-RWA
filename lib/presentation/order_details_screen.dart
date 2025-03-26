import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../data/order_model.dart';
import '../widgets/payment_card_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? orderDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
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
                              // flex: 2,
                              child: ListView.builder(
                                  // itemCount: 2,
                                  itemCount: orderDetails!.items.length,
                                  itemBuilder: (context, index) {
                                    final item = orderDetails!.items[index];

                                    return Stack(
                                      children: [
                                        SizedBox(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.red),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color:
                                                          Colors.grey.shade100,
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
                                                      const EdgeInsets.all(8.0),
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
                                                                '₹${item.listPrice}',
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
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          6),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey)),
                                                              child: Text(
                                                                  '${item.listPrice}',
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
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          6),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey)),
                                                              child: Text(
                                                                  '${item.quantity}',
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: IconButton(
                                                onPressed: _scanProduct,
                                                icon: const Icon(
                                                  Icons.document_scanner_outlined,
                                                  color: Colors.orange,
                                                )),
                                          ),
                                        )
                                      ],
                                    );
                                  })),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 2.5),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PaymentSummary(
                            order: orderDetails!,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
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

  bool successBarcodeFlag = false;

  Future<void> _scanProduct() async {
    // Replace this with your QR scanning function.
    String? scannedCode = await goToQrPage("your-phone-number");
    if (scannedCode != null) {
      setState(() {
        successBarcodeFlag = true;
      });
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
