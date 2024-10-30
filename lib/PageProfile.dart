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
import 'package:shared_preferences/shared_preferences.dart';
import 'common/constants.dart';
import 'presentation/attendance/attendence_screen.dart';
import 'ViewProfile.dart';
import 'presentation/attendance/attendence_screen.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserType();
    getProfileImage();
    _getId();
    _getDeviceToken();
  }

  getProfileImage() async {

    try {
      final storageRef = FirebaseStorage.instanceFor(
              bucket: "gs://hng-offline-marketing.appspot.com")
          .ref();

      final prefs = await SharedPreferences.getInstance();
      var locationCode = prefs.getString('locationCode') ?? '106';
      var profile_image_url_ = prefs.getString('profile_image_url') ?? '';

      //        storageRef.child("$locationCode/Profile/$userCode/$empCode.jpg");
      final imageUrl = await storageRef
          .child("Profile/$userCode/$profile_image_url_")
          .getDownloadURL().timeout(const Duration(seconds: 5));
      setState(() {
        // attachProof = true;
        profileImageUrl = imageUrl;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }

  }

  var profileImageUrl = "";

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const ViewProfile()));
                },
                child: Container(
                  // margin: EdgeInsets.all(15),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12, spreadRadius: 1, blurRadius: 2)
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    children: [
                      profileImageUrl.isEmpty
                          ? CircleAvatar(
                              // backgroundColor: Colors.blue,
                              radius: 38,
                              child: Text(userName.getInitials()),
                              // backgroundImage: ,
                            )
                          : Hero(
                        tag: 'userImage',
                            child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 38,
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                          ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$userName',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                'View my profile',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Manage',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                // margin: EdgeInsets.all(15),
                padding: const EdgeInsets.only(
                    left: 20, top: 15, bottom: 15, right: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AttendenceScreen()));
                      },
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.fact_check,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              'Attendance',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                    // const Divider(),
                    /* Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Text(
                            'Leaves',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 15,
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
              Container(
                // margin: EdgeInsets.all(15),
                padding: const EdgeInsets.only(
                    left: 20, top: 15, bottom: 15, right: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MyStaffMovementAppliedPage()));
                      },
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.fact_check,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              'Staff Movement',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 15,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                // margin: EdgeInsets.all(15),
                padding: const EdgeInsets.only(
                    left: 20, top: 15, bottom: 15, right: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StaffMovementPage()));
                      },
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.fact_check,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              'Staff Movement Apply',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 15,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                // margin: EdgeInsets.all(15),
                padding: const EdgeInsets.only(
                    left: 20, top: 15, bottom: 15, right: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const MyStaffMovementHistoryPage()));
                      },
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.fact_check,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              'My Staff Movement History',
                              style:
                              TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 15,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                // margin: EdgeInsets.all(15),
                padding: const EdgeInsets.only(
                    left: 20, top: 15, bottom: 15, right: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                 CoupenGenPage()));
                      },
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.fact_check,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              'Coupon Validation',
                              style:
                              TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 15,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              const Spacer(),
                 const Text(
                'Version ${Constants.appVersion}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10,),
              )

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
      ),
    );
  }

  var userCode = "";

  var userName = "";

  Future<void> getuserType() async {
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString('userType');
    userCode = prefs.getString('userCode')!;
    userName = prefs.getString('user_name')!;
    setState(() {
      userCode = userCode;
      userName = userName;
    });
  }

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    // Navigator.popUntil(
    //     context,
    //     (route) => MaterialPageRoute(builder: (BuildContext context) =>LoginScreen));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen()),
      ModalRoute.withName('/SplashScreen'),
    );
  }
  var deviceId = "";
  var tokenFCM = "";

  Future<String> _getId() async {

    final SharedPreferences pref = await SharedPreferences.getInstance();

    String? id = await pref.getString(
      "deviceid",
    );

    // var Myid;

    setState(() {
      deviceId = id!;
      // deviceId = "55ec53ccf5a40648";
    });

    return deviceId;
  }
  Future<String> _getDeviceToken() async {

    final SharedPreferences pref = await SharedPreferences.getInstance();

    String? id = await pref.getString(
      "tokenFCM",
    );

    // var Myid;

    setState(() {
      tokenFCM = id!;
      // deviceId = "55ec53ccf5a40648";
    });

    return tokenFCM;
  }

}

