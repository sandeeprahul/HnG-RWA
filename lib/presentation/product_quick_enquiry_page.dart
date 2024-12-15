import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ProductQuickEnquiryPage extends StatefulWidget {
  const ProductQuickEnquiryPage({super.key});

  @override
  State<ProductQuickEnquiryPage> createState() => _ProductQuickEnquiryPageState();
}

class _ProductQuickEnquiryPageState extends State<ProductQuickEnquiryPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? skuName;
  String? stockOnHand;
  String? averageDailySales;
  String? promotion;

  Future<void> fetchProductDetails(String code) async {
    final url = Uri.parse(
        "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Coupon/productenquiry/$code");

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          skuName = data['skuName'];
          stockOnHand = data['soh'];
          averageDailySales = data['avarageDailySales'];
          promotion = data['promotion'];
        });
      } else {
        _showError('Failed to fetch product details.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _scanProduct() async {
    // Replace this with your QR scanning function.
    String? scannedCode = await goToQrPage("your-phone-number");
    if (scannedCode != null) {
     /* setState(() {

      });*/
      _codeController.text = scannedCode;

      fetchProductDetails(scannedCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Quick Enquiry Screen',style: TextStyle(fontSize: 16),),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Scan Product',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    onTapOutside: (h){
                      // _scanProduct();
                      fetchProductDetails(_codeController.text);
                      print("onTapOutside:$h");

                    },
                    onSubmitted: (d){
                      fetchProductDetails(_codeController.text);

                      print("onSubmitted:$d");
                    },
                    decoration:  InputDecoration(
                      // labelText: 'Scan Product',
                      border:const OutlineInputBorder(),
                      suffixIcon:     IconButton(
                        icon:  const Icon(Icons.qr_code_scanner),
                        onPressed: _scanProduct,
                      ),
                    ),

                  ),
                ),
              /*  const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanProduct,
                ),*/
              ],
            ),
            const SizedBox(height: 16.0),

              const Text(
                'Sku Name',
                style: TextStyle(fontSize: 16,),
              ),
              Text(skuName??'', style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
              const SizedBox(height: 8.0),
              const Text(
                '\nStock On Hand',
                style: TextStyle(fontSize: 16),
              ),
              Text(stockOnHand ?? '',style: const TextStyle(color: Colors.green,fontSize: 16),),
              const SizedBox(height: 8.0),
              const Text(
                '\nAverage Daily Sales',
                style: TextStyle(fontSize: 16),
              ),
              Text(averageDailySales ?? '', style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.green)),
              const SizedBox(height: 8.0),
              const Text(
                '\nPromotion',
                style: TextStyle(fontSize: 16),
              ),
              Container(
                  color: Colors.yellow,
                  child: Text(promotion ?? '', style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16))),
              const SizedBox(height: 8.0),
              const Text(
                '\nNote: This Functionality will work only when the staff is inside the store',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),

          ],
        ),
      ),
    );
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

