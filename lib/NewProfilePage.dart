import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/presentation/coupen_generation_page.dart';
import 'package:hng_flutter/presentation/login/login_screen.dart';
import 'package:hng_flutter/extensions/string_extension.dart';
import 'package:hng_flutter/main.dart';
import 'package:hng_flutter/presentation/my_staff_movement_applied_page.dart';
import 'package:hng_flutter/presentation/my_staff_movement_history_page.dart';
import 'package:hng_flutter/presentation/profile/staff_movement_page.dart';
import 'package:hng_flutter/widgets/profile_page_list_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/constants.dart';
import 'presentation/attendance/attendence_screen.dart';
import 'ViewProfile.dart';
import 'presentation/attendance/attendence_screen.dart';

class NewPageProfilePage extends StatefulWidget {
  const NewPageProfilePage({Key? key}) : super(key: key);

  @override
  State<NewPageProfilePage> createState() => _NewPageProfilePageState();
}

class _NewPageProfilePageState extends State<NewPageProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 45,
              color: Colors.indigo,
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Account Menu',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const CircleAvatar(
              backgroundColor: Colors.indigo,
              radius: 38,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
              // backgroundImage: ,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hi, Charles',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 5),
                          child: Text(
                            'Employee Role',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Spacer(),
                ],
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Assigned Learning Paths',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Text('10',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                Column(
                  children: [
                    Text('Badges earned',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    Text('2',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xfff0f0f8),
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(6),
              child: const Column(
                children: [
                  ProfilePageListWidget(
                    customIcon: Icons.person,
                    customText: 'Profile',
                  ),
                  ProfilePageListWidget(
                    customIcon: Icons.add_box_rounded,
                    customText: 'Manage',
                  ),
                  ProfilePageListWidget(
                    customIcon: Icons.play_circle,
                    customText: 'Studio Tools',
                  ),
                  ProfilePageListWidget(
                    customIcon: Icons.celebration,
                    customText: 'Badges',
                  ),
                  ProfilePageListWidget(
                    customIcon: Icons.settings,
                    customText: 'Seetings',
                  ),
                ],
              ),
            ),
          ],
        ),
        Visibility(
            visible: loading,
            child: Center(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.all(20),
                    height: 115,
                    width: 150,
                    child: const Column(
                      children: [
                        CircularProgressIndicator(),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Please wait..'),
                        )
                      ],
                    )))),
      ],
    );
  }
}
