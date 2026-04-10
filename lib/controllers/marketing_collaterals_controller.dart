import 'package:get/get.dart';

class MarketingCollateralsController extends GetxController {
  var isLoading = true.obs;
  
  var totalItems = 138.obs;
  var capturedItems = 12.obs;
  var selectedFilter = "All (138)".obs;

  final List<String> filters = ["All (138)", "Moveable Assets (29)", "Floor Bay (28)"];

  var categories = <String, List<Map<String, dynamic>>>{
    "FLOOR BAYS": [
      {"name": "Floor Bay — Cosmetics", "category": "Cosmetics", "status": "Capture", "type": "floor"},
      {"name": "Floor Bay — Skin Care", "category": "Skin Care", "status": "Capture", "type": "floor"},
      {"name": "Floor Bay — Hair Care", "category": "Hair", "status": "Capture", "type": "floor"},
    ],
    "WALL BAYS": [
      {"name": "Wall Bay — Dental", "category": "Dental", "status": "Capture", "type": "wall"},
      {"name": "Wall Bay — Cosmetics", "category": "Cosmetics", "status": "Done", "type": "wall"},
    ],
    "MOVEABLE ASSETS": [
      {"name": "Double Door", "category": "Glass Door", "status": "Pending", "type": "moveable"},
    ]
  }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCollateralData();
  }

  Future<void> fetchCollateralData() async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading(false);
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }
}
