import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

import 'location_controller.dart';

class OrderController extends GetxController {
  var isLoading = true.obs;
  var isError = false.obs;
  var isHyperLocal = false.obs; // Added flag for OMS source
  var orders = <Map<String, dynamic>>[].obs;
  final LocationController locationController = Get.put(LocationController());

  var type = 0.obs; // Reactive variable

  OrderController(int initialType) {
    type.value = initialType;
  }

  void updateType(int newType) {
    type.value = newType;
  }

  @override
  void onInit() {
    // fetchOrders();
    super.onInit();
  }

  Future<void> fetchOrders(String locationCode) async {
    try {
      orders.clear();
      orders.value = [];
      isLoading(true);
      isError(false);

      late String url;
      if (type.value == -1) {
        url =
            "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/StoreOrderlist/$locationCode";
      } else if (type.value == 1) {
        url =
            "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/StoreOrderlistOFD/$locationCode";
      } else if (type.value == 0) {
        url =
            "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/StoreOrderlistRTS/$locationCode";
      }

      final response = await http.get(Uri.parse(url));

      print(response.body);
      print(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          orders.value = (data['data'] as List)
              .map((order) => {
                    'orderId': order['order_id'],
                    'status': order['status'],
                    'paymentMethod': order['payment_mode_name'],
                    'paymentStatus': order['payment_mode_status'],
                    'date': _formatDate(order['order_date']),
                    'icon': _getOrderIcon(order['status']),
                    'iconColor': _getOrderIconColor(order['status']),
                  })
              .toList();
        }
      } else {
        isError(true);
      }
    } catch (e) {
      isError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchEcomOrders(String storeID, String orderType, String status) async {
    try {
      orders.clear();
      isLoading(true);
      isError(false);

      final url = "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/StoreOrderlist/$storeID/$orderType/open";
      // final url = "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/StoreOrderlist/$storeID/$orderType/$status";

      final response = await http.get(Uri.parse(url));

      print("ECOM Orders URL: $url");
      print("ECOM Orders Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          orders.value = (data['data'] as List)
              .map((order) => {
                    'orderId': order['orderId'],
                    'status': order['status'],
                    'paymentMethod': order['paymentModeName'],
                    'paymentStatus': order['paymentModeStatus'],
                    'date': _formatDate(order['orderDate']),
                    'icon': _getOrderIcon(order['status']),
                    'iconColor': _getOrderIconColor(order['status']),
                    'shippingMethod': order['shippingMethod'],
                  })
              .toList();
        }
      } else if (response.statusCode == 404) {
        String msg = "Orders not found (404)";
        try {
          final data = json.decode(response.body);
          msg = data['message'] ?? data['Message'] ?? msg;
        } catch (_) {}
        Fluttertoast.showToast(msg: msg);
        isError(true);
      } else {
        isError(true);
      }
    } catch (e) {
      print("Error fetching ECOM orders: $e");
      isError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateHandedOverToCustomer(String orderId) async {
    try {
      isLoading.value = true;
      const url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/UpdateHandedOverToCustomer';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Order_id": orderId}),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "ok") {
          Fluttertoast.showToast(
            msg: responseBody['message'] ?? 'Order handed over successfully',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          return true;
        } else {
          Fluttertoast.showToast(
            msg: responseBody['message'] ?? 'Failed to update status',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Server returned ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Update failed: $e");
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  IconData _getOrderIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.pending;
      case 'ORDER_APPROVED':
        return Icons.check_circle;
      case 'ORDER_PAYMENT_FAILED':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Color _getOrderIconColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'ORDER_APPROVED':
        return Colors.green;
      case 'ORDER_PAYMENT_FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMMM d, yyyy')
          .format(dateTime); // Example: March 24, 2025
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }
}
