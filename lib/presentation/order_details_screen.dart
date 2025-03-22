import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../widgets/payment_card_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order['orderId']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Order Status: ${widget.order['status']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: SizedBox(
                          height: 50,
                          width: 50,
                          child: SvgPicture.network(
                              'https://ik.imagekit.io/hng/desktop-assets/svgs/logo.svg')),
                      title: const Text('Bella Cotton Paper Sticks Foil A160' ,style: TextStyle(fontSize: 15)),
                      subtitle: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6,),
                          Text('Product# 567411',style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 6,),


                        ],
                      ),

                      trailing: const Column(
                        children: [
                          Text('₹79.0', style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                          Text('x 1'),
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(),
                        Text('Coupon: null ',style: TextStyle(color: Colors.grey,fontSize: 12)),
                        Spacer(),
                        Text('Campaign: 0.0',style: TextStyle(color: Colors.grey,fontSize: 12)),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            const Expanded(
              child:PaymentSummary(),
            ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _scanProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('SCAN'),
                    ),
                    const SizedBox(height: 4,),ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('ENTER BARCODE'),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanProduct() async {
    // Replace this with your QR scanning function.
    String? scannedCode = await goToQrPage("your-phone-number");
    if (scannedCode != null) {
      /* setState(() {

      });*/
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
