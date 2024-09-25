import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/data/Attendence.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'common/constants.dart';

class AttendanceController extends GetxController {
  TextEditingController searchController = TextEditingController();

  @override
  void onReady() {
    // initialize the favorites list with some dummy data
    getAcitiveCheckListData();
    super.onReady();
  }

  @override
  void onInit() {
    super.onInit();
    getAcitiveCheckListData();
  }

  List<Attendance> checkList = [];
  var checkListGet = <Attendance>[].obs;

  var _locationCode;

  get locationCode => _locationCode;

  set locationCode(value) {
    _locationCode = value;
  }

  Stream<List<Attendance>> getAcitiveCheckListData() async* {
    final prefs = await SharedPreferences.getInstance();
    locationCode = prefs.getString('locationCode') ?? '106';
    var userID = prefs.getString('userCode') ?? '';
    String url =
        "${Constants.apiHttpsUrl}/Attendance/GetEmployeeAttendanceStatus/$userID";

    print(url);
    final response = await http.get(Uri.parse(url));
    checkList = [];
    Iterable l = json.decode(response.body);
    checkList =
        List<Attendance>.from(l.map((model) => Attendance.fromJson(model)));
    update();

    checkListGet.addAll(checkList);

    yield checkListGet;
    update();
  }
}

