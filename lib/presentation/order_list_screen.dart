import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/widgets/order_list_widget.dart';

import '../controllers/order_controller.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderController orderController = Get.put(OrderController());

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
            child: Obx(() {
              if (orderController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (orderController.isError.value) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Failed to load orders"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => orderController.fetchOrders(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              } else {
                return OrderListWidget(
                    orders: orderController.orders,
                    onOrderTap: (order) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsScreen(order: order),
                        ),
                      );
                    });
              }
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
