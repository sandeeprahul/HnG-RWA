import 'package:get/get.dart';

class ManagerReviewController extends GetxController {
  var isLoading = true.obs;

  // Summary counts
  var capturedCount = 12.obs;
  var approvedCount = 7.obs;
  var rejectedCount = 2.obs;
  var pendingReviewCount = 12.obs;

  // Review items
  var reviewItems = <Map<String, dynamic>>[
    {
      "title": "Floor Bay — Cosmetics",
      "userName": "Priya Sharma",
      "time": "09:41 AM",
      "status": "Review", // Review, Approved, Retake
      "type": "pending",
      "thumbCode": "HSP 27 MAR 09:41"
    },
    {
      "title": "Wall Bay — Cosmetics",
      "userName": "Priya Sharma",
      "time": "09:22 AM",
      "status": "Approved",
      "approvedTime": "09:45 AM",
      "type": "done",
      "thumbCode": "HSP 27 MAR 09:22"
    },
    {
      "title": "Double Door",
      "userName": "Priya Sharma",
      "time": "09:05 AM",
      "status": "Retake",
      "warning": "Image blurry — retake required. Ensure door signage is fully visible.",
      "type": "warning",
      "thumbCode": "HSP 27 MAR 09:05"
    },
  ].obs;

  var pendingCaptureCount = 126.obs;
  var dueDate = "Mar 31".obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviewData();
  }

  Future<void> fetchReviewData() async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading(false);
  }

  void approveItem(int index) {
    reviewItems[index]['status'] = 'Approved';
    reviewItems[index]['type'] = 'done';
    reviewItems[index]['approvedTime'] = "Just now";
    approvedCount.value++;
    reviewItems.refresh();
  }

  void rejectItem(int index) {
    reviewItems[index]['status'] = 'Rejected';
    rejectedCount.value++;
    reviewItems.refresh();
  }
}
