import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/data/GetChecklist.dart';
import 'package:hng_flutter/checkListItemScreen.dart';
import 'package:hng_flutter/checkListItemScreen_Lpd.dart';
import 'package:hng_flutter/lpdCheckListScreen.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/ActiveCheckListLpd.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/LPDSection.dart';
import 'checkListScreen_lpd.dart';
import 'helper/permission_helper.dart';
import 'main.dart';

class checkInOutScreenLPD extends StatefulWidget {
  // int chekassignId_;
  final ActiveCheckListLpd activeCheckList;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  // LPDSection mLpdChecklist;

  checkInOutScreenLPD(this.activeCheckList, this.mGetActvityTypes,
      this.locationsList);

  @override
  State<checkInOutScreenLPD> createState() => _checkInOutScreenLPDState(
      this.activeCheckList,
      this.mGetActvityTypes,
      this.locationsList,
      );
}

class _checkInOutScreenLPDState extends State<checkInOutScreenLPD> {
  ActiveCheckListLpd activeCheckList;
  GetActvityTypes mGetActvityTypes;
  String locationsList;

  // LPDSection mLpdChecklist;

  _checkInOutScreenLPDState(this.activeCheckList, this.mGetActvityTypes,
      this.locationsList);

  XFile? photo;
  var _croppedFile;
  var deviceID = "Not known";
  var lat, lng;

  Geolocator geolocator = Geolocator();


  Timer? timer;
  var status_;
  var imageType;

  var imageEncoded;
  bool successPopUp = false;
  bool loading = false;
  var typeAttencenceList = [
    'Present',
    'Out of Office meeting',
    'Client meeting',
    'Marked as present'
  ];
  String dropdownText = "Present";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handlePermission();
    getTime();

    /*Timer timer =
        Timer.periodic(Duration(seconds: 15), (Timer t) => getlocation());*/
    photo = null;
  }



  Future<void> handlePermission() async {
    final status = await PermissionHelper.requestLocationPermission();

    if (status.isGranted) {
      // Permission granted, proceed with your logic
      if (widget.activeCheckList.location_Validate_flag == "Y") {
        getlocation(0);
      } else {
        getPhoto(0);
      }
    } else if (status.isPermanentlyDenied ||
        status.isDenied ||
        status.isRestricted) {
      const dynamicMessage = 'Please allow location permission for Location Check process';
      PermissionHelper.showPermissionAlert(context, dynamicMessage);
    }
  }

  CameraController? Camcontroller;
  String imagePath = "";
  bool camVisible = false;

  getPhoto(int firstTime) async {
    final ImagePicker _picker = ImagePicker();

    if (Platform.isAndroid) {
      try {
        final cameras =
            await availableCameras(); //get list of available cameras
        final frontCam = cameras[1];

        Camcontroller = CameraController(frontCam, ResolutionPreset.medium);
        Camcontroller?.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            camVisible = true;
          });
        });
      } on CameraException catch (e) {
        print('Error in fetching the cameras: $e');
      }
    } else {
      photo = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      _cropImage(photo, firstTime);
    }
    /* String? deviceId = await PlatformDeviceId.getDeviceId;
    print("DeviceID");
    print(deviceId);*/
  }

  var timeMin = "";

  getTime() {
    var datetime = DateTime.now();
    var datetime_ = DateFormat("hh:mm a").format(DateTime.now());

    print(datetime_);
    print(datetime.minute);
    setState(() {
      // timeMin = datetime.hour.toString() + ':' + datetime.minute.toString();
      timeMin = datetime_;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  var lat_ = 0.0, lng_ = 0.0;

  Future<void> getlocation(var firstime) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("_determinePosition");
      print(position.latitude);
      print(position.longitude);

      setState(() {
        lat_ = double.parse(widget.activeCheckList.latitude);
        // lat_ = position.latitude;
        // lng_ = position.longitude;
        lng_ = double.parse(widget.activeCheckList.longitude);
      });

      // var lat = prefs.getString('latitude');
      //
      // var lng = prefs.getString('longitude');
      var lat = position.latitude; //user lat

      var lng = position.longitude; //user lng

      setState(() {
        loading = false;
      });
      checkDistance_(lat, lng, lat_, lng_, firstime);
    } catch (e) {
      Navigator.pop(context);
    }

    // getLocationStatus(0);
  }

  checkDistance_(var lat, var lng, var lat_, var lng_, var firstime) async {
    try {
      setState(() {
        loading = true;
      });
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double currentLatitude = position.latitude;
      double currentLongitude = position.longitude;

      double distanceInMeters = Geolocator.distanceBetween(
          currentLatitude, currentLongitude, lat_, lng_);
      print("checkDistance");
      print(distanceInMeters);
      var mts = distanceInMeters.toString().split('.');
      var meters = mts[0];
      if (int.parse(meters) <= 150) {
        setState(() {
          loading = false;
          takePhoto = true;
        });
        // alertGetPhoto('You are near to store\n$meters meters ', firstime);
        alertGetPhoto(
            'You are tagged to Store ${widget.activeCheckList.locationName}. Click Proceed to continue ',
            firstime);
      } else {
        setState(() {
          loading = false;
          takePhoto = false;
        });
        alertExit(
          'You are outside of store\n$meters meters far.',
        );
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  bool takePhoto = false;

  Future alertExit(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context_) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  // Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => checkListScreen_lpd(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                         ),
                      ));
                },
              ),
              TextButton(
                child: const Text('ReCheck'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => checkListScreen_lpd(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                           ),
                      )); // getPhoto(0);

                  // getLocationStatus(f);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future alertGetPhoto(String msg, int f) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context_) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: const Text('Proceed'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  getPhoto(f);
                },
              ),
              /*  TextButton(
                child: const Text('ReCheck'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  Navigator.of(context).pop();
                  // getLocationStatus(f);
                },
              ),*/
            ],
          ),
        );
      },
    );
  }

  Future alertReCheck(String msg, int f) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context_) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it'),
                onPressed: () {
                  Navigator.of(context_).pop();
                },
              ),
              TextButton(
                child: const Text('ReCheck'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  // Navigator.of(context).pop();
                  // getLocationStatus(f);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String date = widget.activeCheckList.startDate;
    DateTime parseDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('MMM dd yyyy');
    var outputDate = outputFormat.format(inputDate);

    //starttime
    String start_time = widget.activeCheckList.startTime;
    DateTime start_time_ = DateFormat("dd-MM-yyyy HH:mm:ss").parse(start_time);
    var startTime_ = DateTime.parse(start_time_.toString());
    var startTimeFormat = DateFormat('hh:mm a');
    var outputTime = startTimeFormat.format(startTime_);

    //outtime
    String endTime = widget.activeCheckList.endTime;
    DateTime endTime_ = DateFormat("dd-MM-yyyy HH:mm:ss").parse(endTime);
    var endTime__ = DateTime.parse(endTime_.toString());
    // var startTimeFormat = DateFormat('hh:mm a');

    var enddTime = startTimeFormat.format(endTime__);

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => checkListScreen_lpd(
                    1,
                    widget.mGetActvityTypes,
                    widget.locationsList,
                   ),
              ));
          return Future.value(false);
        },
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 15),
                    child: Stack(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: InkWell(
                            onTap: () {
                              // Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => checkListScreen_lpd(
                                        1,
                                        widget.mGetActvityTypes,
                                        widget.locationsList,
                                       ),
                                  ));
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: RichText(
                                text: const TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: 'Activity Check In',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black)),
                                ]),
                              )),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                /*Image.asset(
                              'assets/maps.jpeg',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                            ),*/
                                Container(
                                  color: Colors.black26,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(5),
                                      width: 80,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            size: 20,
                                          ),
                                          Text(
                                            'Refresh',
                                            style: TextStyle(fontSize: 12),
                                          )
                                        ],
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: () {
                                // findUserGeoLoc();
                                // getlocStatus(1);
                                // findUserGeoLoc(1);
                                if (widget.activeCheckList
                                        .location_Validate_flag ==
                                    "Y") {
                                  getlocation(1);
                                } else {
                                  getPhoto(1);
                                }
                                getTime();
                              },
                              child: SizedBox(
                                height: 110,
                                width: 120,
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: _body(),
                                    ),
                                    const Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 15, right: 10),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              'Check In time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ),
                          Text(
                            timeMin,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          /*   Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Shift',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF757575)),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('General Shift',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Time',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF757575))),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('09:30AM To 07:00PM',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                            ],
                          ),*/
                          const SizedBox(
                            height: 7,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 7,
                          ),
                          Visibility(
                            visible: true,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'LPD',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                'Time : $outputTime - $enddTime',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 7,
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                'Store name : ${widget.activeCheckList.locationName} ',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /*      InkWell(
                  onTap: () async {
                    String? deviceId = await PlatformDeviceId.getDeviceId;
                    print("DeviceID");
                    print(deviceId);
                    setState(() {
                      deviceID = deviceId!;
                    });
                    final ImagePicker _picker = ImagePicker();
                    photo = await _picker.pickImage(source: ImageSource.camera);
                    _cropImage(photo);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Take Photo',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )),
              Text(
                'Your location : lat=' +
                    lat.toString() +
                    ",lng = " +
                    lng.toString(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Locked location:",
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      )),
                  Text("  lat:12.9111277,lng: 77.6267444",
                      style: TextStyle(
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                status_,
                style: TextStyle(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
              Text(
                'Your DeviceID:',
              ),
              Text(deviceID,
                  style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold)),*/

                  /*Center(
                child: InkWell(

                    onTap: () async {
                      Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      print("_determinePosition");
                      print(position.latitude);
                      print(position.longitude);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble('lat', position.latitude);
                      await prefs.setDouble('lng', position.longitude);
                    },
                    child: Text(
                      'GET LOCATION',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    )),
              ),
              InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final double? lat = prefs.getDouble('lat');
                    final double? lng = prefs.getDouble('lng');

                    Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high);

                    if (lat != position.latitude || lng != position.longitude) {
                      print("not there");
                      print("$lat,$lng");
                      print(position.longitude);
                      print(position.latitude);
                    }
                  },
                  child: Text(
                    'Check LOCATION',
                    style: TextStyle(
                      fontSize: 45,
                    ),
                  )),*/

                  // _body(),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    if (takePhoto) {
                      if (imageType != null) {
                        checkInUser(imageEncoded);
                      } else {
                        alert("Please take photo.");
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        'Check In',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  color: const Color(0x80000000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.only(
                            left: 15, top: 10, bottom: 15, right: 15),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    'Select Attendence Type',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                )),
                            const Divider(),
                            ListView.separated(
                              shrinkWrap: true,
                              itemCount: typeAttencenceList.length,
                              itemBuilder: (context, pos) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 7, bottom: 7, left: 10),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        dropdownText = typeAttencenceList[pos];
                                        showAtdncTypePopup = false;
                                      });
                                      print(typeAttencenceList[pos]);
                                    },
                                    child: Text(typeAttencenceList[pos],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                        )),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(visible: successPopUp, child: loginSuccess()),
              Visibility(
                  visible: loading,
                  child: Container(
                    color: const Color(0x80000000),
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
                            ))),
                  )),
              Visibility(
                  visible: Camcontroller == null ? false : camVisible,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    // aspectRatio: controller!.value.aspectRatio,
                    child: Stack(
                      children: [
                        SizedBox(
                            height: double.infinity,
                            // height: MediaQuery.of(context).size.height,
                            // width: MediaQuery.of(context).size.width,
                            width: double.infinity,
                            child: Camcontroller == null
                                ? const CircularProgressIndicator()
                                : CameraPreview(Camcontroller!)),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: () async {
                                // final image = await Camcontroller!.takePicture();

                                try {
                                  final image =
                                      await Camcontroller!.takePicture();
                                  setState(() {
                                    imagePath = image.path;
                                    camVisible = false;
                                  });
                                  _cropImage(image.path, 0);
                                } catch (e) {
                                  print(e);
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 35,
                                  child: Icon(Icons.camera),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage(var photo, int firstTime) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: Platform.isAndroid ? photo : photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality : 40,//1280 x 720//1920 x 1080
        maxWidth: 1920,
        maxHeight: 1080,
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
        final tempFile = croppedFile.readAsBytes();
        final path = _croppedFile!.path;
        print(path.toString().split('.'));
        var imgType = path.toString().split('.');

        print("_croppedFile");
        imgType.forEach((element) {
          print(element);
          if (element == 'jpg') {
            setState(() {
              imageType = 'jpg';
            });
          } else if (element == 'png') {
            setState(() {
              imageType = 'png';
            });
          }
        });

        print('imageEncoded');
        croppedFile.readAsBytes().then((value) {
          imageEncoded = base64.encode(value);
        });

        if (firstTime == 0) {
          // popupAttendence(/);
          setState(() {
            showAtdncTypePopup = true;
          });
        } else if (firstTime == 1) {
          setState(() {
            showAtdncTypePopup = false;
          });
        }
      }
    }
  }

  bool showAtdncTypePopup = false;

  bool showProgress = false;

  Future<void> cloudstorageRef(var img, var empCCode_) async {
    String empCode = empCCode_;

    // final storageRef = FirebaseStorage.instance.ref();
    // FirebaseStorage storageRefd = FirebaseStorage.instanceFor(bucket: "gs://hgstores_rwa_dilo");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();

    // var locationCode = prefs.getString('locationCode') ?? '106';
    var locationCode = widget.activeCheckList.locationCode;

    final imagesRef = storageRef.child("$locationCode/LPDCheckIn/$empCode.jpg");

    // String dataUrl = base64img;
// Create a reference to "mountains.jpg"
    final mountainsRef =
        imagesRef.child("$locationCode/DiloCheckIn/$empCode.jpg");

// Create a reference to 'images/mountains.jpg'
    try {
      // await imagesRef.putString(img, format: PutStringFormat.dataUrl);
      await imagesRef
          .putString(img,
              format: PutStringFormat.base64,
              metadata: SettableMetadata(contentType: 'image/png'))
          .then((p0) => print('uploaded to firebase storage successfully'));
      String downloadUrl = (await FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref())
          .toString();
      print(downloadUrl);
    } on FirebaseException catch (e) {
      print('FirebaseException');
      print(e.message);
      // ...
    }
  }

  checkInUser(var base64img) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();

      // var json = jsonDecode(prefs.getString('loginResponse') ?? '');
      String datetime_ =
          DateFormat("yyyy-MM-dd'T'hh:mm:ss.S'Z'").format(DateTime.now());
      print('DATATIME ' + datetime_);

      String date_ = DateFormat("yyyy-MM-dd").format(DateTime.now());
      String date_time =
          DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
      String dateForEmpCode_ =
          DateFormat("yyyyMMddhhmmssS").format(DateTime.now());

      var userId = prefs.getString("userCode");
      String empCode = "EMP$userId$dateForEmpCode_";

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/lpdaudit/Lpd_CheckIn', //lpdaudit/AddCheckinHeader
      );

      var locationCode;
      locationCode = prefs.getString('locationCode');
      print(prefs.getString('locationCode'));
      var deviceid = prefs.getString("deviceid");

      var params = {
        "lpd_checklist_assign_id": activeCheckList.lpdChecklistAssignId,
        "userId": userId,
        "check_in_lat": '$lat_',
        "check_in_long": '$lng_',
        "created_by": userId,
        "updated_by": 0,
        "validated_long_lat": "Y",
        "deviceid": deviceid,
        "images": {
          "imageName": empCode,
          "imageFormat": "jpg",
          "imagebase64": ""
        },
      };

      //{"statusCode":"200","message":"LPD Check In is Completed","errerMessage":null}
      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(milliseconds: 5000));

      var forlog = jsonEncode(params);
      print('forlog' + forlog);
      print(response.body);
      print(response.statusCode);
      print(response.toString());
      var respo = jsonDecode(response.body);

      print(response.body);
      print(response.statusCode);
      print(response.toString());

      print(respo['statusCode']);
      if (respo['statusCode'] == '200') {
        cloudstorageRef(base64img, empCode);

        setState(() {
          loading = false;
          successPopUp = true;
          imageEncoded = null;
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          // Navigator.pop(context, 1);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => lpdCheckListScreen(
                    1,
                    widget.mGetActvityTypes,
                    widget.locationsList,

                    widget.activeCheckList),
              ));

          /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      checkListItemScreen_Lpd(widget.activeCheckList,widget.mLpdChecklist),
                ));*/
          /* Get.off(
            SplashScreen(),
            arguments: 1,
            transition: Transition.leftToRight,
          );*/
        });
        //{"statusCode":"200","message":"Attendance Add Successfully","errerMessage":null}

        if (respo['message'] == 'LPD Check In is Completed') {}
      } else {
        setState(() {
          loading = false;
          successPopUp = false;
          imageEncoded = null;
        });

        var msg = respo['message'] ?? 'Please try after sometime.';
        alertFailure(msg);
      }
      /* setState(() {
      // loading = false;
      imageEncoded = null;
    });*/
    } catch (e) {
      setState(() {
        loading = true;
      });
      _showRetryAlert(base64img);
    }
  }

  Future<void> _showRetryAlert(var image) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text("Network issue\nPlease retry"),
          actions: <Widget>[
            // Container(
            //   padding: EdgeInsets.all(15),
            //   decoration:
            //       const BoxDecoration(color: CupertinoColors.activeBlue),
            //   child: InkWell(
            //       onTap: () {
            //         Navigator.of(context).pop();
            //         // submitCheckList();
            //       },
            //       child: const Text('Cancel',
            //           style: TextStyle(color: Colors.white))),
            // ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    checkInUser(image);
                    // submitCheckList();
                  },
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );
  }

  Future alertFailure(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: Text(msg == null ? 'Please try after sometime...' : msg),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future alert(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it'),
                onPressed: () {
                  Navigator.of(context).pop();
                  getPhoto(0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
    if (_croppedFile != null) {
      return _imageCard();
    } else {
      return const SizedBox(
        width: 120,
        height: 110,
        child: Icon(
          Icons.add_a_photo,
          size: 50,
        ),
      );
    }
  }

  Widget loginSuccess() {
    return Container(
      width: double.infinity,
      color: const Color(0x80000000),
      child: Container(
        margin:
            const EdgeInsets.only(left: 30, right: 30, top: 100, bottom: 100),
        color: Colors.white,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.beenhere_rounded,
              size: 100,
              color: Colors.green,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Text(
                'Successfully Checked In',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCard() {
    return Center(
      child: SizedBox(height: 110, width: 120, child: _image()),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
