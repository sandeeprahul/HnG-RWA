import 'package:flutter/material.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onGrantPermission;

  const LocationPermissionDialog({super.key, required this.onGrantPermission});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Permission'),
      content: const Text('Your app needs to  access your location for CheckIn and CheckOut.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onGrantPermission();
          },
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }
}
