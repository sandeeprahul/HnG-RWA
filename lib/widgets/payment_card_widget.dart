import 'package:flutter/material.dart';
import 'package:hng_flutter/data/order_model.dart';

class PaymentSummary extends StatelessWidget {
  final Order order;
  const PaymentSummary({super.key, required this.order,});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      // margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1.5, color: Colors.grey),
            const SizedBox(height: 8),
            _buildSummaryRow('No of Items:', "${order.itemCount}"),
            _buildSummaryRow('Total Order Value:', "${order.subTotal}"),
            _buildSummaryRow('Discount:',  "${order.discountTotal}"),
            _buildSummaryRow('Total Invoice Value:', "${order.total}"),
            // _buildSummaryRow('Paid With Glow Points:', '₹0'),
            // _buildSummaryRow('Paid With Coupon:', '₹0'),
            _buildSummaryRow('Delivery Charges:',  "${order.shippingPrice}"),
            const SizedBox(height: 8),
            // const Divider(thickness: 1.5, color: Colors.grey),
            // const SizedBox(height: 8),

          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
