import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class SectionDetailsController extends GetxController {
  var isLoading = true.obs;
  var questions = [].obs;
  var totalQuestions = 0.obs;
  var completedQuestions = 0.obs;
  var checklistStatus = ''.obs;

  Future<void> fetchSectionDetails(String checklistId, String sectionId, String createdBy) async {
    try {
      isLoading(true);
      var url = Uri.parse('https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/AreaManager/HeaderQuestion/$checklistId/$sectionId/$createdBy');
     print(url);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        checklistStatus.value = data['checklist_Current_Stats'];
        totalQuestions.value = int.parse(data['checklist_Question_header_Total_Count']);
        completedQuestions.value = int.parse(data['checklist_Question_header_Completed_Count']);
        questions.value = data['checklist_Question_Header'];

      } else {
        Get.snackbar('Error', 'Failed to load section details');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }
}