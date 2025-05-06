import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:hng_flutter/widgets/location_display_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../common/zoomable_image.dart';
import '../widgets/location_search_dialog.dart';

class ProductQuickEnquiryPage extends StatefulWidget {
  const ProductQuickEnquiryPage({super.key});

  @override
  State<ProductQuickEnquiryPage> createState() =>
      _ProductQuickEnquiryPageState();
}

class _ProductQuickEnquiryPageState extends State<ProductQuickEnquiryPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? skuName;
  String? stockOnHand;
  String? averageDailySales;
  String? promotion;
  Map<String, dynamic>? productData;

  Future<void> fetchProductDetails(String code) async {

    SharedPreferences pref = await SharedPreferences.getInstance();
    var userCode = pref.getString('userCode');
    // var locationCode = "106";
    final url = Uri.parse(
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/Coupon/Newproductenquiry/$code/$locationCode/$userCode");
    print(
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/Coupon/Newproductenquiry/$code/$locationCode/$userCode");
    setState(() {
      _isLoading = true;
      productData = null;
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 100), onTimeout: () {
        throw TimeoutException('The connection has timed out. Please try again.');
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          setState(() {
            productData = data['product'][0];
          });
        } else {
          _showError(data['status']);
        }
      } else {
        _showError('Failed to fetch product details.${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        _showError('Request timed out. Please check your connection and try again.');
      } else {
        _showError('An error occurred: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showSimpleDialog(title: 'Alert!', msg: message);
    _codeController.clear();
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



  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Function to display all rows
  Widget _buildProductDetails(Map<String, dynamic> productData) {
    final details = [
      // ["SKU Code", productData['skU_CODE']],
      // ["SKU Name", productData['skU_NAME']],
      // ["Location Code", productData['locatioN_CODE']],
      // ["HSN Code", productData['hsN_CODE']],
      // ["HSN Description", productData['hsN_DESCRIPTION']],
      // ["Tax Code", productData['taX_CODE']],
      // ["Tax Rate", "${productData['taX_RATE']}%"],
      // ["EAN Code", productData['ean_code']],
      // ["Stock On Hand", productData['soh']],
      // ["Availability", productData['availability']],
      // ["Average Daily Sales", productData['avarageDailySales']],
      // ["Promotion", productData['promotion']],
    ];

    return SingleChildScrollView(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          Center(
            child: InkWell(
              onTap: (){
                Get.to(ZoomableImage(
                    imageUrl:
                    productData!['productImageUrl']));
              },
              child: Image.network(
                productData['productImageUrl'] ?? '', // Image URL
                height: 150,
                width: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 150,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Add some spacing after the image
          Text(
            textAlign: TextAlign.center,
            '${productData['skU_NAME']}\n',
            style: const TextStyle(fontSize: 16,color: Colors.black),
            // overflow: TextOverflow.ellipsis,
          ),
          Container(
            color:Colors.white   , // Alternate background
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Availability',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Flexible(
                  child: Text(
                      '${productData['availability']}',
                    style:  TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: productData['availability']=="Available"?Colors.green:Colors.red),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200] , // Alternate background
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Average Daily Sales',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Flexible(
                  child: Text(
                      '${productData['avarageDailySales']}',
                    style:  const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),  Container(
            color: Colors.grey[200] , // Alternate background
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Range Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Flexible(
                  child: Text(
                      '${productData['rangeStatus']}',
                    style:  const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            // padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  textAlign: TextAlign.start,
                  'Promotion:',
                  style: TextStyle(fontSize: 16,color: Colors.black),
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
            color: Colors.yellow,
            child: Text(
              '${productData['promotion']}',
              style: const TextStyle(fontSize: 16,color: Colors.black),
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          // Product Details Rows
          ...List.generate(details.length, (index) {
            return _buildDetailRowWithBackground(
              details[index][0],
              details[index][1] ?? "N/A",
              index % 2 == 0, // Grey background for even rows
            );
          }),
        ],
      ),
    );
  }

// Function to build rows with alternating background color
  Widget _buildDetailRowWithBackground(
      String label, String value, bool isGrey) {
    return Container(
      color: isGrey ? Colors.grey[200] : Colors.white, // Alternate background
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String locationCode = '';
  String userId = '';
  String locationName = '';
  @override
  void initState() {
    super.initState();
    loadLocationCode();

  }
  Future<void> loadLocationCode() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      locationCode = prefs.getString('locationCode') ?? 'No Code Found';
      userId = prefs.getString('userCode') ?? 'No User Found';
      locationName = prefs.getString('location_name') ?? 'No Name Found';
    });

    showLocationDialog(context, userId);
  }

  void showLocationDialog(BuildContext context, String userId) async {
    final selectedLocation = await showDialog(
      context: context,
      builder: (context) => LocationSearchDialog(userId: userId),
    );

    if (selectedLocation != null) {
      print("Selected Location: ${selectedLocation['locationName']}");
      setState(() {
        locationCode =selectedLocation['locationCode'] ?? 'No Code Found';
        locationName =selectedLocation['locationName'] ?? 'No Name Found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Product Quick Enquiry",
          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
        ),
      ),
      /* appBar: AppBar(
        title: const Text('Product Quick Enquiry Screen',style: TextStyle(fontSize: 16),),
        backgroundColor: Colors.orange,
      ),*/
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 8,),
            Row(
              children: [


                Expanded(
                  child: TextField(
                    controller: _codeController,
                    onTapOutside: (h) {
                      // _scanProduct();
                      if (_codeController.text.isNotEmpty) {
                        fetchProductDetails(_codeController.text);
                        print("onTapOutside:$h");
                      }
                    },
                    onSubmitted: (d) {
                      if (d.isNotEmpty) {
                        fetchProductDetails(_codeController.text);
                        print("onSubmitted:$d");
                      }
                    },

                    decoration: InputDecoration(
                      hintText: 'Enter Code or Scan Product',
                      border: const OutlineInputBorder(),

                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanProduct,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8,),

            InkWell(
              onTap: (){
                showLocationDialog(context,"70002");
              },
              child: LocationDisplay(
                locationCode: locationCode,
                locationName: locationName,
              ),
            ),


            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: productData == null
                        ? const Center(
                            child: Text(
                                'No product data available. Please search or scan.'),
                          )
                        : _buildProductDetails(productData!)),
           /* const Text(
              '\nNote: This Functionality will work only when the staff is inside the store',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),*/
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
