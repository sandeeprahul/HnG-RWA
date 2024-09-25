import 'package:flutter/material.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status;
  }

  static void showPermissionAlert(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(message), // Use the dynamic message here
          actions: <Widget>[
            CustomElevatedButton(text: 'Ok', onPressed: (){
              Navigator.of(context).pop();
              openAppSettings();
            }),

          ],
        );
      },
    );
  }
}
