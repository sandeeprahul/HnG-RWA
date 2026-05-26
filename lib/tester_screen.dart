// lib/app/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/recent_scans_page.dart';
import 'package:hng_flutter/scanner_page.dart';
import 'package:hng_flutter/tester_camera_scanner_widget.dart';
import 'package:hng_flutter/tester_product_controller.dart';
import 'package:hng_flutter/tester_scan_controller.dart';

class TesterScreen extends StatelessWidget {
  const TesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController ctrl = Get.find();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
        title: const Text('Tester Availability'),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              // onPressed: () => Get.toNamed('/scanner')
              onPressed: () => Get.to(const ScannerPage())

          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store & Parent Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Store: ${ctrl.parentInfo.value.storeId}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 24),
                          Text('Parent SKU: ${ctrl.parentInfo.value.parentSku}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(ctrl.parentInfo.value.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(ctrl.parentInfo.value.brand,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Selection row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(ctrl.selectedCountText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500))),
                  TextButton(
                      onPressed: ctrl.toggleSelectAll,
                      child: const Text('Select All')),
                ],
              ),
              const SizedBox(height: 8),

              // Child products list
              Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctrl.childProducts.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final p = ctrl.childProducts[index];
                      return CheckboxListTile(
                        value: p.isSelected,
                        onChanged: (_) => ctrl.toggleSelection(index),
                        title: Text('${p.sku}  •  ${p.shadeName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('SKU: ${p.sku}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        secondary: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: p.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: p.status.color.withOpacity(0.3)),
                          ),
                          child: Text(p.status.displayName,
                              style: TextStyle(
                                  color: p.status.color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12)),
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  )),
              const SizedBox(height: 20),

              // Buttons row 1
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ctrl.confirmAllAvailable,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Confirm All Available'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue)),
                      child: Obx(
                          () => Text("Today's Scans: ${ctrl.todayScansCount}")),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Buttons row 2
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.snackbar(
                          'Products Updated', ctrl.getLastUpdatedText()),
                      child: Obx(() => Text(ctrl.getLastUpdatedText())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.to(const ScannerPage()),
                      // onPressed: () => Get.toNamed('/scanner'),
                      child: const Text('Scan Another Product'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick link to Recent Scans
              GestureDetector(
                onTap: () => Get.to(const RecentScansPage()),
                // onTap: () => Get.toNamed('/recents'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 18),
                      SizedBox(width: 8),
                      Text('View All Recent Scans →'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // if (index == 1) Get.toNamed('/scanner');
          if (index == 1) Get.to(const ScannerPage());
          // if (index == 2) Get.toNamed('/recents');
          if (index == 2) Get.to(const RecentScansPage());
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Recents'),
        ],
      ),
    );
  }
}
