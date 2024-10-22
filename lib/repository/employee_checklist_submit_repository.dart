import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../controllers/progressController.dart';
import '../helper/apiResponse.dart';
import '../helper/progressDialog.dart';

class EmployeeSubmitChecklistRepository {
  final ApiService apiService;
  // final ProgressController _controller;
  final ProgressController progressController = Get.find<ProgressController>();

  EmployeeSubmitChecklistRepository(
      {required this.apiService});

  // Post checklist data using ApiService
  Future<ApiResponse> postChecklistData(List<Map<String, dynamic>> data) async {

    try {
      progressController.show();

      final response = await apiService.postData(
        endpoint: "/Employee/AddQuestionAnswer",
        data: data,
      );
      progressController.hide();

      Get.back(); // Close the progress dialog
      final message = response['message'] ?? 'Success';
      final statusCode = response['statusCode'] ?? "200"; // Defaulting to 200 if not present

      print('Checklist posted successfully: $response');
      return ApiResponse(message: message, statusCode: statusCode);

    } catch (e) {
      progressController.hide();

      Get.back(); // Close the progress dialog

      print('Error posting checklist: $e');
      throw Exception("Failed to post checklist: $e");
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
      progressController.hide();

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
      progressController.hide();

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
      progressController.hide();

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
      progressController.hide();

      final pref = await SharedPreferences.getInstance();
      var empCode = pref.getString("userCode");

      var sendJson = {
        'emp_checklist_assign_id': checklistAssignId,
        'employee_code': empCode,
      };

      print('Sending JSON: $sendJson');
      progressController.hide();

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
      progressController.hide();
      print(e);
      return '';
    }
  }
}
