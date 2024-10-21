import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';

import '../api_service.dart';

class EmployeeSubmitChecklistRepository {
  final ApiService apiService;

  EmployeeSubmitChecklistRepository({required this.apiService});

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
        endpoint: 'checklist',  // Example endpoint for getting checklist data
      );
      return response;
    } catch (e) {
      print('Error fetching checklist: $e');
      throw e;
    }
  }
}
