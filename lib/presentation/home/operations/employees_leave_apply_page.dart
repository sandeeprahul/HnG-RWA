import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/helper/confirmDialog.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../data/opeartions/leave_apply_employees_entity.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
// @override
// ConsumerState<PageSurvey> createState() => _PageSurveyState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<LeaveType> leaveTypes = [];
  List<Employee> employees = [];

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
        title: const Text(
          "Record WeekOff",
        ),
      ),
      body:loading?const Center(child: CircularProgressIndicator()): Column(
        children: [
          // Dropdown for Leave Types
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
                  for (var employee in employees) employee.empCode: selectAll
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      "Date: ${employee.date}",
                                      style: TextStyle(color: Colors.grey[700]),
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
                                  selectedEmployees[employee.empCode] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedEmployees[employee.empCode] =
                                      value ?? false;
                                  selectAll = selectedEmployees.values
                                      .every((isSelected) => isSelected);
                                });
                              },
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
      loading  = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userCode = preferences.getString("userCode");
    String? locationCode = preferences.getString("locationCode");

    // Collect selected employees and prepare JSON output
    List<Map<String, String>> jsonOutput = employees
        .where((employee) => selectedEmployees[employee.empCode] == true)
        .map((employee) => {
      "empCode": employee.empCode,
      "date": employee.date,
      "leaveType": selectedLeaveType!.leaveType,
      "locationCode": locationCode ?? '',
      "updatedby": userCode ?? '',
    })
        .toList();

    // Convert the JSON output to a string
    final String jsonBody = json.encode(jsonOutput);

    // Define the endpoint URL
    const String url = "https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/Login/attendanceupdate";

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
          loading  = false;
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
            loading  = false;
          });
          showSimpleDialog(title: 'Error', msg: responseData["message"]);

          // Handle error case if statusCode is not 200
        }
        // Handle success, parse response if necessary
      } else {
        setState(() {
          loading  = false;
        });
        print("Failed to submit leaves. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        showSimpleDialog(title: 'Error', msg: 'Failed to submit leaves. Status code: ${response.statusCode}');

      }
    } catch (e) {
      setState(() {
        loading  = false;
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
    final String url = "https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/Login/GetLeaveTypesAndEmployess/$userCode";  // Replace with your actual URL
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
        showSimpleDialog(title: 'Error!', msg: 'Failed to load data. Status code: ${response.statusCode}');

        throw Exception("Failed to load data. Status code: ${response.statusCode}");
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

}