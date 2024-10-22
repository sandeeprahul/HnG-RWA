import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showConfirmDialog(
    {required VoidCallback onConfirmed,
    required String title,
    required String msg}) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    16), // Adjust the radius for rounded corners
              )),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
             // Close the dialog
            Get.back();
            onConfirmed(); // Execute the callback function

          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    16), // Adjust the radius for rounded corners
              )),
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.white,fontSize: 18),
          ),
        ),
      ],
    ),
  );
}
