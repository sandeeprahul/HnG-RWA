import 'package:flutter/material.dart';

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
        title: const Row(
          children: [
            Text('Orders'),

            // Spacer(),
            // Icon(Icons.document_scanner_outlined),

          ],
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

                  border: UnderlineInputBorder(

                  )
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Row(
                      // mainAxisAlignmentlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Order ID: ${order['orderId']}',
                          style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Status: ',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              Text(
                                order['status'],
                                style: TextStyle(
                                  color: order['status'] == 'ORDER_APPROVED' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Method: ',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              Text(
                                order['paymentMethod'] ?? 'null',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Status: ',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              Text(
                                order['paymentStatus'] ?? 'null',
                                style: TextStyle(
                                  color: order['paymentStatus'] == 'SUCCESS' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),const Spacer(),
                              Text(
                                order['date'],
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // trailing: Text(
                    //   order['date'],
                    //   style: const TextStyle(color: Colors.black54, fontSize: 12),
                    // ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                  )
                  ,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
