import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class QRViewExample extends StatefulWidget {
  final String phone;

  const QRViewExample(String string, {super.key, required this.phone});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  // Barcode? result;
  // QRViewController? controller;
  // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String phone="";
  String desc = "";
  String code = "";
  bool codeVisibility = false;
  TextEditingController phoneController = TextEditingController();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  /* @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                  flex: 5,
                  child: ElevatedButton(
                      onPressed: () async {
                        gotoToQRPage();
                      },
                      child: const Text('Scan qr'))),

            ],
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



  @override
  void dispose() {
    super.dispose();
  }

  bool loading = false;

  Future<void> callApi(String? scanData) async {
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
        "mobileno": widget.phone,
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

  Future<void> gotoToQRPage() async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const SimpleBarcodeScannerPage(),
        ));
    // showAlert(res,controller);
    callApi(res);

  }
}
