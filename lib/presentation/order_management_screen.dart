import 'package:flutter/material.dart';

import 'order_list_screen.dart';
import 'out_for_delivery_screen.dart';

class OrderManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Management Process',
          style: TextStyle(color: Colors.white,fontSize: 16),
        ),
        backgroundColor: Colors.orange,
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              icon: Icons.list_alt,
              label: 'All Orders',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  const OrderListScreen()));

                // Add functionality here
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              icon: Icons.local_shipping,
              label: 'Out For Delivery',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  const OutForDeliveryScreen(type: 0,)));
                // Add functionality here
                //OutForDeliveryScreen
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              icon: Icons.check_circle_outline,
              label: 'Delivered',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  const OutForDeliveryScreen(type: 1,)));
                // Add functionality here
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
