import 'package:flutter/material.dart';
import 'package:hng_flutter/widgets/order_list_widget.dart';

import 'order_details_screen.dart';

class OutForDeliveryScreen extends StatefulWidget {
  final int type;

  const OutForDeliveryScreen({super.key, required this.type});

  @override
  State<OutForDeliveryScreen> createState() => _OutForDeliveryScreenState();
}

class _OutForDeliveryScreenState extends State<OutForDeliveryScreen> {
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
        title:  Text(
          widget.type == 0? 'Update Out For Delivery':"Delivery Update",
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
            child: OrderListWidget(
                orders: orders,
                onOrderTap: (order) {
                  if (widget.type == 0) {
                    showDeliveryPopup(context);
                  } else {
                    showOutForDeliveryPopup(context);
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

  void showDeliveryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order ID : 3003-106-1788734',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildTextField('Delivery Executive Name'),
              const SizedBox(height: 12),
              buildTextField('Delivery Executive Mobile No'),
              const SizedBox(height: 12),
              buildTextField('Estimated Minutes For Delivery'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add your logic here
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Out For Delivery',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showOutForDeliveryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order ID : 3003-106-1788734',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildTextField('Delivered to Person Name'),
              const SizedBox(height: 12),
              buildTextField('Delivered to Mobile No'),
              SizedBox(height: 4,),
              ElevatedButton(
                onPressed: () {
                  // Add your logic here
                  // Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send OTP',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              buildTextField('Enter OTP'),
              SizedBox(height: 4,),

              ElevatedButton(
                onPressed: () {
                  // Add your logic here
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
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
              ElevatedButton(
                onPressed: () {
                  // Add your logic here
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Out For Delivery',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        TextField(
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
