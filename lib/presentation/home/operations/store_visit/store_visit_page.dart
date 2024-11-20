import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hng_flutter/checkInOutScreenEmployee.dart';

import 'package:hng_flutter/checkListItemScreen.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/enums/store_visit_select_enum.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/UserLocations.dart';
import '../../../../data/opeartions/store_visit/issue_list.dart';
import '../../../../data/opeartions/store_visit/store_visit_locations_entity.dart';
import '../../../../helper/permission_helper.dart';
import '../../../../widgets/issue_list_widget.dart';

class StoreVisitPage extends StatefulWidget {
  final int checkInoutType;

  StoreVisitPage(this.checkInoutType, {super.key});

  @override
  State<StoreVisitPage> createState() => _StoreVisitPageState();
}

class _StoreVisitPageState extends State<StoreVisitPage> {
  // int checkInoutType;

  // _StoreVisitPageState();

  XFile? photo;
  var _croppedFile;
  var deviceID = "Not known";
  var lat_ = 0.0, lng_ = 0.0;
  late CameraController controller;

  Geolocator geolocator = Geolocator();
  List<IssuesList> selectedIssueList = [];

  TextEditingController scroreController = TextEditingController();

  // Assuming you have a controller registered with GetX

  /*final checkInOutCtrl c = Get.put(checkInOutCtrl());

  final checkInOutCtrl controller = Get.find();*/

  Timer? timer;
  List<StoreVisitLocationsEntity> userLocations = [];
  List<StoreVisitLocationsEntity> userLocationsTemp = [];
  List<IssuesList> issuesList = [];
  List<IssuesList> issuesListTemp = [];

  // var status_ = 0;
  var imageType;

  bool showLocationList = false;
  StoreVisitLocationsEntity? selectedLocation;

  var imageEncoded;
  bool successPopUp = false;
  bool loading = false;
  var typeAttencenceList = [
    'Present',
    'Out of Office meeting',
    'Client meeting',
    'Marked as present',
    'CheckOut'
  ];
  String dropdownText = "Present";

  ImagePicker? _picker;

  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handlePermission();
    _picker = ImagePicker();
    // _determinePosition();
    // findUserGeoLoc();

    getLocation(0);
    fetchLocations();
    getDeviceConfig();
    photo = null;
  }

  Future<void> handlePermission() async {
    final status = await PermissionHelper.requestLocationPermission();

    if (status.isGranted) {
      // Permission granted, proceed with your logic

    } else if (status.isPermanentlyDenied ||
        status.isDenied ||
        status.isRestricted) {
      const dynamicMessage =
          'Please allow location permission for Location Check process';
      PermissionHelper.showPermissionAlert(context, dynamicMessage);
    }
  }


/*
  Future<void> checkLocationInRadius(double userLatitude, double userLongitude) async {
    LatLng userLocation = LatLng(userLatitude, userLongitude);
    LatLng targetLocation = LatLng(targetLatitude, targetLongitude); // Provide the target location coordinates here

    double distance = SphericalUtil.computeDistanceBetween(userLocation, targetLocation);

    if (distance <= radius) {
      print('Location is within the radius');
    } else {
      print('Location is outside of the radius');
    }
  }*/

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
    // timer?.cancel();
    super.dispose();
  }

  Future<Position> getLocation(var firsTime) async {
    try{
      setState(() {
        loading = true;
      });

      Position position = await   Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        lat_ = position.latitude;
        lng_ = position.longitude;
      });

      setState(() {
        loading = false;
      });
      return position;

    }catch(e){
      setState(() {
        loading = false;
      });
      showSimpleDialog(title: "Alert!", msg: "Please enable Location permissions\n$e");
      rethrow ;
    }


  }

  // var imagePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Store Visit',
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Visibility(
            visible: userLocationsTemp.isEmpty ? false : true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Date: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Expanded(child: Text(formatDate(DateTime.now()))),
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Store Name: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Expanded(
                                child: Text(userLocationsTemp.isEmpty
                                    ? ''
                                    : selectedLocation!.locationName)),
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: scroreController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(fontSize: 14),
                              // isCollapsed: true,
                              border: OutlineInputBorder(),
                              labelText: 'Enter score 0 to 5',
                              hintText: 'Enter score 0 to 5',
                            ),
                            onChanged: (value) {
                              final valuee = double.parse(value);
                              // final valuee = int.parse(value);
                              if (valuee != 0 && valuee > 5) {
                                Fluttertoast.showToast(
                                    msg: 'Enter values between 0 to 5',
                                    gravity: ToastGravity.TOP);
                                scroreController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),

                  // const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Issues List',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final issueList = issuesList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(issueList.valueName,maxLines: 2,)),
                              SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                    value: selectedIssueList.contains(issueList)
                                        ? true
                                        : false,
                                    onChanged: (value) {
                                      if (selectedIssueList
                                          .contains(issueList)) {
                                        setState(() {
                                          selectedIssueList.remove(issueList);
                                        });
                                      } else {
                                        setState(() {
                                          selectedIssueList.add(issueList);
                                        });
                                      }
                                    }),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: issuesList.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Divider(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: () {
                    if (scroreController.text.isEmpty) {
                      alert('Please Enter Score');
                    } else {
                      showCheckoutAlert(context);
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16),
                  )),
            ),
          ),
          Visibility(
              visible: showLocationList,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
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
                          padding: const EdgeInsets.only(top: 15, bottom: 10),
                          child: Text(
                            'Select Store',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                        Expanded(
                          child: ListView.separated(
                              itemCount: userLocations.length,
                              itemBuilder: (context, index) {
                                final location = userLocations[index];
                                return InkWell(
                                  onTap: () {
                                    if (location.visitstatus == "Pending") {

                                      checkDistance_(
                                          double.parse(location.latitude),
                                          double.parse(location.longitude),
                                          StoreVisitEnum.visited);

                                      setState(() {
                                        // showAtdncTypePopup = true;
                                        showLocationList = false;
                                        selectedLocation = location;
                                        userLocationsTemp.add(location);
                                      });
                                    } else {
                                      checkDistance_(
                                          double.parse(location.latitude),
                                          double.parse(location.longitude),
                                          StoreVisitEnum.notVisited);

                                      setState(() {
                                        // showAtdncTypePopup = true;
                                        showLocationList = false;
                                        selectedLocation = location;
                                        userLocationsTemp.add(location);
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                location.locationName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.5),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                'Location Code- ${location.locationCode}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              location.visitstatus == "Pending",
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: const Text(
                                              'Pending',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                          size: 15,
                                        )
                                      ],
                                    ),
                                  ),
                                  /*  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${location.locationName} - Location Code: ${location.locationCode}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5),
                                      ),
                                      Text(
                                        location.latitude.isEmpty ||
                                                location.longitude.isEmpty
                                            ? 'Map Points: '
                                            : 'Map Points: ${location.latitude},${location.longitude}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),*/
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                final location = userLocations[index];

                                return Visibility(
                                    visible: location.visitstatus == "Pending",
                                    child: const Divider());
                              }),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
              )),
          Visibility(
              visible: showProgress,
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
                        width: 200,
                        child: const Column(
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Fetching location..'),
                            )
                          ],
                        ))),
              )),
        ],
      )),
    );
  }

  bool showAtdncTypePopup = false;

  bool showProgress = false;

  Future alertFailure(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!', textAlign: TextAlign.center),
            content: Text(msg == null ? 'Please try after sometime...' : msg,
                textAlign: TextAlign.center),
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
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Alert!', textAlign: TextAlign.center),
          content: Text(msg, textAlign: TextAlign.center),
          actions: <Widget>[
            Center(
              child: CustomElevatedButton(
                  text: 'Got it',
                  onPressed: () {
                    Navigator.of(contextt).pop();
                    Navigator.of(context).pop();

                  }),
            ),
          ],
        );
      },
    );
  }

  Future alertSuccess(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Alert!', textAlign: TextAlign.center),
          content: Text(msg, textAlign: TextAlign.center),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(contextt).pop();
                Navigator.of(context).pop();

                // getPhoto(0);
              },
            ),
          ],
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
            title: const Text('Alert!', textAlign: TextAlign.center),
            content: Text(msg, textAlign: TextAlign.center),
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
                  Navigator.of(context).pop();
                  // getLocationStatus(f);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showCheckoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('You are about to checkout from the store'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform checkout operation here
                Navigator.of(context).pop();
                sendData(); // Close the dialog
              },
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  double maxDistance = 150; // Maximum distance in meters

  var lat, lng;

  Future<void> checkDistance_(
      double userLatitude, double userLongitude, var storevisit) async {

    try{
      setState(() {
        loading = true;
      });
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double currentLatitude = position.latitude;
      double currentLongitude = position.longitude;

      double distance = Geolocator.distanceBetween(
        currentLatitude,
        currentLongitude,
        // currentLatitude,
        // currentLongitude,
        userLatitude,
        userLongitude,
      );

      /*double distanceInMeters = Geolocator.distanceBetween(
        userLatitude, userLatitude, position.latitude, position.longitude);*/
      var mts = distance.toString().split('.');
      print(distance);
      var meters = mts[0];

      if (double.parse(meters) <= maxDistance) {
        setState(() {
          loading = false;
          lat = currentLatitude;
          lng = currentLongitude;
        });
        print("storevisit->$storevisit");
        if (storevisit == StoreVisitEnum.notVisited) {
          callStoreVisitCheckIn(currentLatitude, currentLongitude);
        }
        /* successAlertGetPhoto('You are near to store\n$meters meters ', firstime,
          position.latitude, position.longitude);*/
        Fluttertoast.showToast(msg: 'You are near to store\n$meters meters ');
      } else {
        setState(() {
          loading = false;
        });
        alertGetPhoto('You are outside of store\n$meters meters far.');
        Fluttertoast.showToast(msg: '${position.latitude} ${position.longitude}');
      }
    }catch(e){
      Navigator.pop(context);
    }



  }

  Future alertGetPhoto(String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context_) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!', textAlign: TextAlign.center),
            content: Text(
              msg,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              /* TextButton(
                child: const Text('Re-Check'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  // getPhoto(f);
                },
              ),*/
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  // Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // getPhoto(f);
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

  Future successAlertGetPhoto(String msg, int f, var lat, var lng) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context_) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text(
              'Alert!',
              textAlign: TextAlign.center,
            ),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: const Text('Proceed'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  /* setState(() {
                    showAtdncTypePopup = true;
                  });*/
                },
              ),
              /*  TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context_).pop();
                  // Navigator.of(context).pop();
                  // getPhoto(f);
                },
              ),*/
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

  Future<void> cloudstorageRef(var img, var empcode) async {
    final prefs = await SharedPreferences.getInstance();
    String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    var userId = prefs.getString("userCode");
    String empCode = empcode;
    ;
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();

    var locationCode = prefs.getString('locationCode') ?? '106';

    final imagesRef = storageRef.child("$locationCode/attendance/$empCode.jpg");

    try {
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
      if (kDebugMode) {
        print('FirebaseException');
        print(e.message);
      }
    }
  }

  String pendingstatus = '';

  Future<List<StoreVisitLocationsEntity>?> fetchLocations() async {
    try {
      print("fetchLocations");

      setState(() {
        loading = true;
      });

      final pref = await SharedPreferences.getInstance();
      var userid = pref.getString("userCode");
      final url =
          '${Constants.apiHttpsUrl}/Login/Storevisitlocations/$userid'; // Replace with your API endpoint URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responses = jsonDecode(response.body);
        print("Url->$url $responses");

        if (responses['statusCode'] == "200" &&
            responses['status'] == "success") {
          setState(() {
            pendingstatus = responses["pendingstatus"];
          });
          final List<dynamic> jsonList = responses['locationlist'];
          final List<dynamic> prameterlist = responses['prameterlist'];

          userLocations.clear();
          issuesList.clear();
          final List<StoreVisitLocationsEntity> locations = jsonList
              .map((json) => StoreVisitLocationsEntity.fromJson(json))
              .toList();

          final List<IssuesList> prameterlist_ =
              prameterlist.map((json) => IssuesList.fromJson(json)).toList();
/*
        print("locations.length" + locations.length.toString());
*/

          issuesList = prameterlist_;
          userLocations = locations;
          if (userLocations.isNotEmpty) {
            if (pendingstatus == "Pending") {
              for (var details in userLocations) {
                if (details.visitstatus == "Pending") {
                  userLocationsTemp.add(details);
                }
              }

              checkDistance_(
                  double.parse(userLocationsTemp[0].latitude),
                  double.parse(userLocationsTemp[0].longitude),
                  StoreVisitEnum.visited);

              setState(() {
                // showAtdncTypePopup = true;
                showLocationList = false;
                selectedLocation = userLocationsTemp[0];
                // userLocationsTemp.add(userLocations[0]);
                loading = false;
              });
            } else {
              userLocations = locations;

              setState(() {
                showLocationList = true;
                loading = false;
              });
            }
          }

          setState(() {
            loading = false;
          });

          return locations;
        } else {
          setState(() {
            loading = false;
          });
          throw Exception('Failed to fetch locations');
        }
      } else {
        setState(() {
          loading = false;
        });
        throw Exception('Failed to fetch locations');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      alert(Constants.networkIssue);
      return null;
    }
  }

  String formatDate(DateTime dateTime) {
    String day = DateFormat('d').format(dateTime);
    String month = DateFormat('MMMM').format(dateTime);
    String year = DateFormat('y').format(dateTime);

    // Add suffix to the day (e.g., 1st, 2nd, 3rd, 4th, etc.)
    String daySuffix = getDaySuffix(int.parse(day));

    return '$day$daySuffix $month $year';
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  sendData() async {
    try {
      setState(() {
        showProgress = true;
      });

      final prefs = await SharedPreferences.getInstance();

      String dateForEmpCode_ =
          DateFormat("yyyyMMddhhmmssS").format(DateTime.now());

      var userId = prefs.getString("userCode");

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/StoreVisit',
      );

      List<Map<String, String>> jsonParamsList = [];
      if (userLocationsTemp.isNotEmpty) {
        jsonParamsList = selectedIssueList.map((issue) {
          return {
            'rating_reason': issue.value,
          };
        }).toList();
      }
      // var

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "location_code": selectedLocation!.locationCode,
              "user_code": userId,
              "store_rating": scroreController.text.toString(),
              "remarks": "",
              "latitude": "$lat",
              "longitude": "$lng",
              "storevistlist": jsonParamsList,
            }),
          )
          .timeout(const Duration(seconds: 10));

      var respo = jsonDecode(response.body);
      print("Response->>>>$respo");
      print("Response->>>>${{
        "location_code": selectedLocation!.locationCode,
        "user_code": userId,
        "store_rating": scroreController.text.toString(),
        "remarks": "",
        "latitude": "$lat",
        "longitude": "$lng",
        "storevistlist": jsonParamsList,
      }}");

      if (response.statusCode == 200) {
        if (respo['statusCode'] == '200') {
          setState(() {
            loading = false;
            showProgress = false;
          });
          Fluttertoast.showToast(msg: respo['message']);
          alertSuccess(respo['message']);
          scroreController.clear();
          selectedIssueList.clear();
        } else {

          Fluttertoast.showToast(msg: respo['message']);
          showSimpleDialog( title: 'Alert!', msg: '${respo['message']}\n${response.statusCode}');

          setState(() {
            loading = false;
            showProgress = false;
          });
          scroreController.clear();
          selectedIssueList.clear();
        }
      } else {
        showSimpleDialog( title: 'Alert!', msg: 'Something went wrong\n${response.statusCode}');

        setState(() {
          loading = false;
          showProgress = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;

        showProgress = false;
      });
      Fluttertoast.showToast(msg: "Network issue occurred\nPlease try again");
      showSimpleDialog( title: 'Alert!', msg: 'Something went wrong\n$e');

      scroreController.clear();
      selectedIssueList.clear();
    }
  }

  Future<void> callStoreVisitCheckIn(
      double currentLatitude, double currentLongitude) async {
    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userCode");

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/StoreVisitcheckin',
      );

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "location_code": selectedLocation!.locationCode,
              "user_code": "$userId",
              "latitude": "$currentLatitude",
              "longitude": "$currentLongitude",
            }),
          )
          .timeout(const Duration(seconds: 5));

      var params = {
        "location_code": selectedLocation!.locationCode,
        "user_code": userId,
        "latitude": currentLatitude,
        "longitude": currentLongitude,
      };
      var respo = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (respo['statusCode'] == '200') {
          setState(() {
            loading = false;
            showProgress = false;
          });
          Fluttertoast.showToast(msg: respo['message']);
          // alert(respo['message']);
        } else {
          Fluttertoast.showToast(msg: respo['message']);
          showSimpleDialog( title: 'Alert!', msg: '${respo['message']}');

          setState(() {
            loading = false;
            showProgress = false;
          });
        }
      } else {
        alert("Something went wrong\nError Code ${response.statusCode}");

        setState(() {
          loading = false;
          showProgress = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("callStoreVisitCheckIn Error->>$e");
      }
      Fluttertoast.showToast(msg: "Network issue occurred\nPlease try again");
      alertGetPhoto("Network issue occurred\nPlease try again");
      setState(() {
        loading = false;
        showProgress = false;
      });
    }
  }
}
