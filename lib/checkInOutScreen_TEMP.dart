import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hng_flutter/widgets/camera_preview_widget.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hng_flutter/checkListItemScreen.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Controllers/checkInOutController.dart';
import 'common/constants.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/UserLocations.dart';
import 'PageHome.dart';
import 'main.dart';

class checkInOutScreen_TEMP extends StatefulWidget {
  final int checkInoutType;

  checkInOutScreen_TEMP(this.checkInoutType);

  @override
  State<checkInOutScreen_TEMP> createState() =>
      _checkInOutScreen_TEMPState(this.checkInoutType);
}

class _checkInOutScreen_TEMPState extends State<checkInOutScreen_TEMP> {
  int checkInoutType;

  String statusText = "Loading..";

  _checkInOutScreen_TEMPState(this.checkInoutType);

  XFile? photo;
  var _croppedFile;
  var deviceID = "Not known";
  var lat_ = 0.0, lng_ = 0.0;
  late CameraController controller;

  Geolocator geolocator = Geolocator();

  // Assuming you have a controller registered with GetX

  /*final checkInOutCtrl c = Get.put(checkInOutCtrl());

  final checkInOutCtrl controller = Get.find();*/

  Timer? timer;
  List<UserLocations> userLocations = [];

  // var status_ = 0;
  var imageType;

  bool showLocationList = false;
  UserLocations? selectedLocation;

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
    _picker = ImagePicker();
    // _determinePosition();
    // findUserGeoLoc();

    if (Platform.isAndroid) {
      getPhoto(0);
    }
    getLocation(0);
    fetchLocations(widget.checkInoutType);
    photo = null;
  }

  CameraController? camController;
  String imagePath = "";
  bool camVisible = false;

  Future<void> openCameraForAndroid() async {
    final cameras = await availableCameras();

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        camVisible = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  getPhoto(int firstTime) async {
    await Permission.camera.request();

    final ImagePicker picker = ImagePicker();

    if (Platform.isAndroid) {
      try {
        final cameras =
            await availableCameras(); //get list of available cameras
        final frontCam = cameras[1];

        camController = CameraController(frontCam, ResolutionPreset.medium);
        camController?.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            camVisible = true;
          });
        });
      } on CameraException catch (e) {
        if (kDebugMode) {
          print('Error in fetching the cameras: $e');
        }
      }
    } else {
      photo = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      _cropImage(photo, firstTime);
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
    print("overrideDISPOSE");
    timer?.cancel();
    camController?.dispose();
    super.dispose();
  }

  Future<Position?> getLocation(var firstime) async {
    try {
      setState(() {
        loading = true;
      });

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        lat_ = position.latitude;
        lng_ = position.longitude;
      });

      setState(() {
        loading = false;
      });

      return position;
    } catch (e) {
      Navigator.pop(context);
    }
    return null;
  }

  // var imagePath = '';

  @override
  Widget build(BuildContext context) {
    final CheckInOutController controller = Get.put(CheckInOutController());
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please complete process')));
          return Future.value(false);
        },
        child: SafeArea(
            child: Stack(
          children: [
            // Column(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(bottom: 20, top: 15),
            //       child: Stack(
            //         // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           Align(
            //             alignment: Alignment.topLeft,
            //             child: InkWell(
            //               onTap: () {
            //                 Navigator.pop(context);
            //               },
            //               child: const Padding(
            //                 padding: EdgeInsets.only(left: 15),
            //                 child: Icon(Icons.arrow_back),
            //               ),
            //             ),
            //           ),
            //           Align(
            //             alignment: Alignment.center,
            //             child: Padding(
            //                 padding: const EdgeInsets.only(left: 20),
            //                 child: RichText(
            //                   text: TextSpan(children: <TextSpan>[
            //                     TextSpan(
            //                         text: widget.checkInoutType == 0
            //                             ? 'Check In \n'
            //                             : 'CheckOut\n',
            //                         style: const TextStyle(
            //                             fontSize: 18, color: Colors.black)),
            //                     TextSpan(
            //                         text: timeMin,
            //                         style: const TextStyle(
            //                             fontSize: 17, color: Colors.red))
            //                   ]),
            //                 )),
            //           ),
            //         ],
            //       ),
            //     ),
            //
            //     SizedBox(
            //         height: 250,
            //         child: Stack(
            //           children: [
            //             SizedBox(
            //               height: 200,
            //               child: Stack(
            //                 children: [
            //                   /*Image.asset(
            //                       'assets/maps.jpeg',
            //                       fit: BoxFit.cover,
            //                       width: MediaQuery.of(context).size.width,
            //                     ),*/
            //                   Container(
            //                     color: Colors.black26,
            //                     child: GoogleMap(
            //                       initialCameraPosition: CameraPosition(
            //                         target: LatLng(lat_, lng_),
            //                         zoom: 14.4746,
            //                       ),
            //                       onMapCreated:
            //                           (GoogleMapController controller) {
            //                         // _controller.complete(controller);
            //                       },
            //                       zoomControlsEnabled: false,
            //                       myLocationEnabled: true,
            //                       markers: <Marker>{
            //                         Marker(
            //                           markerId: const MarkerId('1'),
            //                           position: LatLng(lat_, lng_),
            //                         ),
            //                       },
            //                     ),
            //                   ),
            //                   Align(
            //                     alignment: Alignment.bottomRight,
            //                     child: InkWell(
            //                       onTap: () {},
            //                       child: Container(
            //                         margin: const EdgeInsets.all(10),
            //                         padding: const EdgeInsets.all(5),
            //                         width: 80,
            //                         decoration: const BoxDecoration(
            //                           color: Colors.white,
            //                           borderRadius:
            //                               BorderRadius.all(Radius.circular(5)),
            //                         ),
            //                         child: const Row(
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.center,
            //                           children: [
            //                             Icon(
            //                               Icons.refresh,
            //                               size: 20,
            //                             ),
            //                             Text(
            //                               'Refresh',
            //                               style: TextStyle(fontSize: 12),
            //                             )
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             ),
            //             Align(
            //               alignment: Alignment.bottomCenter,
            //               child: InkWell(
            //                 onTap: () {
            //                   // findUserGeoLoc();
            //                   // getLocationStatus(1);
            //                   // getlocation(1);
            //                   setState(() {
            //                     showLocationList = true;
            //                   });
            //                   // findUserGeoLoc(1);
            //
            //                   getTime();
            //                 },
            //                 child: SizedBox(
            //                   height: 110,
            //                   width: 120,
            //                   child: Stack(
            //                     children: [
            //                       Container(
            //                         color: Colors.white,
            //                         child: _body(),
            //                       ),
            //                       const Align(
            //                         alignment: Alignment.topRight,
            //                         child: Padding(
            //                           padding: EdgeInsets.all(5.0),
            //                           child: Icon(
            //                             Icons.camera_alt,
            //                             color: Colors.white,
            //                           ),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         )),
            //     Center(
            //       child: Padding(
            //         padding:
            //             const EdgeInsets.only(top: 10, left: 15, right: 10),
            //         child: Column(
            //           children: [
            //             const Visibility(
            //               visible: false,
            //               child: Padding(
            //                 padding: EdgeInsets.only(top: 5, bottom: 5),
            //                 child: Text(
            //                   'User - Profile Matched',
            //                   style: TextStyle(
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 16,
            //                       color: Colors.green),
            //                 ),
            //               ),
            //             ),
            //             /* Text(
            //                     timeMin,
            //                     style: TextStyle(
            //                         fontWeight: FontWeight.bold,
            //                         color: Colors.green,
            //                         fontSize: 16),
            //                   ),*/
            //             const SizedBox(
            //               height: 10,
            //             ),
            //             const Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //               children: [
            //                 Column(
            //                   children: [
            //                     Text(
            //                       'Shift',
            //                       style: TextStyle(
            //                           fontSize: 16, color: Color(0xFF757575)),
            //                     ),
            //                     SizedBox(
            //                       height: 5,
            //                     ),
            //                     Text('General Shift',
            //                         style: TextStyle(
            //                           fontSize: 16,
            //                           color: Colors.black,
            //                         ))
            //                   ],
            //                 ),
            //                 Column(
            //                   children: [
            //                     Text('Time',
            //                         style: TextStyle(
            //                             fontSize: 16,
            //                             color: Color(0xFF757575))),
            //                     SizedBox(
            //                       height: 5,
            //                     ),
            //                     Text('09:30AM To 07:00PM',
            //                         style: TextStyle(
            //                           fontSize: 16,
            //                           color: Colors.black,
            //                         ))
            //                   ],
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(
            //               height: 7,
            //             ),
            //             const Divider(),
            //             const SizedBox(
            //               height: 7,
            //             ),
            //             Column(
            //               // mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 const Align(
            //                   alignment: Alignment.topLeft,
            //                   child: Text(
            //                     'Attendance Type',
            //                     style: TextStyle(
            //                         fontSize: 16,
            //                         color: Colors.black,
            //                         fontWeight: FontWeight.bold),
            //                   ),
            //                 ),
            //                 const SizedBox(
            //                   height: 7,
            //                 ),
            //                 Container(
            //                   margin: const EdgeInsets.only(bottom: 15, top: 7),
            //                   padding: const EdgeInsets.all(5),
            //                   decoration: BoxDecoration(
            //                       borderRadius: const BorderRadius.all(
            //                           Radius.circular(5)),
            //                       border: Border.all(color: Colors.grey)),
            //                   child: InkWell(
            //                     onTap: () {
            //                       // popupAttendence();
            //                       setState(() {
            //                         // showpopup = true;
            //                         showAtdncTypePopup = true;
            //                       });
            //                     },
            //                     child: Row(
            //                       children: [
            //                         Expanded(
            //                             child: Padding(
            //                           padding: const EdgeInsets.only(left: 5),
            //                           child: Text(dropdownText),
            //                         )),
            //                         const Icon(Icons.keyboard_arrow_down),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //
            //     // _body(),
            //   ],
            // ),
            // Visibility(
            //   visible: showAtdncTypePopup,
            //   child: Container(
            //     color: const Color(0x80000000),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Container(
            //           margin: const EdgeInsets.all(10),
            //           padding: const EdgeInsets.only(
            //               left: 15, top: 10, bottom: 15, right: 15),
            //           color: Colors.white,
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               const Align(
            //                   alignment: Alignment.center,
            //                   child: Padding(
            //                     padding: EdgeInsets.all(5),
            //                     child: Text(
            //                       'Select Attendance Type',
            //                       style: TextStyle(
            //                           fontSize: 18, color: Colors.black),
            //                     ),
            //                   )),
            //               const Divider(),
            //               ListView.separated(
            //                 shrinkWrap: true,
            //                 itemCount: typeAttencenceList.length,
            //                 itemBuilder: (context, pos) {
            //                   return Padding(
            //                     padding: const EdgeInsets.only(
            //                         top: 7, bottom: 7, left: 10),
            //                     child: InkWell(
            //                       onTap: () {
            //                         setState(() {
            //                           dropdownText = typeAttencenceList[pos];
            //                           showAtdncTypePopup = false;
            //                         });
            //                         print(typeAttencenceList[pos]);
            //                       },
            //                       child: Text(typeAttencenceList[pos],
            //                           style: const TextStyle(
            //                             fontSize: 18,
            //                             color: Colors.black87,
            //                           )),
            //                     ),
            //                   );
            //                 },
            //                 separatorBuilder:
            //                     (BuildContext context, int index) {
            //                   return const Divider();
            //                 },
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // Visibility(visible: successPopUp, child: loginSuccess()),

            // Visibility(
            //     visible: showProgress,
            //     child: Container(
            //       color: const Color(0x80000000),
            //       child: Center(
            //           child: Container(
            //               decoration: BoxDecoration(
            //                   color: Colors.white,
            //                   borderRadius: BorderRadius.circular(5)),
            //               padding: const EdgeInsets.all(20),
            //               height: 115,
            //               width: 150,
            //               child: const Column(
            //                 children: [
            //                   CircularProgressIndicator(),
            //                   Padding(
            //                     padding: EdgeInsets.all(8.0),
            //                     child: Text('Please wait..'),
            //                   )
            //                 ],
            //               ))),
            //     )),
            // Visibility(
            //     visible: loading,
            //     child: Container(
            //       color: const Color(0x80000000),
            //       child: Center(
            //           child: Container(
            //               decoration: BoxDecoration(
            //                   color: Colors.white,
            //                   borderRadius: BorderRadius.circular(5)),
            //               padding: const EdgeInsets.all(20),
            //               height: 115,
            //               width: 200,
            //               child: const Column(
            //                 children: [
            //                   CircularProgressIndicator(),
            //                   Padding(
            //                     padding: EdgeInsets.all(8.0),
            //                     child: Text('Getting location..'),
            //                   )
            //                 ],
            //               ))),
            //     )),
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  Text('Please wait..'),
                ],
              ),
            ),
            Visibility(
                visible: camController == null ? false : camVisible,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  // aspectRatio: controller!.value.aspectRatio,
                  child: Stack(
                    children: [
                      SizedBox(
                          // height: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          // width: double.infinity,
                          child: camController == null
                              ? const CircularProgressIndicator()
                              : CameraPreview(
                                  camController!,
                                )),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 22),
                                child: Text(
                                  statusText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 22, color: Colors.black),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: SizedBox(
                                  height: 15,
                                  width: 320,
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey,
                                    child: const Text(
                                      'Please wait',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.transparent),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          const Divider(
                            color: Colors.black,
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: userLocations.length,
                              // itemCount: 2,
                              itemBuilder: (context, index) {
                                final location = userLocations[index];
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
                                        'Location Code: ${location.locationCode} : ${location.latitude}-${location.longitude}',
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
        )),
      ),
    );
  }

  Future<void> _cropImage(var photo, int firstTime) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo,
        // sourcePath: Platform.isAndroid ? photo : photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        maxWidth: 1920,
        maxHeight: 1080,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
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
        startCountdownSubmitImage(firstTime);
      } else if (croppedFile == null) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
        });
      }
    }
  }

  void startCountdownSubmitImage(int isCheckIn) {
    if (!_isCountdownRunning) {
      _isCountdownRunning = true;
      const oneSec = Duration(seconds: 1);
      Timer.periodic(oneSec, (Timer timer) {
        setState(() {
          statusText =
              "Please wait $_countdown seconds"; // Update statusText with remaining seconds
          if (_countdown < 1) {
            timer.cancel();
            _isCountdownRunning = false;
            if (imageType != null) {
              checkInUser(imageEncoded, isCheckIn);
            }
          } else {
            _countdown -= 1;
          }
        });
      });
    }
  }

  bool showAtdncTypePopup = false;

  bool showProgress = false;

  checkInUser(var base64img, int isCheckIn) async {
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

      cloudstorageRef(imageEncoded, empCode);

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Attendance/AttendanceAdd',
      );

      var params;

      if (widget.checkInoutType == 0) {
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
          "check_in_store_geo_lat": lat_,
          "check_in_store_geo_long": lng_,
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
      } else if (widget.checkInoutType == 1) {
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
          "check_out_store_geo_lat": lat_,
          "check_out_store_geo_long": lng_,
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
        if (widget.checkInoutType == 1) {
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
          title: const Text('Alert!', textAlign: TextAlign.center),
          content:
              const Text(Constants.networkIssue, textAlign: TextAlign.center),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0))),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();
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
      builder: (BuildContext contextt) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!', textAlign: TextAlign.center),
            content: Text(msg, textAlign: TextAlign.center),
            actions: <Widget>[
              CustomElevatedButton(
                  text: 'Ok',
                  onPressed: () {
                    // Navigator.of(context).pop();
                    Navigator.pop(contextt);
                    Navigator.pop(context);
                  }),
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
            title: const Text('Alert!', textAlign: TextAlign.center),
            content: Text(msg, textAlign: TextAlign.center),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.beenhere_rounded,
              size: 100,
              color: Colors.green,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Text(
                widget.checkInoutType == 0
                    ? 'Successfully Checked In'
                    : 'Successfully Checked Out',
                style: const TextStyle(
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

  double maxDistance = 100;

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
        startCountdown();
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

  int _countdown = 5;
  bool _isCountdownRunning = false;

  void startCountdown() {
    if (!_isCountdownRunning) {
      _isCountdownRunning = true;
      const oneSec = Duration(seconds: 1);
      Timer.periodic(oneSec, (Timer timer) {
        setState(() {
          statusText = "Taking selfi in $_countdown";
          if (_countdown < 1) {
            timer.cancel();
            _isCountdownRunning = false;
            performFunctionAfterCountdown();
          } else {
            _countdown -= 1;
          }
        });
      });
    }
  }

  void performFunctionAfterCountdown() async {
    // Add your function here, which will be called after the countdown reaches 0 seconds.
    try {
      final image = await camController!.takePicture();
      setState(() {
        imagePath = image.path;
        camVisible = false;
      });
      _cropImage(image.path, 0);
    } catch (e) {
      print(e);
    }
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
            title: const Text('Alert!', textAlign: TextAlign.center),
            content: Text(
              msg,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              CustomElevatedButton(
                  text: 'Ok',
                  onPressed: () {
                    Navigator.of(context_).pop();
                    // Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  })
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
                  getPhoto(f);

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

          userLocations.clear();
          final List<UserLocations> locations =
              jsonList.map((json) => UserLocations.fromJson(json)).toList();
/*
        print("locations.length" + locations.length.toString());
*/

          userLocations = locations;

          if (userLocations.length == 1 || userLocations.isNotEmpty) {
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
