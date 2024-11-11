import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../widgets/custom_elevated_button.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String phone = "";
  String desc = "";
  String code = "";
  bool codeVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(36),
            margin: const EdgeInsets.all(36),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                  ),
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'MOBILE NUMBER',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Please enter your mobile number',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: 'Enter Phone number',
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: ()  {
                        if (phoneController.text.isNotEmpty &&
                            phoneController.text.length == 10) {
                          goToQrPage(
                            phoneController.text.toString(),
                          );



                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              14), // Adjust the value as needed
                        ),
                      ),
                      child: const Text('SUBMIT'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
              visible: codeVisibility,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 88,
                    ),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    Text("Code : $code",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> goToQrPage(String phone) async {


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



    // var res = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>  const SimpleBarcodeScannerPage(),
    //     ));
    // print("res: $res");
    // callApi();
    showAlert(res!, phone);
  }



  void showAlert(String barcode, String phone){
    Get.dialog(
      AlertDialog(
        title: const Text('Scanned Code'),
        content: Text('The scanned code is: $barcode'),
        actions: [

          ElevatedButton(
            onPressed: () {
              Get.back(); // Close the dialog using GetX
              // controller.poNoController.text = barcode;
              // Get.back();
              callApi(barcode,phone);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  bool loading = false;

  Future<void> callApi(String? scanData, String phone) async {
    try {
      setState(() {
        loading = true;
      });
// http://200.healthandglow.in/qrcouponapi/api/Qrcoupon/detail
      var url = Uri.http(
        '200.healthandglow.in',
        '/qrcouponapi/api/Qrcoupon',
      );
      var params;

      /* params = {
        "qrcodetext":
            "https://rwaweb.healthandglowonline.co.in/hgcoupon/QRdescription.aspx?qrcodetext=TESTQR",
        "mobileno": "8050920201",
      };*/
      params = {
        "qrcodetext": "$scanData",
        "mobileno": phone,
      };
      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(seconds: 10));

      var respo = jsonDecode(response.body);

      if (respo['statucode'] == '200') {
        // _showAlert("Coupon Code : ");
        String descWithoutTags = removeHtmlTags(respo['coupondesc']);
        setState(() {
          loading = false;

          desc = descWithoutTags;
          code = respo['couponcode'];
          codeVisibility = true;
          _showAlert("${respo['statucode']}\n${respo['message']}");
        });
      } else {
        setState(() {
          loading = false;
        });
        _showAlert("${respo['statucode']}\n${respo['message']}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      _showAlert(
          "Something went wrong!\n${e.toString()}\n Please contact IT support");
    }
  }

  String removeHtmlTags(String htmlString) {
    // Use a regular expression to remove HTML tags
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  Future<void> _showAlert(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(message),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'OK',
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }
}
