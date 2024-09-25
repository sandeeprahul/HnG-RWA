import 'package:firebase_storage/firebase_storage.dart';

class Employeedetail {
  Employeedetail({
    required this.employeeCode,
    required this.employeeName,
    required this.activeInd,
    required this.locationCode,
    required this.attendanceStatus,
    required this.check_in_selfie_url,
    required this.locationName,
    required this.checkintime,
    required this.checkouttime,
    required this.designation,
  });

  String employeeCode;
  String employeeName;
  String activeInd;
  String locationCode;
  String attendanceStatus;
  String check_in_selfie_url;
  String locationName;
  String checkintime;
  String checkouttime;
  String designation;

  factory Employeedetail.fromJson(Map<String, dynamic> json) => Employeedetail(
        employeeCode: json["employeeCode"],
        employeeName: json["employeeName"],
        activeInd: json["activeInd"]!,
        locationCode: json["locationCode"],
        attendanceStatus: json["attendanceStatus"]!,
        check_in_selfie_url: json["check_in_selfie_url"]!,
    locationName: json["locationName"]!,
    checkintime: json["checkintime"]!,
    checkouttime: json["checkouttime"]!,
    designation: json["designation"]!,
      );

  Map<String, dynamic> toJson() => {
        "employeeCode": employeeCode,
        "employeeName": employeeName,
        "activeInd": activeInd,
        "locationCode": locationCode,
        "attendanceStatus": attendanceStatus,
        "check_in_selfie_url": check_in_selfie_url,
        "locationName": locationName,
        "checkintime": checkintime,
        "checkouttime": checkouttime,
        "designation": designation,
      };

  Future<Employeedetail> getImageDataFromFirebase() async {
    final employeeDetails = Employeedetail(
        employeeCode: employeeCode,
        employeeName: employeeName,
        activeInd: activeInd,
        locationCode: locationCode,
        attendanceStatus: attendanceStatus,
        check_in_selfie_url: check_in_selfie_url,
      locationName: locationName,
      checkintime: checkintime,
      checkouttime: checkouttime,
      designation: designation,
    );

    final imageUrl = await FirebaseStorage.instance
        .ref()
        .child("$locationCode/QuesAns/${employeeDetails.check_in_selfie_url}")
        .getDownloadURL();

    /* final pojo = Pojo(
      "employee_code",
      "employee_name",
      "active_ind",
      "location_code",
      "attendance_status",
      imageUrl,
    );*/
    employeeDetails.check_in_selfie_url = imageUrl;

    return employeeDetails;
  }
}