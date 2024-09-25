import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPopup extends StatelessWidget {
  final void Function(PermissionStatus status) onPermissionGranted;
  final void Function(PermissionStatus status) onPermissionDenied;

  const PermissionPopup({
    Key? key,
    required this.onPermissionGranted,
    required this.onPermissionDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Access Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please provide the following permissions for more personalised experience.',overflow: TextOverflow.ellipsis,maxLines: 3,),
          ListTile(
            leading: const Icon(Icons.location_pin),
            title: const Text('Allow Location Access'),
            subtitle: const Text('For doing CheckIn/CheckOut process at Location we need Location permission enabled',overflow: TextOverflow.ellipsis,maxLines: 3),
            onTap: () async {
              await Permission.location.request();
              onPermissionGranted(PermissionStatus.granted);

            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Allow Camera Access'),
            subtitle: const Text('TO CheckIn/CheckOut we need camera access to take photo',overflow: TextOverflow.ellipsis,maxLines: 3),
            onTap: () async {
              await Permission.camera.request();
              onPermissionGranted(PermissionStatus.granted);

            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),

            title: const Text('Allow Notifications'),
            subtitle: const Text('Get notified about the latest offers, schemes & new arrivals.',overflow: TextOverflow.ellipsis,maxLines: 3),
            onTap: () async {
              await Permission.notification.request();
              onPermissionGranted(PermissionStatus.granted);

            },
          ),
        ],
      ),
      actions: [

        TextButton(
          onPressed: () async {
            // await Permission.location.request();
            // await Permission.notification.request();
            // await Permission.camera.request();
            PermissionStatus locationPermission = await Permission.location.status;
            PermissionStatus cameraPermission = await Permission.camera.status;

            // PermissionStatus permissionStatus = PermissionStatus.granted;

            if(locationPermission.isGranted&&cameraPermission.isGranted){
              onPermissionGranted(PermissionStatus.granted);
            }
            else{
              onPermissionDenied(PermissionStatus.denied);
            }
            Navigator.pop(context);
          },
          child: const Text('Proceed'),
        ),
      ],
    );
  }
}
