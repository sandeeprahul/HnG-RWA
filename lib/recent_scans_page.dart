import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/tester_product_controller.dart';
import 'package:intl/intl.dart';

class RecentScansPage extends StatelessWidget {
  const RecentScansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController ctrl = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Recent Scans'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back())),
      body: Obx(() {
        if (ctrl.recentScans.isEmpty) {
          return const Center(child: Text('No scans yet. Scan a product!'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.recentScans.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final scan = ctrl.recentScans[index];
            return ListTile(
              leading: const Icon(Icons.qr_code, size: 32, color: Colors.pink),
              title: Text(scan.barcode, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(scan.productName),
              trailing: Text(DateFormat('HH:mm:ss').format(scan.timestamp), style: const TextStyle(color: Colors.grey)),
            );
          },
        );
      }),
    );
  }
}