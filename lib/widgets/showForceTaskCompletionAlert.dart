import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/OutletSelectScreen.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';

import '../AttendenceScreen.dart';
import '../presentation/employee_qna.dart';
import '../presentation/home/operations/employees_leave_apply_page.dart';
import '../presentation/storeAudit/store_audit_qna.dart';


void showForceTaskCompletionAlert(tasks, {Function(dynamic)? onReturn})
 {

  Get.dialog(
    PopScope(
      canPop: false, // Prevents system pop gestures or back button
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // Optional: handle attempted pop if needed
      },      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            textAlign: TextAlign.center,
            'Pending Tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please complete these pending tasks:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...tasks.map((task) => _buildTaskItem(task,onReturn)).toList(),
          ],
        ),

      ),
    ),
    barrierDismissible: false,
  );
}

// Suppose this is your full list
final List<GetActvityTypes> allAudits = [
  GetActvityTypes(
    userId: "",
    auditId: "1",
    auditName: "DILO",
    description: "View and perform the tasks assigned to you",
    currentCount: 0,
    pendingCount: 0,
    apiUrl: "",
  ),
  GetActvityTypes(
    userId: "",
    auditId: "2",
    auditName: "Store Audit",
    description: "Audit for store operations and compliance",
    currentCount: 0,
    pendingCount: 0,
    apiUrl: "",
  ),
  GetActvityTypes(
    userId: "",
    auditId: "3",
    auditName: "LPD Audit",
    description: "Loss prevention and detection audit",
    currentCount: 0,
    pendingCount: 0,
    apiUrl: "",
  ),
  GetActvityTypes(
    userId: "",
    auditId: "4",
    auditName: "DILO Employee",
    description: "View and perform the tasks assigned to you",
    currentCount: 0,
    pendingCount: 0,
    apiUrl: "",
  ),
  GetActvityTypes(
    userId: "",
    auditId: "5",
    auditName: "AM Store Audit",
    description: "Area manager store-level audit",
    currentCount: 0,
    pendingCount: 0,
    apiUrl: "",
  ),
  GetActvityTypes(
    userId: "",
    auditId: "6",
    auditName: "Virtual Merch Page",
    description: "Virtual merchandising and display page audit",
    currentCount: 0,
    pendingCount: 0,
    apiUrl: "",
  ),
];

final List<GetActvityTypes> diloList =
allAudits.where((e) => e.auditId == "1").toList();

final List<GetActvityTypes> storeAuditList =
allAudits.where((e) => e.auditId == "2").toList();

final List<GetActvityTypes> lpdAuditList =
allAudits.where((e) => e.auditId == "3").toList();

final List<GetActvityTypes> diloEmployeeList =
allAudits.where((e) => e.auditId == "4").toList();

final List<GetActvityTypes> amStoreAuditList =
allAudits.where((e) => e.auditId == "5").toList();

final List<GetActvityTypes> virtualMerchPageList =
allAudits.where((e) => e.auditId == "6").toList();


Widget _buildTaskItem(Map<String, dynamic> task,Function? onReturn) {
  // Determine color based on priority
  Color priorityColor;
  switch (task['priority']) {
    case 5:
      priorityColor = Colors.red[400]!;
      break;
    case 4:
      priorityColor = Colors.orange[400]!;
      break;
    case 3:
      priorityColor = Colors.yellow[700]!;
      break;
    default:
      priorityColor = Colors.blue[400]!;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ],
    ),
    child: ListTile(
      leading: Container(
        height: 6,
        width: 6,
        decoration: BoxDecoration(
          color: priorityColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Text(
        task['title'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: () {
        // Navigate to respective screen
        if (task['targetScreen'] != null) {
          if (task['targetScreen'] == 'storeAudit') {
            Get.back();

            Get.to(() => OutletSelectionScreen( storeAuditList[0]))?.then((_) {
              print("Back from Store Audit to MainScreen");
              onReturn?.call(); // ✅ trigger MainScreen method
            });

            //
          } else if (task['targetScreen'] == 'employee') {///employeeDilo
            Get.back();

            Get.to( OutletSelectionScreen(diloList[0]))?.then((_) {
              print("Back from Store Audit to MainScreen");
              onReturn?.call(); // ✅ trigger MainScreen method
            });

          }else if (task['targetScreen'] == 'employeeDILO') {///employeeDilo
            Get.back();

            Get.to( OutletSelectionScreen(diloEmployeeList[0]))?.then((_) {
              print("Back from Store Audit to MainScreen");
              onReturn?.call(); // ✅ trigger MainScreen method
            });

          } else if (task['targetScreen'] == 'attendance') {
            Get.back();

            Get.to(const AttendenceScreen())?.then((_) {
              print("Back from Store Audit to MainScreen");
              onReturn?.call(); // ✅ trigger MainScreen method
            });
          } else if (task['targetScreen'] == 'leaveForm') {
            Get.back();

            Get.to(const EmployeeListScreen(formattedAuditName: 'Record Attendance',))?.then((_) {
              print("Back from Store Audit to MainScreen");
              onReturn?.call(); // ✅ trigger MainScreen method

            });
            //EmployeeListScreen
          }
          else if (task['targetScreen'] == 'checkIn') {
            Get.back(result: 'checkIn');
            //EmployeeListScreen
          }
        }
        // Get.toNamed('/${task['targetScreen']}');
      },
    ),
  );
}
