import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manager_review_controller.dart';

class ManagerReviewPage extends StatelessWidget {
  const ManagerReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ManagerReviewController controller = Get.put(ManagerReviewController());

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Manager Review',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // actions: [
        //   Row(
        //     children: const [
        //       Icon(Icons.signal_cellular_alt, color: Colors.blueGrey, size: 16),
        //       SizedBox(width: 4),
        //       Icon(Icons.battery_full, color: Colors.green, size: 16),
        //       SizedBox(width: 12),
        //     ],
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(controller),
                    const SizedBox(height: 24),
                    _buildSummaryStats(controller),
                    const SizedBox(height: 32),
                    const Text(
                      'PENDING REVIEW',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 12),
                    ...controller.reviewItems.asMap().entries.map((entry) {
                      return _buildReviewCard(controller, entry.key, entry.value);
                    }).toList(),
                    const SizedBox(height: 24),
                    Text(
                      'PENDING CAPTURE (${controller.pendingCaptureCount} ITEMS)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 12),
                    _buildPendingCaptureCard(controller),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            _buildStickyBottomButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ManagerReviewController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Captures',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'High Street Phoenix · March 2026',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${controller.pendingReviewCount} pending',
            style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(ManagerReviewController controller) {
    return Row(
      children: [
        _statBox("CAPTURED", controller.capturedCount.value.toString(), Colors.white, Colors.black),
        const SizedBox(width: 12),
        _statBox("APPROVED", controller.approvedCount.value.toString(), const Color(0xFFE0F2F1), const Color(0xFF00897B)),
        const SizedBox(width: 12),
        _statBox("REJECTED", controller.rejectedCount.value.toString(), const Color(0xFFFFEBEE), const Color(0xFFD32F2F)),
      ],
    );
  }

  Widget _statBox(String label, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.6))),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ManagerReviewController controller, int index, Map<String, dynamic> item) {
    bool isPending = item['status'] == 'Review';
    bool isApproved = item['status'] == 'Approved';
    bool isRetake = item['status'] == 'Retake';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRetake ? Colors.red.shade100 : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.image, color: Colors.grey)),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        color: Colors.black54,
                        child: Text(
                          item['thumbCode'],
                          style: const TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        _statusPill(item['status']),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('By ${item['userName']} · ${item['time']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _actionButton("X Reject", const Color(0xFFFFEBEE), const Color(0xFFD32F2F), () => controller.rejectItem(index)),
                const SizedBox(width: 8),
                _actionButton("↶ Retake", const Color(0xFFFFF3E0), const Color(0xFFE65100), () {}),
                const SizedBox(width: 8),
                _actionButton("✓ Approve", const Color(0xFFE0F2F1), const Color(0xFF00897B), () => controller.approveItem(index)),
              ],
            ),
          ],
          if (isApproved) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check, color: Color(0xFF2E7D32), size: 16),
                const SizedBox(width: 8),
                Text('Approved by you · ${item['approvedTime']}', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
          if (isRetake && item['warning'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['warning'],
                      style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    Color bgColor;
    Color textColor;
    if (status == 'Approved') {
      bgColor = const Color(0xFFE0F2F1);
      textColor = const Color(0xFF00897B);
    } else if (status == 'Retake') {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _actionButton(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildPendingCaptureCard(ManagerReviewController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom, color: Colors.brown, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.pendingCaptureCount} items not yet captured',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Awaiting store staff · Due: ${controller.dueDate}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomButton(ManagerReviewController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Submit to Area Manager (${controller.approvedCount}/${controller.capturedCount} approved)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
