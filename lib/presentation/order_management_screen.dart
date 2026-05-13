import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ecom_order_list_screen.dart';
import 'order_list_screen.dart';
import 'out_for_delivery_screen.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // _buildSectionTitle("HYPERLOCAL (OMS)"),
          _buildMenuCard(
            context,
            icon: Icons.list_alt_rounded,
            title: 'All Orders',
            subtitle: 'Manage local store orders',
            color: Colors.deepOrangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderListScreen())),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            icon: Icons.local_shipping_rounded,
            title: 'Out For Delivery',
            subtitle: 'Assign & track deliveries',
            color: Colors.deepOrangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OutForDeliveryScreen(type: 0))),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            icon: Icons.check_circle_rounded,
            title: 'Delivered',
            subtitle: 'View completed handovers',
            color: Colors.deepOrangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OutForDeliveryScreen(type: 1))),
          ),

          const SizedBox(height: 32),
          // _buildSectionTitle("E-COMMERCE (ECOM)"),
          // _buildMenuCard(
          //   context,
          //   icon: Icons.shopping_bag_rounded,
          //   title: 'Standard Orders',
          //   subtitle: 'Manage ECOM standard shipping',
          //   color: Colors.deepOrange,
          //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EcomOrderListScreen(orderType: "Standard", status: "open"))),
          // ),
          // const SizedBox(height: 12),
          // _buildMenuCard(
          //   context,
          //   icon: Icons.bolt_rounded,
          //   title: 'Express Orders',
          //   subtitle: 'Manage ECOM express shipping',
          //   color: Colors.deepOrange,
          //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EcomOrderListScreen(orderType: "Express", status: "open"))),
          // ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
