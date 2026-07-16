import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/testerFlow/tester_new_screen.dart';
import 'package:hng_flutter/widgets/location_search_dialog.dart';
import 'package:http/http.dart' as http;
import 'tester_models.dart';
import 'scanner_screen.dart';

class StoreDashboardScreen extends StatefulWidget {
  final int initialIndex;
  const StoreDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

enum AvailabilityTab {
  available('Available', 'Y', Color(0xFF16A34A)),
  notAvailable('Not Available', 'N', Color(0xFFDC2626)),
  pending('Pending', 'P', Color(0xFFD97706));

  final String label;
  final String flag;
  final Color color;

  const AvailabilityTab(this.label, this.flag, this.color);
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> with WidgetsBindingObserver {
  late TesterController controller;
  int _currentIndex = 0;
  final Map<int, bool> _expandedCategories = {};
  final Map<int, Map<int, bool>> _expandedBrands = {};
  final Map<int, Map<int, Map<AvailabilityTab, bool>>> _loadingBrandTabs = {};
  final Map<int, Map<int, Map<AvailabilityTab, List<Map<String, dynamic>>>>>
      _brandTabSkuLists = {};
  final Map<int, Map<int, Map<AvailabilityTab, String>>> _brandTabErrors = {};
  final Map<int, Map<int, AvailabilityTab>> _selectedBrandTabs = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    if (!Get.isRegistered<TesterController>()) {
      Get.put(TesterController());
    }
    controller = Get.find<TesterController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureLocationSelected();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    if (controller.storeCode.value.isNotEmpty) {
      await controller.fetchMasterSummary();
      await controller.loadFromPrefs(); // Ensure recent scans are refreshed/cleaned
      // Clear cached brand SKU lists to ensure data freshness when re-opened
      setState(() {
        _brandTabSkuLists.clear();
        _brandTabErrors.clear();
        _loadingBrandTabs.clear();
      });
    }
  }

  Future<void> _showLocationDialog() async {
    await controller.loadUserCode();
    if (!mounted) return;
    final userCode = controller.userCode.value;
    final selectedLocation = await showDialog(
      context: context,
      builder: (context) => LocationSearchDialog(userId: userCode),
    );
    if (selectedLocation != null) {
      await controller.updateLocation(
        selectedLocation['locationCode'] ?? '',
        selectedLocation['locationName'] ?? '',
      );
      if (mounted) {
        await controller.fetchMasterSummary();
      }
    }
  }

  Future<bool> _ensureLocationSelected() async {
    await controller.loadFromPrefs();
    await controller.loadUserCode();
    if (mounted && controller.storeCode.value.isEmpty) {
      if (await controller.fetchAndAutoSelectLocation()) {
        if (mounted) {
          await controller.fetchMasterSummary();
        }
        return true;
      }
      await _showLocationDialog();
    } else if (controller.storeCode.value.isNotEmpty) {
      if (mounted) {
        await controller.fetchMasterSummary();
      }
    }
    return controller.storeCode.value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent, // Make status bar transparent to show gradient
        statusBarIconBrightness: Brightness.light, // White icons
        statusBarBrightness: Brightness.dark, // For iOS
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboardPage(),
              const TesterNewScreen(showBackButton: false),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildDashboardPage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Obx(
            () => controller.isLoadingMasterSummary.value
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00A8A8),
                    ),
                  )
                : controller.masterSummary.value == null
                    ? const Center(
                        child: Text('No data available'),
                      )
                    : _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00A8A8),
        unselectedItemColor: const Color(0xFF64748B),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _refreshData();
          }
        },
      ),
    );
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Color(0xFF00A8A8)),
                title: Text(
                  'Store Dashboard',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00A8A8)),
                title: Text(
                  'Scan Product',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                onTap: () {
                  // Navigator.pop(context);
                  Get.to(const TesterNewScreen());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      // margin: const EdgeInsets.only(top: 56),
      padding: const EdgeInsets.fromLTRB( 16, 56, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Store Dashboard',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Visibility(
            visible: false,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF00A8A8),
                shape: BoxShape.circle,
              ),
              child: Obx(
                () => Text(
                  controller.userCode.value.isNotEmpty
                      ? controller.userCode.value.substring(0, 2).toUpperCase()
                      : 'JS',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final summary = controller.masterSummary.value!;
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLocationChip(),
          const SizedBox(height: 16),
          _buildOverallStatus(summary),
          const SizedBox(height: 16),
          _buildStartHereBanner(summary),
          const SizedBox(height: 24),
          _buildCategoriesHeader(),
          const SizedBox(height: 12),
          ...summary.data.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return _buildCategoryCard(category, index);
          }).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLocationChip() {
    return GestureDetector(
      onTap: _showLocationDialog,
      child: Obx(
        () => Container(
          alignment: Alignment.center,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0369A1).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: Color(0xFF0369A1), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.locationName.value.isNotEmpty
                        ? '${controller.locationName.value} (${controller.storeCode.value})'
                        : 'Tap to select store location',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                ),
                const Icon(Icons.edit, color: Color(0xFF0369A1), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStatus(MasterSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY\'S OVERALL STATUS',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalCount}',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Total SKUs tracked at this store',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          _buildProgressBar(summary),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusStat(
                '${summary.totalAvailableCount}',
                'Available',
                const Color(0xFF16A34A),
              ),
              _buildStatusStat(
                '${summary.totalNotAvailableCount}',
                'Not Available',
                const Color(0xFFDC2626),
              ),
              _buildStatusStat(
                '${summary.totalPendingCount}',
                'Pending',
                const Color(0xFFD97706),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MasterSummary summary) {
    final total = summary.totalCount.toDouble();
    final availableWidth =
        total > 0 ? (summary.totalAvailableCount / total) : 0.0;
    final notAvailableWidth =
        total > 0 ? (summary.totalNotAvailableCount / total) : 0.0;
    final pendingWidth = total > 0 ? (summary.totalPendingCount / total) : 0.0;

    return Container(
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE2E8F0),
      ),
      child: Row(
        children: [
          if (availableWidth > 0)
            Expanded(
              flex: (availableWidth * 1000).toInt(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(8),
                    right: Radius.circular(8),
                  ),
                ),
              ),
            ),
          if (notAvailableWidth > 0)
            Expanded(
              flex: (notAvailableWidth * 1000).toInt(),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          if (pendingWidth > 0)
            Expanded(
              flex: (pendingWidth * 1000).toInt(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(8),
                  // borderRadius: BorderRadius.horizontal(
                  //   right: availableWidth == 0 && notAvailableWidth == 0
                  //       ? const Radius.circular(8)
                  //       : const Radius.circular(8),
                  //   left: availableWidth == 0 && notAvailableWidth == 0
                  //       ? const Radius.circular(8)
                  //       : const Radius.circular(8),
                  // ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusStat(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartHereBanner(MasterSummary summary) {
    // Find category with the most pending items
    CategorySummary? topCategory;
    int maxPending = 0;
    for (var cat in summary.data) {
      if (cat.pendingCount > maxPending) {
        maxPending = cat.pendingCount;
        topCategory = cat;
      }
    }
    if (topCategory == null || maxPending == 0) {
      topCategory = summary.data.isNotEmpty ? summary.data[0] : null;
      maxPending = topCategory?.pendingCount ?? 0;
    }
    if (topCategory == null) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      child: Row(
        children: [
          const Text('👆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'START HERE',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                Text(
                  '${topCategory.execCatName} has the most pending items ($maxPending)',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF92400E), size: 26),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'CATEGORIES',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          'Sorted: most pending first',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategorySummary category, int index) {
    final isExpanded = _expandedCategories[index] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedCategories[index] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.execCatName,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFF64748B),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCategoryChip('Total', category.totalCount,
                            const Color(0xFF64748B)),
                        _buildCategoryChip('Available', category.availableCount,
                            const Color(0xFF16A34A)),
                        _buildCategoryChip(
                            'Not Available',
                            category.notAvailableCount,
                            const Color(0xFFDC2626)),
                        _buildCategoryChip('Pending', category.pendingCount,
                            const Color(0xFFD97706)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProgressBarForCategory(category),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  ...category.brands.asMap().entries.map((entry) {
                    final brandIndex = entry.key;
                    final brand = entry.value;
                    return _buildBrandItem(category, brand, index, brandIndex);
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchBrandSkuList(String execCatName, String brandName,
      int categoryIndex, int brandIndex, AvailabilityTab tab) async {
    // Initialize nested maps if necessary
    if (!_loadingBrandTabs.containsKey(categoryIndex)) {
      _loadingBrandTabs[categoryIndex] = {};
    }
    if (!_loadingBrandTabs[categoryIndex]!.containsKey(brandIndex)) {
      _loadingBrandTabs[categoryIndex]![brandIndex] = {};
    }
    _loadingBrandTabs[categoryIndex]![brandIndex]![tab] = true;

    if (!_brandTabErrors.containsKey(categoryIndex)) {
      _brandTabErrors[categoryIndex] = {};
    }
    if (!_brandTabErrors[categoryIndex]!.containsKey(brandIndex)) {
      _brandTabErrors[categoryIndex]![brandIndex] = {};
    }
    _brandTabErrors[categoryIndex]![brandIndex]![tab] = '';

    setState(() {});

    try {
      final locationCode = controller.storeCode.value;
      if (locationCode.isEmpty) {
        _brandTabErrors[categoryIndex]![brandIndex]![tab] =
            'No location selected';
        _loadingBrandTabs[categoryIndex]![brandIndex]![tab] = false;
        setState(() {});
        return;
      }

      final url = Uri.parse(
          'https://rwaweb.healthandglowonline.co.in/Tester_sku/api/store-soh/sku-list?location_code=$locationCode&exec_cat_name=${Uri.encodeComponent(execCatName)}&brand_name=${Uri.encodeComponent(brandName)}&available_flag=${tab.flag}');

      print("_fetchBrandSkuList URL: $url");
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!_brandTabSkuLists.containsKey(categoryIndex)) {
          _brandTabSkuLists[categoryIndex] = {};
        }
        if (!_brandTabSkuLists[categoryIndex]!.containsKey(brandIndex)) {
          _brandTabSkuLists[categoryIndex]![brandIndex] = {};
        }

        _brandTabSkuLists[categoryIndex]![brandIndex]![tab] =
            (data['data'] as List<dynamic>)
                .map((item) => item as Map<String, dynamic>)
                .toList();
        _brandTabErrors[categoryIndex]![brandIndex]![tab] = '';
      } else {
        _brandTabErrors[categoryIndex]![brandIndex]![tab] =
            'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _brandTabErrors[categoryIndex]![brandIndex]![tab] = 'Error: $e';
    } finally {
      _loadingBrandTabs[categoryIndex]![brandIndex]![tab] = false;
      setState(() {});
    }
  }

  Widget _buildProgressBarForCategory(CategorySummary category) {
    final total = category.totalCount.toDouble();
    final availableWidth = total > 0 ? (category.availableCount / total) : 0.0;
    final notAvailableWidth =
        total > 0 ? (category.notAvailableCount / total) : 0.0;
    final pendingWidth = total > 0 ? (category.pendingCount / total) : 0.0;

    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFFE2E8F0),
      ),
      child: Row(
        children: [
          if (availableWidth > 0)
            Expanded(
              flex: (availableWidth * 1000).toInt(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          if (notAvailableWidth > 0)
            Expanded(
              flex: (notAvailableWidth * 1000).toInt(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          if (pendingWidth > 0)
            Expanded(
              flex: (pendingWidth * 1000).toInt(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.horizontal(
                    right: availableWidth == 0 && notAvailableWidth == 0
                        ? const Radius.circular(6)
                        : Radius.zero,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrandItem(
    CategorySummary category,
    BrandSummary brand,
    int categoryIndex,
    int brandIndex,
  ) {
    final brandExpandedMap = _expandedBrands[categoryIndex] ?? {};
    final isBrandExpanded = brandExpandedMap[brandIndex] ?? false;

    // Get selected tab for this brand, default to pending
    if (!_selectedBrandTabs.containsKey(categoryIndex)) {
      _selectedBrandTabs[categoryIndex] = {};
    }
    if (!_selectedBrandTabs[categoryIndex]!.containsKey(brandIndex)) {
      _selectedBrandTabs[categoryIndex]![brandIndex] = AvailabilityTab.pending;
    }
    final selectedTab = _selectedBrandTabs[categoryIndex]![brandIndex]!;

    // Get loading, error, and sku list for the selected tab
    final loadingMap = _loadingBrandTabs[categoryIndex] ?? {};
    final brandLoadingMap = loadingMap[brandIndex] ?? {};
    final isLoading = brandLoadingMap[selectedTab] ?? false;

    final errorMap = _brandTabErrors[categoryIndex] ?? {};
    final brandErrorMap = errorMap[brandIndex] ?? {};
    final error = brandErrorMap[selectedTab] ?? '';

    final skuListMap = _brandTabSkuLists[categoryIndex] ?? {};
    final brandSkuListMap = skuListMap[brandIndex] ?? {};
    final skuList = brandSkuListMap[selectedTab] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEDF2F7),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (!_expandedBrands.containsKey(categoryIndex)) {
                    _expandedBrands[categoryIndex] = {};
                  }
                  _expandedBrands[categoryIndex]![brandIndex] =
                      !isBrandExpanded;
                });
                if (!isBrandExpanded && skuList.isEmpty) {
                  _fetchBrandSkuList(category.execCatName, brand.brandName,
                      categoryIndex, brandIndex, selectedTab);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        brand.brandName,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Icon(
                        isBrandExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF92400E),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${brand.totalCount} Total',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available: ${brand.availableCount}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Not available: ${brand.notAvailableCount}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pending: ${brand.pendingCount}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isBrandExpanded) ...[
            const SizedBox(height: 16),
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: AvailabilityTab.values.map((tab) {
                  final isSelected = tab == selectedTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBrandTabs[categoryIndex]![brandIndex] = tab;
                        });
                        // Fetch data for this tab if not already loaded
                        final brandSkuListMap =
                            _brandTabSkuLists[categoryIndex]?[brandIndex] ?? {};
                        if (brandSkuListMap[tab]?.isEmpty ?? true) {
                          _fetchBrandSkuList(category.execCatName,
                              brand.brandName, categoryIndex, brandIndex, tab);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? tab.color.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: tab.color, width: 2)
                              : null,
                        ),
                        child: Text(
                          tab.label,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? tab.color
                                : const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFF00A8A8),
                  ),
                ),
              )
            else if (error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDC2626)),
                ),
                child: Column(
                  children: [
                    Text(
                      error,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFFDC2626),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _fetchBrandSkuList(
                          category.execCatName,
                          brand.brandName,
                          categoryIndex,
                          brandIndex,
                          selectedTab),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8A8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (skuList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No SKUs found',
                  // 'No SKUs found for ${selectedTab.label.toLowerCase()}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...skuList.map((sku) => _buildSkuCard(sku)),
          ],
        ],
      ),
    );
  }

  Widget _buildSkuCard(Map<String, dynamic> sku) {
    String available = sku['AVAILABLE']?.toString() ?? '';
    Color statusColor;
    String statusText;

    if (available == 'Y') {
      statusColor = const Color(0xFF16A34A);
      statusText = 'Available';
    } else if (available == 'N') {
      statusColor = const Color(0xFFDC2626);
      statusText = 'Not Available';
    } else {
      statusColor = const Color(0xFFD97706);
      statusText = 'Pending';
    }

    // Format Last_Updated_Datetime
    String formattedDate = '';
    if (sku['Last_Updated_Datetime'] != null) {
      try {
        DateTime dateTime = DateTime.parse(sku['Last_Updated_Datetime']);
        formattedDate =
            '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedDate = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SKU: ${sku['PARENT_SKU_CODE']?.toString() ?? ''}",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sku['SKU_NAME']?.toString() ?? 'Unknown',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (sku['REMARKS'] != null &&
              sku['REMARKS'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Remarks: ${sku['REMARKS']}',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (sku['No_Of_Days'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'No. of Days: ${sku['No_Of_Days']}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              if (formattedDate.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 2),
                    Text(
                      formattedDate,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
