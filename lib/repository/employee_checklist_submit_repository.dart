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
  final SharedPreferences _preferences;
  final ProgressController progressController = Get.find<ProgressController>();

  EmployeeSubmitChecklistRepository({
    required this.apiService,
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  Future<ApiResponse> postChecklistData(List<Map<String, dynamic>> data) async {
    progressController.show();
    try {
      final response = await apiService.postData(
        endpoint: "/Employee/AddQuestionAnswer",
        data: data,
      );
      return ApiResponse(
        message: response['message'] ?? 'Success',
        statusCode: response['statusCode'] ?? '200',
      );
    } catch (e) {
      handleError(e);
      rethrow;
    } finally {
      progressController.hide();
      Get.back(); // Optionally handle this in the controller instead
    }
  }

  Future<Map<String, dynamic>> getChecklistData() async {
    try {
      return await apiService.getData(endpoint: 'checklist');
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  Future<bool> questionCancel({
    required int checklistAssignId,
    required int checklistMstItemId,
  }) async {
    progressController.show();
    try {
      final empCode = _preferences.getString("userCode");
      final sendJson = {
        "checklist_assign_id": checklistAssignId,
        "checklist_mst_item_id": checklistMstItemId,
        "employeeCode": empCode,
      };

      final response = await apiService.postData(
          endpoint: '/Employee/QuestionCancel', data: sendJson);

      if (response['statusCode'] == '200') {
        Get.snackbar('Success', 'Question cancelled successfully');
        return true;
      } else {
        showSimpleDialog(title: 'Alert!', msg: response['message']);
        return false;
      }
    } catch (e) {
      handleError(e);
      return false;
    } finally {
      progressController.hide();
    }
  }

  Future<String> submitAllDilo({
    required int checklistAssignId,
    required int checklistMstItemId,
  }) async {
    progressController.show();
    try {
      final empCode = _preferences.getString("userCode");
      final sendJson = {
        'emp_checklist_assign_id': checklistAssignId,
        'employee_code': empCode,
      };

      final response = await apiService.postData(
          endpoint: '/Employee/WorkFlowStatusEmp', data: sendJson);

      if (response['statusCode'] == '200') {
        showSimpleDialog(title: 'Success', msg: response['message']);
        return response['message'];
      } else {
        showSimpleDialog(title: 'Alert!', msg: response['message']);
        return response['message'];
      }
    } catch (e) {
      handleError(e);
      return 'Error';
    } finally {
      progressController.hide();
    }
  }

  void handleError(dynamic error) {
    print('Error: $error');
    Get.snackbar('Error', 'Something went wrong. Please try again.');
  }
}

