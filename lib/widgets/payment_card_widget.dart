import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/order_model.dart';

class PaymentSummary extends StatelessWidget {
  final Order order;
  final dynamic orderController;

  const PaymentSummary({
    super.key,
    required this.order,
    required this.orderController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Explicitly access the observable map to ensure GetX always registers a dependency,
      // even if order.items is empty and the loop doesn't run.
      final selectedData = orderController.selectedProductData;
      final _ = selectedData.length; 

      int totalChangedQuantity = 0;
      for (var item in order.items) {
        if (selectedData.containsKey(item.skuCode)) {
          int modifiedQty = selectedData[item.skuCode]["quantity"] ?? item.quantity;
          totalChangedQuantity += modifiedQty;
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 46),
        child: Card(
          elevation: 4,
          color: Colors.white,
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
                _buildSummaryRow('Total Order Qty:', "${order.itemCount}"),
                _buildSummaryRow('Total Order Value:', "₹${order.subTotal}"),
                _buildSummaryRow('Discount:', "₹${order.discountTotal}"),
                _buildSummaryRow('Total Invoice Value:', "₹${order.total}"),
                _buildSummaryRow('Delivery Charges:', "₹${order.shippingPrice}"),
                _buildSummaryRow('Total Changed Qty:', "$totalChangedQuantity"),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    });
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
