import 'package:flutter/material.dart';

class OrderListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(Map<String, dynamic>) onOrderTap;

  const OrderListWidget({
    Key? key,
    required this.orders,
    required this.onOrderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Stack(
              children: [
                Row(
                  children: [
                    Text(
                      'Order ID: ${order['orderId']}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.lightGreen,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Order Status: ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        order['status'],
                        style: TextStyle(
                          color: order['status'] == 'ORDER_APPROVED'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
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
                    children: [
                      Text(
                        'Payment Status: ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        order['paymentStatus'] ?? 'null',
                        style: TextStyle(
                          color: order['paymentStatus'] == 'SUCCESS'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        order['date'],
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () => onOrderTap(order),
          ),
        );
      },
    );
  }
}
