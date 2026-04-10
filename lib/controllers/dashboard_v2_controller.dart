import 'package:get/get.dart';

class DashboardV2Controller extends GetxController {
  var isLoading = true.obs;
  
  // Data Observables
  var userName = "".obs;
  var greeting = "".obs;
  var storeName = "".obs;
  var currentDate = "".obs;
  var marketingDueData = {}.obs;
  var activities = <Map<String, dynamic>>[].obs;
  var selectedNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Mock API Response
      userName.value = "Priya Sharma";
      greeting.value = "Good afternoon";
      storeName.value = "High Street Phoenix";
      currentDate.value = "Mar 27, 2026";
      
      marketingDueData.value = {
        "title": "Marketing Capture Due",
        "deadline": "March 2026",
        "pendingItems": 138
      };

      activities.assignAll([
        {
          "title": "DILO",
          "subtitle": "View and perform assigned tasks",
          "current": 2,
          "pending": 0,
          "icon": "assets/icons/dilo.png", // Fallback to IconData in UI if not found
          "type": "task_with_count"
        },
        {
          "title": "Store Audit",
          "subtitle": "View and perform assigned tasks",
          "icon": "assets/icons/audit.png",
          "type": "simple"
        },
        {
          "title": "Marketing Collaterals",
          "subtitle": "Capture fixture & display photos",
          "icon": "assets/icons/marketing.png",
          "isNew": true,
          "type": "simple"
        },
        {
          "title": "LPD",
          "subtitle": "View and perform assigned tasks",
          "icon": "assets/icons/lpd.png",
          "type": "simple"
        },
      ]);
      
    } catch (e) {
      print("Error fetching dashboard: $e");
    } finally {
      isLoading(false);
    }
  }

  void changeNavIndex(int index) {
    selectedNavIndex.value = index;
  }
}
