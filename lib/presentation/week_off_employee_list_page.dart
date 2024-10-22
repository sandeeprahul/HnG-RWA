import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/controllers/employee_weekoff_controller.dart';
import 'package:hng_flutter/repository/employee_leave_apply_repository.dart';

import '../api_service.dart';
import '../common/constants.dart';
import '../widgets/employee_details_list_widget.dart';

class WeekOffEmployeeListPage extends StatefulWidget {

  const WeekOffEmployeeListPage({super.key});

  @override
  State<WeekOffEmployeeListPage> createState() => _WeekOffEmployeeListPageState();
}

class _WeekOffEmployeeListPageState extends State<WeekOffEmployeeListPage> {
  final EmployeeLeaveApplyController controller = Get.put(EmployeeLeaveApplyController(
    repository: EmployeeLeaveApplyRepository(apiService: ApiService(baseUrl: Constants.apiHttpsUrl)),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          } else if (controller.employeeList.isNotEmpty) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  collapsedHeight: 200,
                  pinned: true,
                  backgroundColor: Colors.orange,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'weekoff',
                      child: Image.asset('assets/weekoff_icon.png', color: Colors.white),
                    ),
                    title: const Text('Week-Off apply'),
                    centerTitle: false,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final employee = controller.employeeList[index];
                      return EmployeeDetailsListWidget(employee, index + 1);
                    },
                    childCount: controller.employeeList.length,
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text("No employees found"),
            );
          }
        }),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Get.delete<EmployeeLeaveApplyController>(); // Disposes the controller manually
  }
}
