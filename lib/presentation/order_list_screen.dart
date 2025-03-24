import 'package:flutter/material.dart';
import 'package:hng_flutter/widgets/order_list_widget.dart';

import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final List<Map<String, dynamic>> orders = [
    {
      'orderId': '3003-106-1788734',
      'status': 'ORDER_APPROVED',
      'paymentMethod': 'upi',
      'paymentStatus': 'SUCCESS',
      'date': 'November 28',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
    },
    {
      'orderId': '1001-106-1783039',
      'status': 'ORDER_PAYMENT_DETAILS',
      'paymentMethod': 'ONLINE',
      'paymentStatus': "APPROVED",
      'date': 'November 13',
      'icon': Icons.local_shipping,
      'iconColor': Colors.grey,
    },
    {
      'orderId': '1001-106-1747771',
      'status': 'ORDER_PAYMENT_FAILED',
      'paymentMethod': 'PAYTM',
      'paymentStatus': 'FAILED',
      'date': 'August 22',
      'icon': Icons.error,
      'iconColor': Colors.red,
    },
    {
      'orderId': '3003-106-1788734',
      'status': 'ORDER_APPROVED',
      'paymentMethod': 'upi',
      'paymentStatus': 'SUCCESS',
      'date': 'November 28',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
    },
    {
      'orderId': '1001-106-1747771',
      'status': 'ORDER_PAYMENT_FAILED',
      'paymentMethod': 'PAYTM',
      'paymentStatus': 'FAILED',
      'date': 'August 22',
      'icon': Icons.error,
      'iconColor': Colors.red,
    },
    {
      'orderId': '3003-106-1788734',
      'status': 'ORDER_APPROVED',
      'paymentMethod': 'upi',
      'paymentStatus': 'SUCCESS',
      'date': 'November 28',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
    },
    {
      'orderId': '1001-106-1747771',
      'status': 'ORDER_PAYMENT_FAILED',
      'paymentMethod': 'PAYTM',
      'paymentStatus': 'FAILED',
      'date': 'August 22',
      'icon': Icons.error,
      'iconColor': Colors.red,
    },
    {
      'orderId': '3003-106-1788734',
      'status': 'ORDER_APPROVED',
      'paymentMethod': 'upi',
      'paymentStatus': 'SUCCESS',
      'date': 'November 28',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.document_scanner_outlined),
                  border: UnderlineInputBorder()),
            ),
          ),
          Expanded(
            child:OrderListWidget(orders: orders, onOrderTap: (order){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderDetailsScreen(order: order),
                ),
              );
            }),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.orange)),
            child: Row(
              children: [
                const Expanded(
                  child: Center(child: Text('ClearAll')),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange,
                    child: const Center(
                        child: Text(
                      'Filter',
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
