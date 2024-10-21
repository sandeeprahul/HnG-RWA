import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSimpleDialog({required String title , required String msg}) {
  Get.dialog(
    AlertDialog(
      title:  Text(title),
      content:  Text(msg),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: const Text('Ok'),
        ),

      ],
    ),
  );
}
