import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/helper/confirmDialog.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../data/opeartions/leave_apply_employees_entity.dart';

class EmployeeListScreen extends StatefulWidget {
  final String formattedAuditName;

  const EmployeeListScreen({super.key, required this.formattedAuditName});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
// @override
// ConsumerState<PageSurvey> createState() => _PageSurveyState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<LeaveType> leaveTypes = [];
  List<Employee> employees = [];
  List<Description> descriptionList = [];

  Map<String, bool> selectedEmployees = {};
  bool selectAll = false;
  bool loading = false;
  LeaveType? selectedLeaveType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          widget.formattedAuditName,
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dropdown for Leave Types
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16,right: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Message: ',
                          style: TextStyle(

                            fontSize: 18,
                              decoration: TextDecoration.underline
                            /*  decoration: TextDecoration.underline,    decorationColor: Colors.grey,*/ // Set the underline color here
                          ),
                        ),
                      ),Expanded(
                        flex: 2,
                        child: Text(
                          descriptionList[0].message,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: const TextStyle(

                            fontSize: 18,
                            color: Colors.red
                            /*  decoration: TextDecoration.underline,    decorationColor: Colors.grey,*/ // Set the underline color here
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: DropdownButtonFormField<LeaveType>(
                    decoration: const InputDecoration(
                      labelText: "Select Leave Type",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedLeaveType,
                    items: leaveTypes.map((LeaveType leaveType) {
                      return DropdownMenuItem<LeaveType>(
                        value: leaveType,
                        child: Text(leaveType.leaveType),
                      );
                    }).toList(),
                    onChanged: (LeaveType? newValue) {
                      setState(() {
                        selectedLeaveType = newValue;
                        // TODO: Filter or update employee list based on leave type
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                // Select All Checkbox
                CheckboxListTile(
                  title: const Text("Select All"),
                  value: selectAll,
                  onChanged: (bool? value) {
                    setState(() {
                      selectAll = value ?? false;
                      selectedEmployees = {
                        for (var employee in employees)
                          if (employee.status.isEmpty)
                            employee.empCode: selectAll
                      };
                    });
                  },
                ),
                // Employee List
                Expanded(
                  child: ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          // elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Stack(
                            children: [
                              // Main content with custom checkbox
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // const SizedBox(width: 8.0),

                                    // Employee Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            employee.empName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            employee.designation,
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            "Date: ${employee.date}",
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          Text(
                                            "Status: ${employee.status}",
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Custom Checkbox
                                  ],
                                ),
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 26),
                                  child: Checkbox(
                                    value:
                                        selectedEmployees[employee.empCode] ??
                                            false,
                                    onChanged: employee.status.isEmpty
                                        ? (bool? value) {
                                            setState(() {
                                              selectedEmployees[employee
                                                  .empCode] = value ?? false;

                                              selectAll = employees
                                                  .where((emp) =>
                                                      emp.status.isEmpty)
                                                  .every((emp) =>
                                                      selectedEmployees[
                                                          emp.empCode] ??
                                                      false);
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              // Positioned empCode on top right with rounded bottom edges
                              Positioned(
                                top: 1.0,
                                right: 0.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: const BorderRadius.only(
                                      // topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    employee.empCode,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                //Submit button
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedLeaveType == null
                        ? null
                        : () {
                            printData();

                            // Collect selected employees and print JSON
                            showConfirmDialog(
                                onConfirmed: () {
                                  submitLeaves();
                                },
                                title: 'Alert!',
                                msg: 'Confirm Submit?');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,

                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      // textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    child: const Text(
                      "SUBMIT",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> submitLeaves() async {
    setState(() {
      loading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userCode = preferences.getString("userCode");
    String? locationCode = preferences.getString("locationCode");

    // Collect all employees, including selected and unselected, and prepare JSON output
    List<Map<String, String>> jsonOutput = employees.map((employee) {
      bool isSelected = selectedEmployees[employee.empCode] == true;

      return {
        "empCode": employee.empCode,
        "date": employee.date,
        "leaveType":
            isSelected ? selectedLeaveType!.leaveType : employee.status,
        "locationCode": locationCode ?? '',
        "updatedby": userCode ?? '',
        // "isSelected": isSelected ? "true" : "false",  // Indicates if the employee was selected
      };
    }).toList();

    // Convert the JSON output to a string
    final String jsonBody = json.encode(jsonOutput);

    // Define the endpoint URL
    const String url =
        "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/attendanceupdate";

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonBody,
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        print("Leave submission successful!");
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData["statusCode"] == "200") {
          showSimpleDialog(title: 'Success', msg: responseData["message"]);
          Navigator.pop(context);
          print(responseData["message"]); // Output: "Updated Successfully"
          // Handle success (e.g., show a success message to the user)
        } else {
          setState(() {
            loading = false;
          });
          showSimpleDialog(title: 'Error', msg: responseData["message"]);

          // Handle error case if statusCode is not 200
        }
        // Handle success, parse response if necessary
      } else {
        setState(() {
          loading = false;
        });
        print("Failed to submit leaves. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        showSimpleDialog(
            title: 'Error',
            msg:
                'Failed to submit leaves. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error submitting leaves: $e");
      showSimpleDialog(title: 'Error', msg: 'Failed to submit leaves.  $e');
    }
  }

  Future<void> loadData() async {
    try {
      LeaveData leaveData = await fetchLeaveData();
      setState(() {
        leaveTypes = leaveData.leaveTypes;
        employees = leaveData.employees;
        descriptionList = leaveData.description;
      });
    } catch (e) {
      print("Error loading data: $e");
      // Handle error (e.g., show a message to the user)
    }
  }

// Fetch Leave Types and Employees from a single API
  Future<LeaveData> fetchLeaveData() async {
    setState(() {
      loading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userCode = preferences.getString("userCode");
    // var userCode = '70002';

    final String url =
        "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/GetLeaveTypesAndEmployess/$userCode"; // Replace with your actual URL
    print(url);
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        final Map<String, dynamic> data = json.decode(response.body);
        return LeaveData.fromJson(data);
      } else {
        setState(() {
          loading = false;
        });
        showSimpleDialog(
            title: 'Error!',
            msg: 'Failed to load data. Status code: ${response.statusCode}');

        throw Exception(
            "Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      showSimpleDialog(title: 'Error!', msg: 'Error fetching leave data: $e');
      print("Error fetching leave data: $e");
      throw e; // Rethrow to handle it in the calling code
    }
  }

  Future<void> printData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userCode = preferences.getString("userCode");
    String? locationCode = preferences.getString("locationCode");

    // Collect all employees, including selected and unselected, and prepare JSON output

    List<Map<String, String>> jsonOutput = employees.map((employee) {
      bool isSelected = selectedEmployees[employee.empCode] == true;

      return {
        "empCode": employee.empCode,
        "date": employee.date,
        "leaveType":
            isSelected ? selectedLeaveType!.leaveType : employee.status,
        "locationCode": locationCode ?? '',
        "updatedby": userCode ?? '',
        // "isSelected": isSelected ? "true" : "false",  // Indicates if the employee was selected
      };
    }).toList();

    // Convert the JSON output to a string
    // final String jsonBody = json.encode(result);
    // print(jsonBody);
    final String jsonBody2 = json.encode(jsonOutput);
    print("jsonBody2: $jsonBody2");
  }

  List<Map<String, dynamic>> prepareEmployeeData({
    required List<Employee> employeeList,
    required bool selectAll,
    required Map<String, bool> selectedEmployees,
    required String locationCode,
    required String updatedBy,
  }) {
    return employeeList
        .where((employee) =>
            selectAll || (selectedEmployees[employee.empCode] ?? false))
        .map((employee) {
      return {
        "empCode": employee.empCode ?? '',
        "date": employee.date ?? '',
        "leaveType": employee.status.isEmpty
            ? selectedEmployees['leaveType'] ?? ''
            : employee.status,
        "locationCode": locationCode,
        "updatedby": updatedBy,
      };
    }).toList();
  }
}
