import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryController extends GetxController {
  var isLoading = false.obs; // Observable loading state
  var isOtpSent = false.obs; // Tracks if OTP is sent
  var otpFromServer = ''.obs; // Stores OTP received from API
  var otpVerified = false.obs;




  Future<void> sendOtp(String mobile, String name, String orderId) async {
    const String otpApiUrl =
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/DeliveryConfSendOTP"; // Replace with actual API

    Map<String, dynamic> requestBody = {
      "order_id": orderId,
      "Delivered_To_Person_Name": name,
      "Delivered_To_Mobile_No": mobile
    };

    print("sendOtp: $requestBody ");
    try {
      isLoading.value = true; // Show loading
      final response = await http.post(
        Uri.parse(otpApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      isLoading.value = false; // Hide loading

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("sendOtp Response: $responseData");
        if (responseData["status"] == "ok" ||
            responseData["message"] == "OTP sent successfully.") {
          otpFromServer.value =
              responseData["otp"].toString(); // Store OTP from API
          isOtpSent.value = true; // Enable OTP verification
          Get.snackbar("Success", "OTP sent successfully!",
              backgroundColor: Colors.green, colorText: Colors.white);
        }else{
          Get.snackbar("Success", responseData["message"] ,
              backgroundColor: Colors.green, colorText: Colors.white);
        }


      } else {
        Get.snackbar("Error", "Failed to send OTP.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Something went wrong: $e");
    }
  }

  Future<void> verifyOtp(String enteredOtp) async {
    if (enteredOtp == otpFromServer.value.toString()) {
      // Get.back(); // Close popup after success
      otpVerified.value = true;
      Get.snackbar("Success", "OTP verified successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
      // await Future.delayed(const Duration(milliseconds: 500));
    } else {
      otpVerified.value = false;

      Get.snackbar("Error", "Invalid OTP. Try again!",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> submitDeliveryDetails({
    required String name,
    required String mobile,
    required int minutes,
  }) async {
    const String apiUrl =
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/DeliveryCheckoutDetails"; // Replace with actual API URL

    Map<String, dynamic> requestBody = {
      "DeliveryExecutiveName": name,
      "DeliveryExecutiveMobileNo": mobile,
      "EstimatedMinsForDelivery": minutes,
    };

    try {
      isLoading.value = true; // Show progress dialog
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      isLoading.value = false; // Hide progress dialog

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["status"] == "ok") {
          Get.back();
          Get.snackbar("Success", responseData["message"],
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));
          // await Future.delayed(const Duration(milliseconds: 500));
          // Close delivery popup
        } else {
          Get.snackbar("Error", responseData["message"],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Failed", "Failed to submit. Please try again.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> submitDelivered({
    required String orderId,
    required String mobile,
    required String name,
  }) async {
    const String apiUrl =
        "https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/StoreOrder/UpdateDeliveryStatus"; // Replace with actual API URL

    print("submitDelivered: $apiUrl");

    Map<String, dynamic> requestBody = {
      // "order_id": "OID101",
      "order_id": orderId,
      "Delivered_To_Person_Name": name,
      "Delivered_To_Mobile_No": mobile
    };
    print("submitDelivered: $requestBody");

    try {
      isLoading.value = true; // Show progress dialog
      final response = await http.post(Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody));
      print("submitDelivered: ${response.body}");

      isLoading.value = false; // Hide progress dialog

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("submitDelivered: $responseData");

        print("submitDelivered: $responseData");
        if (responseData["status"] == "ok") {
          Get.back();
          Get.snackbar("Success", responseData["message"],
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));
          // await Future.delayed(const Duration(milliseconds: 500));
          // Close delivery popup
        } else {
          Get.snackbar("Error", responseData["message"],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        final responseData = jsonDecode(response.body);

        Get.snackbar("Failed", "${responseData['message']}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
