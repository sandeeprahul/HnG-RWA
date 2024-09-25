import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/data/myStaffMovementData.dart';
import 'package:hng_flutter/data/my_staff_movement_history_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../common/constants.dart';
import 'custom_elevated_button.dart';

class StaffMovementHistoryCard extends StatefulWidget {
  final MyStaffMovementHistoryEntity staffData;

  StaffMovementHistoryCard({required this.staffData});

  @override
  State<StaffMovementHistoryCard> createState() => _StaffMovementHistoryCardState();
}

class _StaffMovementHistoryCardState extends State<StaffMovementHistoryCard> {
  TextEditingController remarksEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _isSubmitting?const Center(
      child:CircularProgressIndicator(),
    ):Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    '${widget.staffData.expectedAroundTime}min',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '${widget.staffData.employeeName}(${widget.staffData.employeecode})'),
                      const SizedBox(height: 4,),
                      Text(widget.staffData.reasonMovement
                      ),
                      const SizedBox(height: 4,),

                      Text('Remarks: ${widget.staffData.remarks}'),
                      const SizedBox(height: 8,),


                      // Text(),
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              visible: widget.staffData.staffoutTiming.isEmpty?false:true,
              child: TextFormField(
                controller: remarksEditingController,
              enabled:widget.staffData.staffoutTiming.isEmpty?false:true,
                decoration:  InputDecoration(
                  labelText: "Remarks",
                  hintText: widget.staffData.remarks,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Visibility(
              visible: widget.staffData.staffoutTiming.isEmpty?false:true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () {
                      // Handle accept action here
                      submitData(1,widget.staffData.transId);

                    },
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('In Store'),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.staffData.staffoutTiming.isEmpty?true:false,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () {
                      // Handle accept action here
                      submitData(1,widget.staffData.transId);

                    },
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('Leave Store'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _isSubmitting = false;
  Future<void> submitData(int isApprove,int transId) async {
    setState(() {
      _isSubmitting = true;
    });


    // Validate the form
    final prefs = await SharedPreferences.getInstance();

    String? userCode = prefs.getString("userCode");
    final Map<String, dynamic> postData = {
      "transId": transId,
    };

    print(postData.toString());

    try {
      /*  var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        'RWASTAFFMOVEMENT_TEST/api/StaffMovement/StaffPost',
      );*/
      final url =
      Uri.parse('https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/StaffMovement/StaffInStore');


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
            'https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/StaffMovement/StaffPost'),
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
        // Navigator.pop(context);
      } else {
        // Handle errors, e.g., show an error message to the user
        print("Failed to submit data, status code: ${response.statusCode}");
        _showAlertWithMSG(
            'Failed to submit data\nStatusCode:${response.statusCode}',isApprove,transId);
      }
    } catch (e) {
      // Handle network errors
      print("Error during data submission: $e");
      _showAlertWithMSG('${Constants.networkIssue}\nPlease Retry.',isApprove,transId);
    } finally {
      // Hide progress indicator
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  Future<void> submitDataStoreIN(int isApprove,int transId) async {
    setState(() {
      _isSubmitting = true;
    });


    // Validate the form
    final prefs = await SharedPreferences.getInstance();

    String? userCode = prefs.getString("userCode");
    final Map<String, dynamic> postData = {
      "transId": transId,
    };

    print(postData.toString());

    try {
      /*  var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        'RWASTAFFMOVEMENT_TEST/api/StaffMovement/StaffPost',
      );*/
      final url =
      Uri.parse('https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/StaffMovement/StaffInStore');


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
            'https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/StaffMovement/StaffPost'),
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
        // Navigator.pop(context);
      } else {
        // Handle errors, e.g., show an error message to the user
        print("Failed to submit data, status code: ${response.statusCode}");
        _showAlertWithMSG(
            'Failed to submit data\nStatusCode:${response.statusCode}',isApprove,transId);
      }
    } catch (e) {
      // Handle network errors
      print("Error during data submission: $e");
      _showAlertWithMSG('${Constants.networkIssue}\nPlease Retry.',isApprove,transId);
    } finally {
      // Hide progress indicator
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _showAlertWithMSG(String msg, int isApprove, int transId) async {
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
                  submitData(isApprove,transId);
                }),
          ],
        );
      },
    );
  }


}
