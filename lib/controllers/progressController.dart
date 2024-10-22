import 'package:get/get.dart';

import '../helper/progressDialog.dart';

class ProgressController extends GetxController {
  void showProgress() {
    showProgressCustom();
  }

  void hideProgress() {
    Get.back(); // This will close the dialog
  }
}
