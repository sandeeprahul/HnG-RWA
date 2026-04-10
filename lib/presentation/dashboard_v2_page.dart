import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_v2_controller.dart';
import 'marketing_collaterals_page.dart';

class DashboardV2Page extends StatelessWidget {
  const DashboardV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardV2Controller controller = Get.put(DashboardV2Controller());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        return RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, controller)),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDueBanner(controller),
                    const SizedBox(height: 24),
                    const Text(
                      'RETAIL ACTIVITIES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...controller.activities.map((activity) => _buildActivityCard(activity)).toList(),
                    const SizedBox(height: 80), // Space for bottom nav
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(BuildContext context, DashboardV2Controller controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE65100), Color(0xFFFF8A50)],
        ),
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(30),
        //   bottomRight: Radius.circular(30),
        // ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: const [
          //      Text(
          //       '9:41',
          //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          //     ),
          //     Text(
          //       'health & glow',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     Row(
          //       children: [
          //         Icon(Icons.signal_cellular_alt, color: Colors.white, size: 16),
          //         SizedBox(width: 4),
          //         Icon(Icons.battery_full, color: Colors.white, size: 16),
          //       ],
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 30),
          Text(
            controller.greeting.value,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                controller.userName.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text('👋', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Store', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      controller.storeName.value,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Today', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      controller.currentDate.value,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueBanner(DashboardV2Controller controller) {
    final data = controller.marketingDueData;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFEFCA8A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)
              ],
            ),
            child: const Icon(Icons.alarm, color: Color(0xFFE65100), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, color:
                  Color(0xFF855D21)
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data['deadline']} — ${data['pendingItems']} items pending',
                  style: TextStyle(color:
                  Color(0xFF8A5E20),
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    bool isMarketing = activity['title'] == 'Marketing Collaterals';
    bool hasCount = activity['type'] == 'task_with_count';

    return GestureDetector(
      onTap: () {
        if (isMarketing) {
          Get.to(() => const MarketingCollateralsPage());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isMarketing ? Border.all(color: Colors.orange, width: 1.5) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              padding: const EdgeInsets.symmetric(vertical: 18,horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _getIconForType(activity['title']),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              activity['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isMarketing ? Colors.orange.shade900 : Colors.black87,
                              ),
                            ),
                            if (activity['isNew'] == true) ...[
                              const SizedBox(width: 8),
                              const Spacer(),
                              const Text(
                                'New',
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['subtitle'],
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (activity['isNew'] != true)
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
            if (hasCount) ...[
              // const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Current', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${activity['current']}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.shade200),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Pending', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${activity['pending']}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getIconForType(String title) {
    switch (title) {
      case 'DILO':
        return const Icon(Icons.assignment_outlined, color: Colors.brown, size: 28);
      case 'Store Audit':
        return const Icon(Icons.storefront_outlined, color: Colors.green, size: 28);
      case 'Marketing Collaterals':
        return const Icon(Icons.camera_alt_outlined, color: Colors.orange, size: 28);
      case 'LPD':
        return const Icon(Icons.inventory_2_outlined, color: Colors.brown, size: 28);
      default:
        return const Icon(Icons.task, color: Colors.grey);
    }
  }

  Widget _buildBottomNav(DashboardV2Controller controller) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', 0, controller),
          _navItem(Icons.bar_chart, 'Survey', 1, controller),
          _navItem(Icons.shopping_bag_outlined, 'Retail', 2, controller),
          _navItem(Icons.person_outline, 'Profile', 3, controller, badgeCount: 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, DashboardV2Controller controller, {int badgeCount = 0}) {
    return InkWell(
      onTap: () => controller.changeNavIndex(index),
      child: Obx(() {
        bool isSelected = controller.selectedNavIndex.value == index;
        return SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: isSelected ? Colors.orange : Colors.blueGrey.shade300, size: 28),
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFE65100), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.orange : Colors.blueGrey.shade300,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
