import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/marketing_collaterals_controller.dart';
import 'camera_overlay_page.dart';
import 'manager_review_page.dart';

class MarketingCollateralsPage extends StatelessWidget {
  const MarketingCollateralsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketingCollateralsController controller = Get.put(MarketingCollateralsController());

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Marketing Collaterals',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'March 2026 — High Street Phoenix',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSection(controller),
                    const SizedBox(height: 24),
                    _buildFilters(controller),
                    const SizedBox(height: 24),
                    ...controller.categories.entries.map((entry) {
                      return _buildCategorySection(entry.key, entry.value);
                    }).toList(),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildProgressSection(MarketingCollateralsController controller) {
    double progress = controller.capturedItems.value / controller.totalItems.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Capture Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${controller.capturedItems}/${controller.totalItems}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.orange,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '✓ ${controller.capturedItems} captured',
                style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w500, fontSize: 13),
              ),
              Text(
                '${controller.totalItems.value - controller.capturedItems.value} remaining',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(MarketingCollateralsController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.filters.map((filter) {
          bool isSelected = controller.selectedFilter.value == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.updateFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE65100) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildCollateralItem(item)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCollateralItem(Map<String, dynamic> item) {
    bool isDone = item['status'] == 'Done';
    bool isPending = item['status'] == 'Pending';

    return GestureDetector(
      onTap: () {
        // In your previous screen's navigation:
        Get.to(() => CameraOverlayPage( ///CamHelpPage
          floorBay: "Floor Bay",  // Get from your controller
          storeName: "Health & Glow",
          mallName: "High Street Phoenix",
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDone ? Colors.green.shade100 : Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isDone
                  ? const Icon(Icons.check, color: Color(0xFF2E7D32), size: 24)
                  : _getIconForType(item['type']),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['category'],
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildStatusButton(item['status']),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status) {
    Color bgColor;
    Color textColor;
    
    if (status == 'Capture') {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
    } else if (status == 'Done') {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    } else {
      bgColor = const Color(0xFFFFF3E0).withOpacity(0.5);
      textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _getIconForType(String? type) {
    if (type == 'floor') return const Icon(Icons.file_present_outlined, color: Colors.blueGrey, size: 24);
    if (type == 'wall') return const Icon(Icons.image_outlined, color: Colors.blueGrey, size: 24);
    if (type == 'moveable') return const Icon(Icons.door_front_door_outlined, color: Colors.brown, size: 24);
    return const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey, size: 24);
  }

  Widget _buildSubmitButton(MarketingCollateralsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => const ManagerReviewPage());

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF616161),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Submit for Review (${controller.capturedItems}/${controller.totalItems})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
