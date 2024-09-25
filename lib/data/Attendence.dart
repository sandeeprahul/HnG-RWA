// To parse this JSON data, do
//
//     final attendence = attendenceFromJson(jsonString);

import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'employee_details_entity.dart';

class Attendance {
  String reportingManageruserId;
  String totalcnt;
  String presentcnt;
  String absentcnt;
  String weekoffcnt;
  String leavecnt;

  List<Employeedetail> employeedetails;


  Attendance(
      {required this.reportingManageruserId,
      required this.employeedetails,
      required this.totalcnt,
      required this.presentcnt,
      required this.absentcnt,
      required this.leavecnt,
      required this.weekoffcnt}) {
  }



  Future<void> getImageDataFromFirebase() async {
    print('getImageDataFromFirebase');
    try {
      for (var employee in employeedetails) {
        final imageUrl = await FirebaseStorage.instanceFor(
                bucket: "gs://hng-offline-marketing.appspot.com")
            .ref()
            .child(
                "${employee.locationCode}/attendance/${employee.check_in_selfie_url}")
            .getDownloadURL();
        employee.check_in_selfie_url = imageUrl;
        if (kDebugMode) {
          print("FIREBASE IMAGE URL");
          print(imageUrl);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(


        reportingManageruserId: json["reportingManageruserId"],
        totalcnt: json["totalcnt"],
        presentcnt: json["presentcnt"],
        absentcnt: json["absentcnt"],
        weekoffcnt: json["weekoffcnt"],
        leavecnt: json["leavecnt"],

        employeedetails: List<Employeedetail>.from(
            json["employeedetails"].map((x) => Employeedetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reportingManageruserId": reportingManageruserId,
        "employeedetails":
            List<dynamic>.from(employeedetails.map((x) => x.toJson())),
      };
}

//data
/*[
  {
    "reportingManageruserId": "2009459",
    "totalcnt": "1",
    "presentcnt": "1",
    "absentcnt": "0",
    "weekoffcnt": "0",
    "leavecnt": "0",
    "employeedetails": [
      {
        "employeeCode": "1012594",
        "employeeName": "N GANESH KUMAR",
        "activeInd": "Y",
        "locationCode": "103",
        "attendanceStatus": "Checked In",
        "check_in_selfie_url": "EMP101259420230713105044937.jpg"
      }
    ]
  }
]*/

