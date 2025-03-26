import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/widgets/order_list_widget.dart';
import 'package:http/http.dart' as http;

import '../common/progress_dialog.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/order_controller.dart';
import 'order_details_screen.dart';

class OutForDeliveryScreen extends StatefulWidget {
  final int type;

  const OutForDeliveryScreen({super.key, required this.type});

  @override
  State<OutForDeliveryScreen> createState() => _OutForDeliveryScreenState();
}

class _OutForDeliveryScreenState extends State<OutForDeliveryScreen> {
  // final List<Map<String, dynamic>> orders = [
  //   {
  //     'orderId': '3003-106-1788734',
  //     'status': 'ORDER_APPROVED',
  //     'paymentMethod': 'upi',
  //     'paymentStatus': 'SUCCESS',
  //     'date': 'November 28',
  //     'icon': Icons.check_circle,
  //     'iconColor': Colors.green,
  //   },
  //   {
  //     'orderId': '1001-106-1783039',
  //     'status': 'ORDER_PAYMENT_DETAILS',
  //     'paymentMethod': 'ONLINE',
  //     'paymentStatus': "APPROVED",
  //     'date': 'November 13',
  //     'icon': Icons.local_shipping,
  //     'iconColor': Colors.grey,
  //   },
  //   {
  //     'orderId': '1001-106-1747771',
  //     'status': 'ORDER_PAYMENT_FAILED',
  //     'paymentMethod': 'PAYTM',
  //     'paymentStatus': 'FAILED',
  //     'date': 'August 22',
  //     'icon': Icons.error,
  //     'iconColor': Colors.red,
  //   },
  //   {
  //     'orderId': '3003-106-1788734',
  //     'status': 'ORDER_APPROVED',
  //     'paymentMethod': 'upi',
  //     'paymentStatus': 'SUCCESS',
  //     'date': 'November 28',
  //     'icon': Icons.check_circle,
  //     'iconColor': Colors.green,
  //   },
  //   {
  //     'orderId': '1001-106-1747771',
  //     'status': 'ORDER_PAYMENT_FAILED',
  //     'paymentMethod': 'PAYTM',
  //     'paymentStatus': 'FAILED',
  //     'date': 'August 22',
  //     'icon': Icons.error,
  //     'iconColor': Colors.red,
  //   },
  //   {
  //     'orderId': '3003-106-1788734',
  //     'status': 'ORDER_APPROVED',
  //     'paymentMethod': 'upi',
  //     'paymentStatus': 'SUCCESS',
  //     'date': 'November 28',
  //     'icon': Icons.check_circle,
  //     'iconColor': Colors.green,
  //   },
  //   {
  //     'orderId': '1001-106-1747771',
  //     'status': 'ORDER_PAYMENT_FAILED',
  //     'paymentMethod': 'PAYTM',
  //     'paymentStatus': 'FAILED',
  //     'date': 'August 22',
  //     'icon': Icons.error,
  //     'iconColor': Colors.red,
  //   },
  //   {
  //     'orderId': '3003-106-1788734',
  //     'status': 'ORDER_APPROVED',
  //     'paymentMethod': 'upi',
  //     'paymentStatus': 'SUCCESS',
  //     'date': 'November 28',
  //     'icon': Icons.check_circle,
  //     'iconColor': Colors.green,
  //   },
  // ];
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 0 ? 'Update Out For Delivery' : "Delivery Update",
          style: const TextStyle(color: Colors.white),
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
                      if (widget.type == 0) {
                        showDeliveryPopup(order);
                      } else {
                        showOutForDeliveryPopup(order);
                      }
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

  void showDeliveryPopup(Map<String, dynamic> order) {
    final DeliveryController controller = Get.put(DeliveryController());

    TextEditingController nameController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController minutesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Order ID: ${order['orderId']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildTextField('Delivery Executive Name', nameController),
            const SizedBox(height: 12),
            buildTextField('Delivery Executive Mobile No', mobileController),
            const SizedBox(height: 12),
            buildTextField('Estimated Minutes For Delivery', minutesController),
            const SizedBox(height: 20),

            // Using Obx to observe loading state
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.submitDeliveryDetails(
                            name: nameController.text,
                            mobile: mobileController.text,
                            minutes: int.tryParse(minutesController.text) ?? 0,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    // minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Out For Delivery',
                          style: TextStyle(color: Colors.white),
                        ),
                )),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent accidental dismissal
    );
  }

  void showOutForDeliveryPopup(Map<String, dynamic> order) {
    final DeliveryController controller = Get.put(DeliveryController());

    TextEditingController nameController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController minutesController = TextEditingController();
    TextEditingController otpController = TextEditingController(); // OTP Field

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Order ID: ${order['orderId']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            buildTextField('Delivered to Person Name', nameController),
            const SizedBox(height: 12),
            buildTextField('Delivered to Mobile No', mobileController),
            const SizedBox(height: 4),

            // Send OTP Button
            ElevatedButton(
              onPressed: () => controller.sendOtp(
                  mobileController.text, nameController.text, order['orderId']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Send OTP',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),

            buildTextField('Verify Otp', otpController),
            const SizedBox(height: 4),

            ElevatedButton(
              onPressed: () => controller.verifyOtp(otpController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Final Out For Delivery Button (Only visible if OTP is verified)
            ElevatedButton(
              onPressed: () {
                controller.submitDelivered(
                  orderId: order['orderId'],
                  mobile: mobileController.text,
                  name: nameController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Delivered',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Value',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}
