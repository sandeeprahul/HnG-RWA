import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showProgressCustom(){
  // Show progress dialog
  Get.dialog(
    const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20), // Add some spacing
          Text('Please wait...', style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
    barrierDismissible: false,
  );

}