
import 'package:flutter/material.dart';

import '../AttendenceScreen.dart';
import '../core/light_theme.dart';
import '../presentation/scan_qr_page.dart';

class ScanQrWidget extends StatelessWidget {
  const ScanQrWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
       /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ScanQrPage()));*/
      },
      child: Container(
        margin: const EdgeInsets.only(
            left: 15, right: 15, bottom: 5),
        padding: const EdgeInsets.only(
            left: 15, right: 15, top: 15, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 4,
                  color: (Colors.grey[200]!))
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 15,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(
                Icons.qr_code_scanner,
                size: 20,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Scan QR ',
                style: lightTheme.textTheme.labelSmall!.copyWith(
                    fontSize: 14, fontWeight: FontWeight.bold),

                /* style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),*/
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
