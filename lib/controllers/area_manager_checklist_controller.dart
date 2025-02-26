import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class AreaManagerChecklistController extends GetxController {
  var isLoading = true.obs;
  var checklistData = {}.obs;
  var sections = [].obs;

  @override
  void onInit() {
    fetchChecklist();
    super.onInit();
  }

  Future<void> fetchChecklist() async {
    try {
      isLoading(true);
      var url = Uri.parse(
          // 'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/AreaManager/CreateareamanagerChecklist?locationcode=777&createdby=70003&checklistid=106'
          'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/AreaManager/CreateareamanagerChecklist?locationcode=777&createdby=70003&checklistid=200'
      );
      var response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        // var data = json.decode(response.body);
        // checklistData.value = data;
        // sections.value = data['section'];


        var data = json.decode(response.body);
        checklistData.value = data;
        sections.value = data['section'];

        // **Adding test section for testing**
        sections.add({
          "sectionId": "62",
          "sectionName": "Store Hygiene",
          "section_completion_status": null,
          "percentage": null
        });

      } else {
        Get.snackbar('Error', 'Failed to load checklist');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }
}