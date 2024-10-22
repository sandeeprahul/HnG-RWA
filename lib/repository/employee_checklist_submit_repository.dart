import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../controllers/progressController.dart';
import '../helper/progressDialog.dart';

class EmployeeSubmitChecklistRepository {
  final ApiService apiService;
  // final ProgressController _controller;

  EmployeeSubmitChecklistRepository(
      {required this.apiService});

  // Post checklist data using ApiService
  Future<void> postChecklistData(List<Map<String, dynamic>> data) async {
    try {
      final response = await apiService.postData(
        endpoint: "/Employee/AddQuestionAnswer",
        data: data,
      );
      Get.back(); // Close the progress dialog

      print('Checklist posted successfully: $response');
    } catch (e) {
      Get.back(); // Close the progress dialog

      print('Error posting checklist: $e');
      rethrow;
    }
  }

  // Fetch checklist data
  Future<Map<String, dynamic>> getChecklistData() async {
    try {
      final response = await apiService.getData(
        endpoint: 'checklist', // Example endpoint for getting checklist data
      );
      return response;
    } catch (e) {
      print('Error fetching checklist: $e');
      throw e;
    }
  }

  //question cancel
  Future<bool> questionCancel({
    required int checklistAssignId,
    required int checklistMstItemId,
  }) async {
    bool goBack = false;

    try {
      final pref = await SharedPreferences.getInstance();
      var empCode = pref.getString("userCode");

      var sendJson = {
        "checklist_assign_id": checklistAssignId,
        "checklist_mst_item_id": checklistMstItemId,
        "employeeCode": empCode,
      };

      print('Sending JSON: $sendJson');

      // Use ApiService to send the request
      final response = await apiService.postData(
          endpoint: '/Employee/QuestionCancel', data: sendJson);
      print('Response: $response');

      if (response['statusCode'] == '200') {
        goBack = true;
        Get.snackbar('Success', 'Question cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black,
            colorText: Colors.white);
      } else {
        showSimpleDialog(
            title: 'Alert!',
            msg:
                'Something went wrong\n${response['statusCode']}\nPlease contact IT support.');
      }
    } catch (e) {
      print(e);
    }

    return goBack;
  }

  Future<String> submitAllDilo({
    required int checklistAssignId,
    required int checklistMstItemId,
  }) async {
    // _controller.showProgress();

    try {
      final pref = await SharedPreferences.getInstance();
      var empCode = pref.getString("userCode");

      var sendJson = {
        'emp_checklist_assign_id': checklistAssignId,
        'employee_code': empCode,
      };

      print('Sending JSON: $sendJson');

      // Use ApiService to send the request
      final response = await apiService.postData(
          endpoint: '/Employee/WorkFlowStatusEmp', data: sendJson);
      print('Response: $response');

      if (response['statusCode'] == '200') {
        Get.snackbar('Success', response['message'],
            snackPosition: SnackPosition.BOTTOM);
      } else {
        showSimpleDialog(title: 'Alert!', msg: response['message']);
      }
      return response['message'];
    } catch (e) {
      print(e);
      return '';
    }
  }
}
