import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

import '../data/UserLocations.dart';
import 'location_controller.dart';

class OrderController extends GetxController {
  var isLoading = true.obs;
  var isError = false.obs;
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
