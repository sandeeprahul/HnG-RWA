import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSimpleDialog({required String title , required String msg}) {
  Get.dialog(
    AlertDialog(
      title:  Text(title),
      content:  Text(msg),
      actions: [
        Container(
          decoration:
          BoxDecoration(color: CupertinoColors.activeBlue,borderRadius: BorderRadius.circular(16)),
          child: InkWell(
              onTap: () {
                Get.back(); // Close the dialog
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                child: Text('OK',
                    style: TextStyle(color: Colors.white)),
              )),
        ),


      ],
    ),
  );
}
