import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/presentation/order_list_screen.dart';
import 'package:hng_flutter/presentation/order_management_screen.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:hng_flutter/widgets/product_quick_enquiry_widget.dart';
import 'package:hng_flutter/widgets/scan_qr_widget.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'checkInOutScreenIOS.dart';
import 'common/constants.dart';
import 'common/permission_popup.dart';
import 'controllers/taskCheckerController.dart';
import 'core/light_theme.dart';
import 'presentation/attendance/attendence_screen.dart';
import 'data/GetProgressStatus.dart';
import 'checkInOutScreen_TEMP.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

var base64img;
var imgType_;
bool am = false;

var status_ = 0.obs;
var deviceID = "Not known";
var lat, lng;
var startendTimeText = 'Your shift time starts at ';
bool checkOutbnt = false;
String time = "09:30 AM";
Future<dynamic>? _future;

var chekinTime = "";
var chekoutTime = "";
var checkInBool = true;

Geolocator geolocator = Geolocator();
// final AsyncMemoizer _memoizer = AsyncMemoizer();

class _PageHomeState extends State<PageHome> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checkPermissions();
    _future = getActiveCheckListData();
    getUserCheckInStatus();
    getTime();
    getuserType();
  }

  checkPermissions(int checkInOutType) async {
    PermissionStatus locationPermission = await Permission.location.status;
    PermissionStatus cameraPermission = await Permission.camera.status;
    // gotoCheckInOutScreen(checkInOutType);

    // if(locationPermission.isGranted&&)
    if (locationPermission.isPermanentlyDenied ||
        locationPermission.isDenied ||
        locationPermission.isRestricted ||
        cameraPermission.isPermanentlyDenied ||
        cameraPermission.isDenied ||
        cameraPermission.isRestricted) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Access Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please provide the following permissions for more personalised experience.',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_pin),
                    title: const Text('Allow Location Access'),
                    subtitle: const Text(
                        'For doing CheckIn/CheckOut process at Location we need Location permission enabled',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3),
                    onTap: () async {
                      await Permission.location.request();
                      // onPermissionGranted(PermissionStatus.granted);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Allow Camera Access'),
                    subtitle: const Text(
                        'To CheckIn/CheckOut we need camera access to take photo',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3),
                    onTap: () async {
                      await Permission.camera.request();
                      // onPermissionGranted(PermissionStatus.granted);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Allow Notifications'),
                    subtitle: const Text(
                        'Get notified about the latest offers, schemes & new arrivals.',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3),
                    onTap: () async {
                      await Permission.notification.request();
                      // onPermissionGranted(PermissionStatus.granted);
                    },
                  ),
                ],
              ),
              actions: [
                CustomElevatedButton(
                    text: 'Settings',
                    onPressed: () {
                      openAppSettings();
                    }),
                CustomElevatedButton(
                    text: 'Proceed',
                    onPressed: () async {
                      gotoCheckInOutScreen(checkInOutType);
                      Navigator.pop(context);
                      if (locationPermission.isPermanentlyDenied ||
                          locationPermission.isDenied ||
                          locationPermission.isRestricted ||
                          cameraPermission.isPermanentlyDenied ||
                          cameraPermission.isDenied ||
                          cameraPermission.isRestricted) {
                        await Permission.camera.request();
                        await Permission.location.request();
                      }
                    }),
              ],
            );
          });

      // showDialog(
      //   context: context,
      //   builder: (context) => PermissionPopup(
      //     onPermissionGranted: (status) {
      //       // Handle permission granted
      //       // gotoCheckInOutScreen(checkInOutType);
      //       Navigator.pop(context);
      //     },
      //     onPermissionDenied: (status) {
      //       Navigator.pop(context);
      //
      //       showPermissionAlert();
      //
      //       // Handle permission denied
      //     },
      //   ),
      // );
    } else {
      gotoCheckInOutScreen(checkInOutType);
    }
  }

  PermissionStatus _permissionStatus = PermissionStatus.permanentlyDenied;

  Future<void> requestLocationPermission(int isCheckIn) async {
    final status = await Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });
    if (_permissionStatus.isGranted) {
      gotoCheckInOutScreen(isCheckIn);
    } else if (_permissionStatus.isPermanentlyDenied ||
        _permissionStatus.isDenied ||
        _permissionStatus.isRestricted) {
      showPermissionAlert();
    }
  }

  showPermissionAlert() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text(
              'Please allow Location and Camera permission\'s for CheckIn and CheckOut process'),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Ok',
                onPressed: () {
                  Navigator.of(context).pop();
                  // submitCheckList();
                  openAppSettings();
                }),
          ],
        );
      },
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getUserCheckInStatus();
      //do your stuff
    }
    /*   if(state==AppLifecycleState.paused){
      getUserCheckinstatus();
    }*/
  }

  bool showLocation = false;

  showAlertFCM(var token) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text('$token'),
          actions: <Widget>[
            Container(
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    // submitCheckList();
                    await Clipboard.setData(ClipboardData(text: token));
                  },
                  child: const Text('Copy to ClipBoard',
                      style: TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );
  }

  var userCode = "";
  var userName = "";
  var profile_image_url = "";

  Future<void> getuserType() async {
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString('userType');
    userCode = prefs.getString('userCode')!;
    userName = prefs.getString('user_name')!;
    // profile_image_url = prefs.getString('profile_image_url')!;
    setState(() {
      userCode = userCode;
    });
    if (user == '0') {
      am = false;
    } else if (user == '1') {
      am = true;
    }
    getProfileImage();
  }

  getProfileImage() async {
    try {
      final storageRef = FirebaseStorage.instanceFor(
              bucket: "gs://hng-offline-marketing.appspot.com")
          .ref();

      final prefs = await SharedPreferences.getInstance();
      var locationCode = prefs.getString('locationCode') ?? '106';
      var profileImageUrl_ = prefs.getString('profile_image_url') ?? '';
      print(profileImageUrl_);

      //        storageRef.child("$locationCode/Profile/$userCode/$empCode.jpg");
      final imageUrl = await storageRef
          .child("Profile/$userCode/$profileImageUrl_")
          .getDownloadURL();
      print("imageUrl");
      print(imageUrl);
      setState(() {
        // attachProof = true;
        profile_image_url = imageUrl;
      });
    } catch (e) {
      print("profile_image_urle");
      print("$e");
      // Fluttertoast.showToast(msg: "");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool showImage = false;
  final TaskCheckerController taskCheckController =
      Get.put(TaskCheckerController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 10),
              height: 170,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: (Colors.grey[200])!,
                      spreadRadius: 5,
                      blurRadius: 5)
                ],
                color: const Color(0xfff76613),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      profile_image_url.isEmpty
                          ? const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              // backgroundImage: ,
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  showImage = true;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(profile_image_url),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Hi, $userName\nEmp ID : $userCode',
                          /*    style: const TextStyle(
                              color: Colors.white, fontSize: 13),*/
                          style: lightTheme.textTheme.labelSmall!
                              .copyWith(fontSize: 13, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: noInterNet == false
                          ? Text(
                              Constants.networkIssue,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          : Column(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      startendTimeText,
                                      // style: const TextStyle(fontSize: 12),
                                      style: lightTheme.textTheme.bodySmall!
                                          .copyWith(fontSize: 12),
                                    ),
                                    Text(
                                      checkOutbnt
                                          ? '$chekinTime'
                                          : checkInBool
                                              ? '09:30 AM'
                                              : '$chekinTime',
                                      style: lightTheme.textTheme.labelMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                      /* style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),*/
                                    ),
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: checkOutbnt
                                        ? checkoutBtnWidget()
                                        : checkInBool
                                            ? checkInBtn()
                                            : const Text('')),
                              ],
                            ),
                    ),
                  )
                ],
              ),
            ),

            Visibility(
              visible: true,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AttendenceScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 20, left: 15, right: 15, bottom: 5),
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
                          Icons.group_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'My team Activities ',
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
              ),
            ),

            const ProductQuickEnquiryWidget(),

            // const ScanQrWidget(),
            const Divider(),
           /* GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  OrderManagementScreen()));
              },
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
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
                        Icons.help_outline,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'HyperLocal ',
                        style: lightTheme.textTheme.labelSmall!.copyWith(
                            fontSize: 14, fontWeight: FontWeight.bold),


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
            ),
            const Divider(),*/

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, top: 10, right: 10, bottom: 15),
                child: Text(
                  'Explore Company',
                  // style: TextStyle(fontSize: 15),
                  style: lightTheme.textTheme.labelSmall!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Visibility(
              visible: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(left: 15, right: 15, top: 10),
                      padding: const EdgeInsets.only(left: 15, bottom: 10),
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(color: Colors.grey, blurRadius: 3)
                          ]),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.list_alt,
                              color: Colors.grey,
                              size: 35,
                            ),
                          ),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Policies',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 5, right: 15, top: 10),
                      padding: const EdgeInsets.only(left: 15, bottom: 10),
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(color: Colors.grey, blurRadius: 3)
                          ]),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Icon(
                                Icons.list_alt,
                                color: Colors.grey,
                                size: 35,
                              )),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Holidays',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(7),
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: CupertinoColors.systemBlue,
              ),
              child: Center(
                child: Text(
                  // "303030",
                  'Activity Status Report',
                  // checkList.length == 0 ? '' : checkList[0].userId,
                  /*style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),*/
                  style: lightTheme.textTheme.labelSmall!.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Divider(),
            FutureBuilder<dynamic>(
                future: _future,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  // print('atten $snapshot.data');
                  if (snapshot.data == null) {
                    return const Center(
                      child: Text('No data'),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return checkList.isEmpty
                        ? const Text(
                            'No Records',
                          )
                        : checkList[0].audittypes.isEmpty
                            ? const Text('No Records')
                            : Expanded(
                                // height: 200,
                                child: ListView.builder(
                                    itemCount: checkList.isEmpty
                                        ? 0
                                        : checkList[0].audittypes.length,
                                    itemBuilder:
                                        (BuildContext context, int pos) {
                                      return item(pos);
                                    }),
                              );
                  }
                }),
            SizedBox(
              height: checkList.isEmpty ? 0 : 50,
            ),
          ],
        ),
        Visibility(
            visible: showImage,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // Icon(Icons.close,color: Colors.red,),
                  profile_image_url.isEmpty
                      ? const SizedBox()
                      : Center(
                          child: Image.network(profile_image_url.isNotEmpty
                              ? profile_image_url
                              : ''),
                        ),
                  Container(
                    color: Colors.white,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            showImage = false;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        )),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget checkInBtn() {
    return InkWell(
        onTap: () {
          if (Platform.isIOS) {
            gotoCheckInOutScreen(0);
          } else {
            checkPermissions(0);
          }
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => checkInOutScreenIOS(0),
            ));*/
          /*  if(Platform.isAndroid){
          requestLocationPermission(0);
        }else{
          gotoCheckInOutScreen(0);
        }*/
        },
        child: Container(
          margin: const EdgeInsets.only(top: 7),
          padding:
              const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(
                color: Colors.green,
              )),
          child: Obx(() {
            if (taskCheckController.isLoading.value) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              );
            }
            return Text(
              'Check In',
              style: lightTheme.textTheme.labelSmall!
                  .copyWith(fontSize: 13, color: Colors.white),
            );
          }),
        ));
  }

  // var lat, lng;
  int _expandedIndex = -1;

  Widget item(int pos) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedIndex = pos;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _expandedIndex == pos
                  ? const Color(0xfff76613)
                  : Colors.white,
              boxShadow: [
                const BoxShadow(color: Color(0xFFBDBDBD), blurRadius: 2)
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            // height: 50,
            child: Center(
                child: Text(' ${checkList[0].audittypes[pos].auditType}')),
          ),
        ),
        Visibility(
          visible: _expandedIndex == pos ? true : false,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(5)),
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
            child: const Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text('Region'),
                ),
                Expanded(
                  child: Text('Store Name'),
                ),
                Expanded(
                  child: Text('Current Status'),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: _expandedIndex == pos ? true : false,
          child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              // scrollDirection: Axis.horizontal,
              // itemCount: checkList[0].audittypes.length,
              itemCount: checkList[0].audittypes[pos].locationdetails.length,
              itemBuilder: (BuildContext ctx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      showLocation = !showLocation;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      // boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                              '${checkList[0].audittypes[pos].locationdetails[index].region}'),
                        ),
                        Expanded(
                            child: Text(
                                '${checkList[0].audittypes[pos].locationdetails[index].location}')),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                                '${checkList[0].audittypes[pos].locationdetails[index].checklistProgressSatus}'),
                          ),
                        ),
                      ],
                    ),
                    // child: Text(' ${checkList[0].audittypes[index].auditType}'),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Future<void> getlocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = position.latitude;
      lng = position.longitude;
    });
  }

  Widget checkoutBtnWidget() {
    return InkWell(
      onTap: () {
        checkPermissions(1);
        // requestLocationPermission(1);
        /* showDialog(
          context: context,
          builder: (context) => PermissionPopup(
            onPermissionGranted: (status) {
              // Handle permission granted
            },
            onPermissionDenied: (status) {
              // Handle permission denied
            },
          ),
        );*/
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
        decoration: BoxDecoration(
            // color: Colors.green,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(
              color: const Color(0xfff76613),
            )),
        child: Text(
          'Check Out',
          style: lightTheme.textTheme.labelSmall!
              .copyWith(fontSize: 13, color: const Color(0xfff76613)),

/*          style: TextStyle(
              color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold),*/
        ),
      ),
    );
  }

  bool showProgress = false;

  Future<void> getPhoto() async {
    final ImagePicker _picker = ImagePicker();
    XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    _cropImage(photo);
  }

  var timeMin = "";

  void getTime() {
    var datetime = DateTime.now();
    var datetime_ = DateFormat("hh:mm a").format(DateTime.now());
    print(datetime_);
    print(datetime.minute);
    setState(() {
      // timeMin = datetime.hour.toString() + ':' + datetime.minute.toString();
      timeMin = datetime_;
    });
  }

  var _croppedFile;

  Future<void> _cropImage(var photo) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          /* IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),*/
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
        final path = _croppedFile!.path;
        print(path.toString().split('.'));
        var imgType = path.toString().split('.');

        print("_croppedFile");
        imgType.forEach((element) {
          print(element);
          if (element == 'jpg') {
            setState(() {
              imgType_ = 'jpg';
            });
          } else if (element == 'png') {
            setState(() {
              imgType_ = 'png';
            });
          }
        });
        croppedFile.readAsBytes().then((value) {
          final imageEncoded = base64.encode(value);
          print('imageEncoded');
          print(imageEncoded);
          setState(() {
            base64img = imageEncoded;
          });
        });
        // checkInUser();
        // print(bytes);
      }
    }
  }

  Future<void> gotoCheckInOutScreen(int checkInOutType) async {
    final prefs = await SharedPreferences.getInstance();
    var result;

    if (Platform.isAndroid) {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => checkInOutScreen_TEMP(checkInOutType),
          ));
    } else if (Platform.isIOS) {
      result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => checkInOutScreenIOS(checkInOutType),
          ));
    }

    // after the SecondScreen result comes back update the Text widget with it

    if (result != null) {
      getUserCheckInStatus();

      if (result == 0) {
        await prefs.setString('ckdIn', '1');
        await prefs.setString('ckdInTime', '$timeMin');

        setState(() {
          startendTimeText = "You check in at ";
          checkOutbnt = true;
          time = timeMin;
        });
      } else if (result == 1) {
        await prefs.setString('ckdIn', '0');
        // await prefs.setString('ckdInTime', '$timeMin');

        setState(() {
          checkOutbnt = false;

          startendTimeText = 'Your Shift time start at ';
          // time = timeMin;
        });
      }
    } else {
      // getUserCheckIn();
      getUserCheckInStatus();
    }
  }

  List<GetProgressStatus> checkList = [];

  Future<dynamic> getActiveCheckListData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';
      String url = "${Constants.apiHttpsUrl}/Login/GetProgressStatus/$userID";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      checkList = [];

      Iterable l = json.decode(response.body);
      checkList = List<GetProgressStatus>.from(
          l.map((model) => GetProgressStatus.fromJson(model)));
      return checkList;
    } catch (e) {
      return null;
    }
  }

  Future<void> getUserCheckInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';
      // String url = "${Constants.apiHttpsUrl}/Login/checkinstatus/70002";
      String url = "${Constants.apiHttpsUrl}/Login/checkinstatus/$userID";

      print(url);
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['statusCode'] == "200") {
          if (responseData['checkin_flag'] == "Y" &&
              responseData['checkiout_flag'] == "Y") {
            print('Y&Y');

            String date = responseData['chekout_time'];
            DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
            var inputDate = DateTime.parse(parseDate.toString());
            var outputFormat = DateFormat('hh:mm a');

            setState(() {
              // chekinTime = outputFormat.format(inputDate);
              // chekinTime = responseData['chekin_time'];
              checkOutbnt = false;
              startendTimeText = "You checked out ";
              checkInBool = false;
              chekinTime = outputFormat.format(inputDate);
              print('chekinTime');
              print(chekinTime);
            });
          } else if (responseData['checkin_flag'] == "Y" &&
              responseData['checkiout_flag'] == "N") {
            print('Y&N');

            String date = responseData['chekin_time'];
            DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
            var inputDate = DateTime.parse(parseDate.toString());
            var outputFormat = DateFormat('hh:mm a');

            setState(() {
              chekinTime = outputFormat.format(inputDate);
              checkOutbnt = true;
              startendTimeText = "You check in at ";
            });
            taskCheckController.checkTaskStatus();
          } else if (responseData['checkin_flag'] == "N" &&
              responseData['checkiout_flag'] == "Y") {
            print('N&Y');

            String date = responseData['chekout_time'];
            DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
            var inputDate = DateTime.parse(parseDate.toString());
            var outputFormat = DateFormat('hh:mm a');

            setState(() {
              chekoutTime = outputFormat.format(inputDate);
              checkOutbnt = false;

              startendTimeText = "Your Shift time start at ";
            });
            taskCheckController.checkTaskStatus();
          } else if (responseData['checkin_flag'] == "N" &&
              responseData['checkiout_flag'] == "N") {
            String date = responseData['chekout_time'];
            if (date != "") {
              DateTime parseDate =
                  DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
              var inputDate = DateTime.parse(parseDate.toString());
              var outputFormat = DateFormat('hh:mm a');

              setState(() {
                chekoutTime = outputFormat.format(inputDate);
                checkOutbnt = false;
                startendTimeText = "Your Shift time start at ";
              });
            }
            taskCheckController.checkTaskStatus();
          }
        }
      } else {
        Get.snackbar(
          "Alert!", // SnackBar title
          "Something went wrong\nStatusCode:${response.statusCode}",
          snackPosition: SnackPosition.TOP,
          // You can customize the SnackBar's position
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(
              seconds: 3), // Duration for how long the SnackBar is displayed
        );
      }
    } catch (e) {
      setState(() {
        noInterNet = false;
        checkOutbnt = false;
      });
    }
  }

  bool noInterNet = true;
}
