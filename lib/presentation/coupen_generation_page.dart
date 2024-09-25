import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hng_flutter/data/coupen_entity.dart';
import 'package:hng_flutter/enums/discount_type.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';

class CoupenGenPage extends StatefulWidget {
  @override
  State<CoupenGenPage> createState() => _CoupenGenPageState();
}

class _CoupenGenPageState extends State<CoupenGenPage> {
  DiscountType? _discountType = DiscountType.percentage;
  final TextEditingController _skuCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  /* final List<Coupon> coupons = [
    Coupon(skuCode: '520085', skuName: 'Lakme Lipstick', mrp: '750', discountValue: '550'),
    // Add more Coupon objects as needed
  ];*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Other widgets here...
            const SizedBox(height: 20),
            const Text(
              'List of Coupons',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<DiscountType>(
                    title: const Text('Percentage'),
                    value: DiscountType.percentage,
                    groupValue: _discountType,
                    onChanged: (DiscountType? value) {
                      setState(() {
                        _discountType = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<DiscountType>(
                    title: const Text('Price Off'),
                    value: DiscountType.priceOff,
                    groupValue: _discountType,
                    onChanged: (DiscountType? value) {
                      setState(() {
                        _discountType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Enter Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _skuCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter SKU Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText:
                'Enter value If % 1-95% ,Price Off - 10% less than MRP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading == false
                  ? () {
                // Access entered SKU code: _skuCodeController.text
                // Access selected discount type: _discountType
                print('Entered SKU Code: ${_skuCodeController.text}');
                print('Selected discount type: $_discountType');
                if (_discountController.text.toString().isNotEmpty) {
                  if (_discountType == DiscountType.percentage) {
                    if (int.parse(_discountController.text.toString()) >
                        95 ||
                        int.parse(
                            _discountController.text.toString()) ==
                            0) {
                      //dont do anything
                    } else if(_phoneController.text.toString().isEmpty){
                      alert("Please enter Mobile number");
                    }
                    else {
                      fetchData();
                    }
                  }
                }
              }
                  : null,
              style: loading == false
                  ? ElevatedButton.styleFrom(
                // Enabled button style
                backgroundColor: Colors.blue,
                // Other styles such as text color, elevation, etc.
              )
                  : ElevatedButton.styleFrom(
                // Disabled button style
                backgroundColor:
                Colors.grey, // Change the color for disabled state
                // Other styles for disabled state
              ),
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            const Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Center(child: Text('SkuCode'))),
                Expanded(child: Center(child: Text('SkuName'))),
                Expanded(child: Center(child: Text('MRP'))),
                Expanded(child: Center(child: Text('Discount Value'))),
              ],
            ),
            const Divider(),
            loading == true
                ? const Center(child: CircularProgressIndicator())
                : coupon!=null?SizedBox(
              height: 200,
              child: ListView.separated(
                itemCount: coupon!.products.length,
                itemBuilder: (BuildContext context, int index) {
                  Product product = coupon!.products[index];
                  Batch batch = coupon!.batches[index];
                  return ListTile(
                    // title: Text(product.skuName),
                    subtitle: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child:
                            Center(child: Text(product.skuCode))),
                        Expanded(
                          child: Center(
                            child: SizedBox(
                                width: 75,
                                child: Text(
                                  product.skuName,
                                  maxLines: 4,
                                )),
                          ),
                        ),
                        Expanded(child: Center(child: Text(batch.mrp))),
                        Expanded(
                            child: Center(
                                child:
                                Text("$calculatedDiscountValue"))),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ),
            ):const Text('No data'),
            const SizedBox(height: 20),
            coupon!=null? ElevatedButton(
              onPressed: coupon!.products.isNotEmpty
                  ? () {
                // fetchData();
                sendData();
              }
                  : null,
              style: coupon!.products.isNotEmpty
                  ? ElevatedButton.styleFrom(
                // Enabled button style
                backgroundColor: Colors.blue,
                // Other styles such as text color, elevation, etc.
              )
                  : ElevatedButton.styleFrom(
                // Disabled button style
                backgroundColor:
                Colors.grey, // Change the color for disabled state
                // Other styles for disabled state
              ),
              child: const Text('Generate Coupon'),
            ):const Text('No data'),
          ],
        ),
      ),
    );
  }

/*  Future<void> fetchSKUData(String skuCode) async {
    final String apiUrl =
        'http://199.healthandglowonline.in/selfcheck_uat/api/checkout/geteandetail?ean_code=$skuCode&location=106';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      Coupon apiResponse = Coupon.fromJson(responseData);

    } else {
      // Handle the API call error here
      print('Failed to fetch SKU data. Status code: ${response.statusCode}');
    }
  }*/
  List<Map<String, dynamic>> products = [];
  bool loading = false;
  Coupon? coupon;

  Future<void> fetchData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();

      var locationCode = prefs.getString(
        'locationCode',
      );
      final response = await http.get(Uri.parse(
          'http://199.healthandglowonline.in/selfcheck_uat/api/checkout/geteandetail?ean_code=${_skuCodeController.text.toString()}&location=$locationCode'));

      print(
          'http://199.healthandglowonline.in/selfcheck_uat/api/checkout/geteandetail?ean_code=${_skuCodeController.text.toString()}&location=$locationCode');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        Coupon apiResponse = Coupon.fromJson(responseData);
        setState(() {
          coupon = apiResponse;
          loading = false;
        });

        // Access parsed data using the ApiResponse object, for example:
        String statusCode = apiResponse.statusCode;
        String status = apiResponse.status;
        String multipleMRP = apiResponse.multipleMRP;

        Product product = apiResponse.products.isNotEmpty
            ? apiResponse.products[0]
            : Product(
                locationCode: '',
                skuCode: '',
                skuName: '',
                hsnCode: '',
                hsnDescription: '',
                taxCode: '',
                taxRate: '',
                eanCode: '',
              );

        Batch batch = apiResponse.batches.isNotEmpty
            ? apiResponse.batches[0]
            : Batch(
                storeSkuLocStockNo: '',
                mrp: '',
              );

        // Use the parsed data as needed
        print('Status Code: $statusCode');
        print('Status: $status');
        print('Multiple MRP: $multipleMRP');
        print('Product SKU Name: ${product.skuName}');
        print('Product SKU Code: ${product.skuCode}');
        print('Batch MRP: ${batch.mrp}');
        calculateDiscount();
      } else {
        setState(() {
          loading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  double calculatedDiscountValue = 0.0;

  void calculateDiscount() {
    if (_discountType == DiscountType.percentage) {
      if (coupon != null) {
        calculatedDiscountValue = (double.parse(coupon!.batches[0].mrp) *
                double.parse(_discountController.text.toString())) /
            100;
      }
    } else if (_discountType == DiscountType.priceOff) {
      if (coupon != null) {
        calculatedDiscountValue = (double.parse(coupon!.batches[0].mrp) -
            double.parse(_discountController.text.toString()));
      }
    }
  }

  void sendData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userCode");
      var locationCode = prefs.getString('locationCode') ?? '106';
      const String apiUrl =
          "${Constants.apiHttpsUrl}/Coupon/Createcoupon"; // Replace with your API endpoint

      // The data you want to post
      Map<String, dynamic> postData = {
        "locationCode": locationCode,
        "skudetails": [
          {
            "skucode": coupon!.products[0].eanCode,
            "value": "$calculatedDiscountValue"
          },
        ],
        "mobileno": "${_phoneController.text.toString()}",
        "couponType": _discountType == DiscountType.percentage
            ? "Percentage"
            : "PriceOff",
        "couponvalue": 0,
      };

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(postData),
        );

        if (response.statusCode == 200) {
          setState(() {
            loading = false;
          });
          // Request successful, handle response here if needed
          print('POST request successful!');
          print('Response: ${response.body}');
          alert("Success");
          clearFields();
        } else {
          setState(() {
            loading = false;
          });
          clearFields();

          // Request failed, handle error
          print('POST request failed with status: ${response.statusCode}');
          alert("${Constants.networkIssue} \n${response.statusCode}");
        }
      } catch (e) {
        clearFields();

        setState(() {
          loading = false;
        });
        // An error occurred, handle the exception
        print('Exception: $e');
        alert("${e}\n${Constants.networkIssue}");
      }
    } catch (e) {
      clearFields();

      setState(() {
        loading = false;
      });
      alert("${e}\n${Constants.networkIssue}");
    }
  }
  void clearFields(){
    _phoneController.clear();
    _discountController.clear();
    _skuCodeController.clear();
}

  Future alert(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: Text(msg ?? 'Please try after sometime...'),
            actions: <Widget>[
              CustomElevatedButton(
                  text: 'OK',
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      },
    );
  }
}
