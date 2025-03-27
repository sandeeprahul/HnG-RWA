import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/controllers/order_details_controller.dart';

import '../data/order_model.dart';

class PaymentSummary extends StatelessWidget {
  final Order order;
  final OrderDetailsController orderController;

  const PaymentSummary({
    super.key,
    required this.order,
    required this.orderController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() { // Now it will update when the data changes
      int totalChangedQuantity = _calculateTotalChangedQuantity();
      return Card(
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
              _buildSummaryRow('Total Order Value:', "${order.subTotal}"),
              _buildSummaryRow('Discount:', "${order.discountTotal}"),
              _buildSummaryRow('Total Invoice Value:', "${order.total}"),
              _buildSummaryRow('Delivery Charges:', "${order.shippingPrice}"),
              _buildSummaryRow('Total Changed Qty:', "$totalChangedQuantity"),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    });
  }

  int _calculateTotalChangedQuantity() {
    int totalChangedQty = 0;

    for (var item in order.items) {
      if (orderController.selectedProductData.containsKey(item.skuCode)) {
        int originalQty = item.quantity;
        int modifiedQty = orderController.selectedProductData[item.skuCode]["quantity"] ?? originalQty;
        totalChangedQty += modifiedQty;
      }
    }

    return totalChangedQty;
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
