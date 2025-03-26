import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class OrderController extends GetxController {
  var isLoading = true.obs;
  var isError = false.obs;
  var orders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      isError(false);

      final response = await http.get(Uri.parse(
          'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/StoreOrderlist/106'));

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
