import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OrderDetailsController extends GetxController {
  var borderColors = <String, Color>{}.obs; // Map to store border colors

  Future<void> scanProduct(String skuCode) async {
    try {
      final response = await http.get(
        Uri.parse("http://36.255.252.199/selfcheck_uat/api/checkout/geteandetail?location=106&ean_code=$skuCode"), // Replace with actual API URL
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode({"sku_code": skuCode}),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        bool isProductFound = responseData["product"]
            .any((product) => product["SKU_CODE"] == skuCode);

        if (isProductFound) {

          borderColors[skuCode] = Colors.green; // Change border to green
        } else {
          borderColors[skuCode] = Colors.red; // Keep border red
        }
      } else {
        borderColors[skuCode] = Colors.red; // Error case, keep red
      }
    } catch (e) {
      borderColors[skuCode] = Colors.red; // Handle error
    }
  }
}
