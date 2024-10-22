import 'package:get/get.dart';
import 'package:hng_flutter/controllers/progressController.dart';
import 'package:hng_flutter/repository/employee_leave_apply_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/employee_leaveapply_list.dart';

class EmployeeLeaveApplyController extends GetxController {
  final EmployeeLeaveApplyRepository repository;
  final ProgressController progressController = ProgressController();

  var employeeList = <EmployeeLeaveAplylist>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  EmployeeLeaveApplyController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    fetchEmployeeList();
  }


  Future<void> fetchEmployeeList() async {
    try {
      isLoading.value = true;
      progressController.show();

      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';

      var employees = await repository.getEmployeeList(userID);

      if (employees.isNotEmpty) {
        employeeList.assignAll(employees);
      } else {
        errorMessage.value = "No employees found";
      }
    } catch (e) {
      errorMessage.value = "Error fetching employees: $e";
    } finally {
      isLoading.value = false;
      progressController.hide();
    }
  }



}
