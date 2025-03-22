import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

// import 'package:geofence_flutter/geofence_flutter.dart';
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
import 'data/UserLocations.dart';
import 'main.dart';

class checkInOutScreenIOS extends StatefulWidget {
  final int checkInOutType;

  const checkInOutScreenIOS(this.checkInOutType, {Key? key}) : super(key: key);

  @override
  State<checkInOutScreenIOS> createState() => _checkInOutScreenIOSState();
}

class _checkInOutScreenIOSState extends State<checkInOutScreenIOS> {
  XFile? photo;
  var _croppedFile;
  var deviceID = "Not known";
  var lat, lng;

  Geolocator geolocator = Geolocator();

  TextEditingController searchController = TextEditingController();
  List<UserLocations> filteredLocations = [];

  Timer? timer;
  var status_;
  var imageEncoded;
  bool successPopUp = false;
  bool loading = false;
  var typeAttendanceList = ['Present', 'CheckOut'];
  String dropdownText = "Present";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocations(0);

    getLocation();
    getTime();

    /*Timer timer =
        Timer.periodic(Duration(seconds: 15), (Timer t) => getlocation());*/
    photo = null;
  }

  getPhoto(int firstTime) async {
    final ImagePicker picker = ImagePicker();
    // Request camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        Get.defaultDialog(
          middleText: 'Please grant camera permission for CheckIn/CheckOut',
        );
        print('Camera permission denied');
        return;
      }
    }

    try {
      photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      if (photo != null) {
        _cropImage(photo, firstTime);
      } else {
        print('No photo selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
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
    imageEncoded = "";

    super.dispose();
  }

  void filterSearch(String query) {
    setState(() {
      filteredLocations = userLocations
          .where((location) =>
              location.locationName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              location.locationCode.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> getLocation() async {
    // try{}

   var status =  await Permission.location.request();

   if(status.isGranted){
     Position position = await Geolocator.getCurrentPosition(
         desiredAccuracy: LocationAccuracy.high);
     print(position.latitude);
     print(position.longitude);

     setState(() {
       lat = position.latitude;
       lng = position.longitude;
     });
   }
   else if (status.isDenied) {
     print("Location permission denied.");
     Get.defaultDialog(middleText: "Location permission denied.");
   } else if (status.isPermanentlyDenied) {
     print("Location permission permanently denied. Open settings to enable.");
     // await openAppSettings();
     Get.defaultDialog(middleText: "Location permission permanently denied. Open settings to enable.");

   }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: Stack(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Check In Time '),
                            Text(timeMin, style: const TextStyle(
                                fontSize: 17, color: Colors.green)),
                          ],
                        ),
                      ),
                   /*   Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: RichText(
                              text: TextSpan(children: <TextSpan>[
                                const TextSpan(
                                    text: 'Check In Time ',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black)),
                                TextSpan(
                                    text: timeMin,
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.green))
                              ]),
                            )),
                      ),*/
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
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
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
                        Visibility(
                          visible: successPopUp,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              'User - Profile Matched',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green),
                            ),
                          ),
                        ),
                        /* Text(
                          timeMin,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16),
                        ),*/
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
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
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 7,
                        ),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Attendance Type',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 15, top: 7),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: Border.all(color: Colors.grey)),
                              child: InkWell(
                                onTap: () {
                                  // popupAttendence();
                                  setState(() {
                                    // showpopup = true;
                                    // showAtdncTypePopup = true;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(dropdownText),
                                    )),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                  if (imageEncoded.toString().isNotEmpty ||
                      imageEncoded != null) {
                    checkInUser(imageEncoded);
                  } else {
                    Get.defaultDialog(
                      middleText: 'Please take selfi.',
                    );
                  }
                },
                child: Container(
                  height: 50,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      widget.checkInOutType == 0 ? 'Check In' : 'CheckOut',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: showAtdncTypePopup,
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
                                  'Select Attendance Type',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                              )),
                          const Divider(),
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: typeAttendanceList.length,
                            itemBuilder: (context, pos) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 7, bottom: 7, left: 10),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      dropdownText = typeAttendanceList[pos];
                                      showAtdncTypePopup = false;
                                    });
                                    print(typeAttendanceList[pos]);
                                  },
                                  child: Text(typeAttendanceList[pos],
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
                visible: showLocationList,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10)),
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Container(
                      // color: Colors.white,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),

                      // width: MediaQuery.of(context).size.width / 2,
                      height: userLocations.length > 4
                          ? MediaQuery.of(context).size.height
                          : MediaQuery.of(context).size.height / 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              'Select Location',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          // const Divider(
                          //   color: Colors.black,
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(fontSize: 15),
                                suffixIcon: Icon(Icons.search),
                              ),
                              onChanged: filterSearch,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          Expanded(
                            child: ListView.separated(
                              itemCount: filteredLocations.length,
                              // itemCount: 2,
                              itemBuilder: (context, index) {
                                final location = filteredLocations[index];
                                return InkWell(
                                  onTap: () async {
                                    // controller.showLocationList(!controller.showLocationList.value);

                                    try {
                                      setState(() {
                                        // showAtdncTypePopup = true;
                                        showLocationList = false;
                                        selectedLocation = location;
                                      });
                                      await checkDistance_(
                                          double.parse(location.latitude),
                                          double.parse(location.longitude),
                                          0);
                                    } catch (e) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: ListTile(
                                    title: Text(
                                      location.locationName,
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        'Location Code: ${location.locationCode} ${location.latitude}-${location.longitude}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 15,
                                    ),
                                  ),
                                  /*       Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Icon(Icons.location_pin),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child:
                                                  Text(location.locationName),
                                            ),
                                            Text(
                                                ' - Location Code: ${location.locationCode}')
                                          ],
                                        ),
                                        Text(location.latitude.isEmpty ||
                                                location.longitude.isEmpty
                                            ? 'Map Points: '
                                            : 'Map Points: ${location.latitude},${location.longitude}'),
                                      ],
                                    ),
                                  ),*/
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(),
                            ),
                          ),
                          /*   ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              // Navigator.pop(context);
                              setState(() {
                                showLocationList = false;
                              });
                            },
                            child: const Text('Cancel'),
                          ),*/
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  var imageType;

  Future<void> _cropImage(var photo, int firstTime) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 40,
        //1280 x 720//1920 x 1080
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

  checkInUser(var base64img) async {
    try {
      setState(() {
        showProgress = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var deviceid = prefs.getString("deviceid");

      String datetime_ =
          DateFormat("yyyy-MM-dd'T'hh:mm:ss.S'Z'").format(DateTime.now());

      String dateForEmpCode_ =
          DateFormat("yyyyMMddhhmmssS").format(DateTime.now());

      var userId = prefs.getString("userCode");
      String empCode = "EMP$userId$dateForEmpCode_";

      // cloudstorageRef(imageEncoded, empCode);

      var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWA_GROOMING_API/api/Attendance/AttendanceAdd',
      );

      var params;

      if (widget.checkInOutType == 0) {
        params = {
          "attendance_date": "$datetime_",
          //remove in production
          "attendance_store_code": selectedLocation!.locationCode,
          // "attendance_store_code": '106',
          "attendance_sto_geo_lat": selectedLocation!.latitude,
          "attendance_sto_geo_long": selectedLocation!.longitude,
          "employee_code": prefs.getString('userCode') ?? '105060',
          "check_date_time_in": "$datetime_",
          "check_in_selfie_url": "",
          "check_date_time_out": "",
          "check_out_selfie_url": "",
          "check_in_store_geo_lat": currentLatitude,
          "check_in_store_geo_long": currentLongitude,
          "check_out_store_geo_long": "0",
          "check_out_store_geo_lat": "0",

          "check_out_exception_status": 0,
          "created_by": "$userId",
          "created_datetime": "$datetime_",
          "attendance_current_status": "Present",
          "roaster_id": "10",
          "check_in_exception_status": "0",
          "modiified_datetime": "$datetime_",
          // "modiified_datetime": "2023-02-20",
          "modified_by": "$userId",
          // "check_in_Image_FileName": "EMPCD106" + datetime_,
          "check_in_Image_FileName": "$empCode",
          "check_in_Image_FileName_Format": "jpg",
          "check_out_image": "",
          "check_out_image_FileName": "",
          "check_out_Image_FileName_Format": "",
          "check_in_Image": "",
          // "deviceid": "55ec53ccf5a40648",
          "deviceid": deviceid,
        };
      } else if (widget.checkInOutType == 1) {
        params = {
          "attendance_date": "$datetime_",
          "attendance_store_code": selectedLocation!.locationCode,
          "attendance_sto_geo_lat": selectedLocation!.latitude,
          "attendance_sto_geo_long": selectedLocation!.longitude,
          "employee_code": prefs.getString('userCode'),
          "check_date_time_in": "",
          "check_in_selfie_url": "",
          "check_date_time_out": "$datetime_",
          "check_out_selfie_url": "",
          "check_in_store_geo_lat": "0",
          "check_in_store_geo_long": "0",
          "check_in_exception_status": "0",
          "check_in_Image": "",
          "check_in_Image_FileName": "",
          "check_in_Image_FileName_Format": "",
          "check_out_store_geo_lat": currentLatitude,
          "check_out_store_geo_long": currentLongitude,
          "check_out_exception_status": 0,
          "check_out_image_FileName": "$empCode",
          "check_out_Image_FileName_Format": "jpg",
          "created_by": "$userId",
          "created_datetime": "$datetime_",
          "attendance_current_status": "CheckedOut",
          "roaster_id": "10",
          "modiified_datetime": "$datetime_",
          "modified_by": "$userId",
          "check_out_image": "",
          // "deviceid": 55e"c53ccf5a40648",
          "deviceid": deviceid,
          // "deviceid": "55ec53ccf5a40648",
        };
      }
      // var

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(seconds: 20));

      var respo = jsonDecode(response.body);

      print(respo['statusCode']);
      if (respo['statusCode'] == '200') {
        setState(() {
          loading = false;
          showProgress = false;
          showAtdncTypePopup = false;
          successPopUp = true;
          imageEncoded = null;
        });
        if (widget.checkInOutType == 1) {
          logoutUser(context);
          // Navigator.pop(context, widget.checkInoutType == 0 ? 0 : 1);
          // Navigator.pop(context);
        } else {
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pop(context);
            // Navigator.pop(context, widget.checkInoutType == 0 ? 0 : 1);
          });
        }
      } else {
        setState(() {
          loading = false;
          showAtdncTypePopup = false;
          showProgress = false;
          successPopUp = false;
          imageEncoded = null;
        });

        var msg = respo['message'] ?? 'Please try after sometime.';
        alertFailure(msg);
      }
    } catch (e) {
      setState(() {
        loading = false;
        imageEncoded = null;
        imageEncoded = "";
        showAtdncTypePopup = false;
        showProgress = false;
      });
      _showRetryAlert(base64img);
    }
  }

  void logoutUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Exit App',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: const Text('CheckOut success'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                Fluttertoast.showToast(
                    msg: "Please wait while logging out user");
                final prefs = await SharedPreferences.getInstance();
                prefs.clear();
                await SystemChannels.platform
                    .invokeMethod('SystemNavigator.pop');
                if (Platform.isIOS) {
                  exit(0);
                } else {
                  await SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
                }
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRetryAlert(var image) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text('Retry now?'),
          actions: <Widget>[
            Container(
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),
            Container(
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

  double maxDistance = 100;

  double currentLatitude = 0.0;
  double currentLongitude = 0.0;

  Future<void> checkDistance_(
      double userLatitude, double userLongitude, var firstTime) async {
    try {
      setState(() {
        loading = true;
        statusText = "Calculating distance..";
      });
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      getTime();

      double currentLatitude = position.latitude;
      double currentLongitude = position.longitude;

      double distance = Geolocator.distanceBetween(
        currentLatitude,
        currentLongitude,
        userLatitude,
        userLongitude,
      );

      var mts = distance.toString().split('.');
      var meters = mts[0];

      if (double.parse(meters) <= maxDistance) {
        setState(() {
          loading = false;
          statusText = "You are near to store..";
        });
        getPhoto(firstTime);
      } else {
        setState(() {
          loading = false;
          statusText = "You are outside of store\n$meters meters far.";
        });
        Fluttertoast.showToast(
            msg: 'You are outside of store\n$meters meters far.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
    }
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
                    fontSize: 20),
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getlocStatus(int firstTime) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('status') == 1) {
      getPhoto(firstTime);
    } else {
      Get.defaultDialog(middleText: 'You are outside of store');
    }
  }

  Future<void> getDeviceConfig() async {
    print("getDeviceConfig");

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      print("getDeviceConfig");
      print('Android $release (SDK $sdkInt), $manufacturer $model');
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    }
  }

  Future<void> cloudstorageRef(var img, var empcode) async {
    final prefs = await SharedPreferences.getInstance();
    String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    var userId = prefs.getString("userCode");
    String empCode = empcode;

    // final storageRef = FirebaseStorage.instance.ref();
    // FirebaseStorage storageRefd = FirebaseStorage.instanceFor(bucket: "gs://hgstores_rwa_dilo");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();

    var locationCode = prefs.getString('locationCode') ?? '106';

    final imagesRef = storageRef.child("$locationCode/attendance/$empCode.jpg");

    // String dataUrl = base64img;
// Create a reference to "mountains.jpg"
    final mountainsRef = imagesRef.child("$empCode.jpg");

// Create a reference to 'images/mountains.jpg'
    try {
      // await imagesRef.putString(img, format: PutStringFormat.dataUrl);
      await imagesRef
          .putString(img,
              format: PutStringFormat.base64,
              metadata: SettableMetadata(contentType: 'image/png'))
          .then((p0) => print('uploaded to firebase storage successfully'));
      // String downloadUrl = (await FirebaseStorage.instance.ref().getDownloadURL()).toString();
      String downloadUrl = (await FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref())
          .toString();

      // String downloadUrl = (await FirebaseStorage.instanceFor(bucket: "gs://hng-offline-marketing.appspot.com").ref().getDownloadURL()).toString();
      print(downloadUrl);
    } on FirebaseException catch (e) {
      print(e.message);
      // ...
    }
  }

  String statusText = "Loading..";
  List<UserLocations> userLocations = [];
  bool showLocationList = false;
  UserLocations? selectedLocation;

  Future<List<UserLocations>?> fetchLocations(int checkInoutType) async {
    try {
      setState(() {
        loading = true;
        statusText = "Fetching Locations..";
      });

      final pref = await SharedPreferences.getInstance();
      var userid = pref.getString("userCode");
      final url = '${Constants.apiHttpsUrl}/Login/GetLocation/$userid';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var responses = jsonDecode(response.body);

        if (responses['statusCode'] == "200" &&
            responses['status'] == "success") {
          final List<dynamic> jsonList = responses['locations'];

          if (jsonList.isNotEmpty) {
            userLocations.clear();
            filteredLocations.clear;

            final List<UserLocations> locations =
                jsonList.map((json) => UserLocations.fromJson(json)).toList();
/*
        print("locations.length" + locations.length.toString());
*/

            userLocations = locations;
            filteredLocations = userLocations;

            if (filteredLocations.length == 1 || filteredLocations.isNotEmpty) {
              setState(() {
                showLocationList = true;
                loading = false;
              });
              // print("$userLocations[0].latitude");
            }

            setState(() {
              loading = false;
              // selectedLocation = userLocations[0];
            });

            return locations;
          } else {
            setState(() {
              loading = false;
            });
            Get.defaultDialog(
              title: "Alert!",
              content: const Text('Locations list is empty'),
            );
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pop(context);
            });
          }
        } else {
          setState(() {
            loading = false;
            statusText =
                "Fetching location error..\nStatus Code: ${responses['statusCode']}";
          });
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pop(context);
          });

          throw Exception('Failed to fetch locations');
        }
      } else {
        setState(() {
          loading = false;
          statusText =
              "Fetching location error..\nStatus Code: ${response.statusCode}";
        });
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
        });
        throw Exception('Failed to fetch locations');
      }
    } catch (e) {
      setState(() {
        loading = false;
        statusText = Constants.networkIssue;
      });
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    }
    return null;
  }
}
