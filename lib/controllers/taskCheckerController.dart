import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TaskCheckerController extends GetxController {
  var isLoading = false.obs; // Reactive loading state

  void checkTaskStatus() async {
    try {
      isLoading.value = true; // Show loading indicator
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var userCode = sharedPreferences.getString("userCode");
      // Make the GET request
      final response = await http.get(Uri.parse('https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/Login/Checkattendance/$userCode'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);

        final pendingStatus = data['pendingStatus'] == "true";
        final taskName = data['taskName'] ?? '';
        final taskPage = data['taskPage'] ?? '';

        if (pendingStatus) {
          // Show GetX alert
          Get.defaultDialog(
            title: "Pending Task",
            content: Text("Task: $taskName"),
            confirm: ElevatedButton(
              onPressed: () {
                // Navigate to the taskPage
                Get.back();

                // Get.toNamed(taskPage);
              },
              child: const Text("Continue",style: TextStyle(color: Colors.white),),
            ),
          );
        } else {
          // Optional: Handle no pending task
          // Get.snackbar("Status", "No pending tasks.",backgroundColor: Colors.black,snackPosition: SnackPosition.BOTTOM,colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Failed to fetch data: ${response.reasonPhrase}",backgroundColor: Colors.black,snackPosition: SnackPosition.BOTTOM,colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e",backgroundColor: Colors.black,snackPosition: SnackPosition.BOTTOM,colorText: Colors.white);
    }
    finally {
      isLoading.value = false; // Hide loading indicator
    }
  }
}