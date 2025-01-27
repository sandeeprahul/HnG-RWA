import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hng_flutter/widgets/camera_preview_widget.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;


import '../../data/myStaffMovementData.dart';
import '../../data/staffMovementReasonData.dart';

class StaffMovementPage extends ConsumerStatefulWidget {
  const StaffMovementPage({super.key});

  @override
  ConsumerState<StaffMovementPage> createState() => _StaffMovementPageState();
}

class _StaffMovementPageState extends ConsumerState<StaffMovementPage> {
  String employeeId = "";
  String employeeName = "";
  String selectedReasonDescription = "";
  int selectedReasonID = -1;
  String turnaroundTime = "";
  TextEditingController remarksController = TextEditingController();
  TextEditingController empController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  String remarks = "";
  late Future<List<StaffMovementReasonData>> reasonsFuture;
  late Future<List<MyStaffMovementData>> myMovement;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    myMovement = getMyMovementStatus();
    reasonsFuture = fetchReasons();
    getUserDetails();
  }

  Future<List<StaffMovementReasonData>> fetchReasons() async {
    final response = await http.get(Uri.parse(
        'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/GetStaffmovementreason'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<StaffMovementReasonData>.from(data
          .map((reasonData) => StaffMovementReasonData.fromJson(reasonData)));
    } else {
      throw Exception('Failed to load data ${response.statusCode}');
    }
  }

  Future<List<MyStaffMovementData>> getMyMovementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("userCode");

    final response = await http.get(Uri.parse(
        'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/Staff_In_Out_Detail/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<MyStaffMovementData>.from(
          data.map((reasonData) => MyStaffMovementData.fromJson(reasonData)));
    } else {
      throw Exception('Failed to load data ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Movement Reasons'),
      ),
      body: FutureBuilder<List<StaffMovementReasonData>>(
        future: reasonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Error state with a retry alert
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load data'),
                ElevatedButton(
                  onPressed: () {
                    // Retry fetching data
                    setState(() {
                      reasonsFuture = fetchReasons();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            );
          } else {
            // Data loaded successfully
            final reasons = snapshot.data!;
            return
              _isSubmitting? Visibility(
              // visible: true,
                visible: _isSubmitting,
                child: Container(
                  color: const Color(0x80000000),
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.all(20),
                          height: 115,
                          width: 150,
                          child: const Column(
                            children: [
                              CircularProgressIndicator(),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Please wait..'),
                              )
                            ],
                          ))),
                )):
              SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [

                      Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          TextField(
                            controller: empController,
                          /*  onSaved: (value) {
                              employeeId = value!;
                            },*/
                            decoration: const InputDecoration(
                              labelText: "Employee ID",
                              border: OutlineInputBorder(),
                            ),
                          /*  validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Employee ID';
                              }
                              return null;
                            },*/
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextField(
                            controller: nameController,
                            // onSaved: (value) {
                            //   employeeName = value!;
                            // },

                            enabled: false,
                            decoration:  InputDecoration(
                              labelText: userName,
                              border: const OutlineInputBorder(),
                              hintText: userName
                            ),
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter Employee Name';
                            //   }
                            //   return null;
                            // },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text(
                            "Select Reason For Movement:",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: reasons
                                .map(
                                  (reason) => RadioListTile<String>(
                                    title: Text(reason.reasonDescription),
                                    value: reason.reasonDescription,
                                    groupValue: selectedReasonDescription,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedReasonDescription = value!;
                                        selectedReasonID = reason.reasonCode;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextField(
                            controller: timeController,
                            // onSaved: (value) {
                            //   turnaroundTime = value!;
                            // },
                            decoration: const InputDecoration(
                              labelText: "Turnaround Time in minutes",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter Turnaround Time';
                            //   }
                            //   return null;
                            // },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextField(
                            controller: remarksController,
                            // onSaved: (value) {
                            //   remarks = value!;
                            // },
                            decoration: const InputDecoration(
                              labelText: "Remarks",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: (){
                              if(!_isSubmitting){
                                if(empController.text.toString().isEmpty){
                                  _showAlert("Please enter EmployeeId");
                                }else if(selectedReasonID==-1){
                                  _showAlert("Please select Reason");
                                }
                                else if(timeController.text.toString().isEmpty){
                                  _showAlert("Please enter TurnAround time");
                                }
                              else  if(remarksController.text.toString().isEmpty){
                                  _showAlert("Please enter Remarks");
                                }else{
                                  submitData();
                                }
                              }
                               // ? null : submitData,

                            }
                            // Prevent multiple submissions

                            /* onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                // Now you can use the form values
                                // Perform your submission logic here

                                postMovementReason();
                              }
                            },*/
                            ,child: _isSubmitting
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ) // Show progress indicator while submitting
                                : const Text('Submit'),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> submitData() async {
    try {
    setState(() {
      _isSubmitting = true;
    });
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final prefs = await SharedPreferences.getInstance();

    String? locationCode = prefs.getString('locationCode');
    DateTime now = DateTime.now();
    // Validate the form


    final Map<String, dynamic> postData = {
      "employeeCode": int.parse(empController.text.toString()),
      "staff_trans_date": "${now.year}-${now.month}-${now.day}",
      "reason_movement_id": selectedReasonID,
      "expert_trun_around_time": int.parse(timeController.text.toString()),
      "remarks": remarksController.text.toString(),
      "latitude": "${position.latitude}",
      "longitude": "${position.longitude}",
      "locationCode": 200
    };
   /*  var postData = {
      "employeeCode": int.parse(empController.text.toString()),
      "expert_trun_around_time": int.parse(timeController.text.toString()),
      "remarks": remarksController.text.toString(),
      "staff_trans_date": "${now.year}-${now.month}-${now.day}",
      "reason_movement_id": selectedReasonID,
      "latitude": position.latitude,
      "longitude": position.longitude,
      "locationCode": int.parse(locationCode!),
    };*/

    print(postData.toString());


    /*  var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        'RWA_GROOMING_API/api/StaffMovement/StaffPost',
      );*/
      final url =
      Uri.parse('https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/StaffPost');


      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(postData),
      );

/*
      final response = await http.post(
        Uri.parse(
            'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/StaffPost'),
        body: jsonEncode(postData),
        headers: {
          'Content-Type': 'application/json',
        },
      );*/

      if (response.statusCode == 200) {
        // Successful submission
        // Handle the response, if needed
        print("Data submitted successfully");
        Get.snackbar(
          "Success", // SnackBar title
          "Data submitted successfully",
          snackPosition: SnackPosition.TOP, // You can customize the SnackBar's position
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3), // Duration for how long the SnackBar is displayed
        );
        Navigator.pop(context);

      } else {
        // Handle errors, e.g., show an error message to the user
        print("Failed to submit data, status code: ${response.statusCode}");
        _showAlertWithMSG(
            'Failed to submit data\nStatusCode:${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print("Error during data submission: $e");
      _showAlertWithMSG('${Constants.networkIssue}\nPlease Retry.');
    } finally {
      // Hide progress indicator
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  bool _isSubmitting = false; // Tracks if the data is being submitted
  // bool _isSubmitting = false; // Tracks if the data is being submitted
  Future<void> _showAlertWithMSG(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(msg),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Retry',
                onPressed: () {
                  Navigator.pop(context);
                  submitData();
                }),
          ],
        );
      },
    );
  }
  Future<void> _showAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(msg),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Ok',
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

  String userCode= '';
  String userName= '';
  Future<void> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();


    var user = prefs.getString('userType');
    userCode = prefs.getString('userCode')!;
    userName = prefs.getString('user_name')!;
    setState(() {
      userCode = userCode;
      userName = userName;
    });
  }
}
