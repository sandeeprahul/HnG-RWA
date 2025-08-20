import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../widgets/showForceTaskCompletionAlert.dart';
import 'ScreenTracker.dart';

class AppResumeController extends GetxController with WidgetsBindingObserver {
  final screenTracker = Get.put(ScreenTracker());

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // When app resumes, navigate to home and clear stack
      // Get.offAllNamed('/home'); // Replace with your home route
      if (screenTracker.activeScreen.value == "HomeScreen") {///,LoginScreen
        await getPendingTasks();
      }else {
        return;
      }

    }
  }
  Future<void> getPendingTasks() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      var locationCode = prefs.getString('locationCode') ?? '106';
      var userID = prefs.getString('userCode') ?? '105060';

      String url = "${Constants.apiHttpsUrl}/forcetaskcompletion/Data/$locationCode/$userID";
      print(url);
      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var respo = jsonDecode(response.body);

        if (respo['status'] == true) {

          // _showTextAlert(context, respo['desctext']);
          showForceTaskCompletionAlert(respo['data'], onReturn: () {
            getPendingTasks(); // ✅ refresh
          });


        }
      }else{
        Get.snackbar('Alert!', 'Something went wrong\n${response.statusCode}',backgroundColor: Colors.red,colorText: Colors.white,borderRadius: 2);
      }
    } catch (e) {
      Get.snackbar('Alert!', 'Something went wrong\n${e.toString()}',backgroundColor: Colors.red,colorText: Colors.white,borderRadius: 2);

      // _showRetryAlert(Constants.networkIssue);
    }
  }

}