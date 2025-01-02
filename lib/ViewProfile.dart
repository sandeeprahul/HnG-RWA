import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/widgets/image_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key? key}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  bool changePasswordPopup = false;

  bool showpass = false;
  bool showpass_confim = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserType();
    getProfileImage();
    _getId();
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



  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    if (Camcontroller != null) {
      Camcontroller!.dispose();
    }
    super.dispose();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              // mainAxisSize:   MainAxisSize.min           ,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context, true);
                          },
                          child: const Icon(Icons.arrow_back)),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "Profile",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // getPhoto();
                          if (profile_image_url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ImagePreview(profile_image_url, '-1'),
                                  fullscreenDialog: true),
                            );
                          }
                        },
                        child: profile_image_url.isEmpty
                            ?  CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 40,
                                child: Stack(
                                  children: [
                                    const Center(child: Icon(Icons.person)),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          icon: const Icon(
                                            size: 14,
                                            Icons.edit,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            getPhoto();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Hero(
                                tag: 'userImage',
                                child: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  radius: 58,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 56,
                                          backgroundImage:
                                              NetworkImage(profile_image_url),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              icon: const Icon(
                                                size: 14,
                                                Icons.edit,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                getPhoto();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Visibility(
                        visible: false,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Take photo'),
                        ),
                      )
                    ],
                  ),
                ),
                // const Divider(),
                Container(
                  padding: const EdgeInsets.all(25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 10, left: 25, right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 3,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  designation,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 3,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'EMP ID: $userCode',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 3,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Location: $location_name',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const Divider(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18))),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 15),
                              child: Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Branch Name',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.white,
                                    height: 3,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      location_name,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 15),
                              child: Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Reporting Manager',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      reporting_manager_name,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            InkWell(
                              onTap: () {
                                // alertMobileNumber();
                                setState(() {
                                  changePasswordPopup = true;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 25, right: 15),
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          'Change Your Password',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Version ${Constants.appVersion}\nId:$deviceId',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10,),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 30,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          18.0), // Set the border radius here
                                    ),
                                  ),
                                  onPressed: () {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Please wait while logging out user");

                                    logoutUser(context);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                                _cropImage(image.path);
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 35,
                                child: Icon(
                                  Icons.camera,
                                  size: 35,
                                ),
                              ),
                              /*ElevatedButton(
                                      style: ButtonStyle(
                                      ),
                                        onPressed: () {},
                                        child: Text(
                                            'Take Photo'))*/
                              /* CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 35,
                                  ),*/
                            ),
                          ))
                    ],
                  ),
                )),
            Visibility(
              visible: changePasswordPopup,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    changePasswordPopup = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            // textAlign: TextAlign.center,
                            controller: _passwordController,
                            obscureText: showpass ? true : false,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (showpass) {
                                    setState(() {
                                      showpass = false;
                                    });
                                  } else {
                                    setState(() {
                                      showpass = true;
                                    });
                                  }
                                },
                                icon: showpass
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _confirmController,
                            obscureText: showpass_confim ? true : false,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (showpass_confim) {
                                    setState(() {
                                      showpass_confim = false;
                                    });
                                  } else {
                                    setState(() {
                                      showpass_confim = true;
                                    });
                                  }
                                },
                                icon: showpass_confim
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)
                              )
                                // backgroundColor: Colors.b,
                                ),
                            onPressed: () {
                              checkOtp();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
          ],
        )));
  }

  var userCode = "";

  var userName = "";
  var designation = "";
  var base_location_name = "";
  var reporting_manager_name = "";
  var location_name = "";

  // var userName = "";

  var profile_image_url = "";

  Future<void> getuserType() async {
    final prefs = await SharedPreferences.getInstance();
    // var user = prefs.getString('userType');

    // userName = prefs.getString('user_name')!;
    setState(() {
      userCode = prefs.getString('userCode')!;
      userName = prefs.getString('user_name')!;
      designation = prefs.getString('designation')!;
      base_location_name = prefs.getString('base_location_name')!;
      reporting_manager_name = prefs.getString('reporting_manager_name')!;
      location_name = prefs.getString('location_name')!;
      location_name = prefs.getString('location_name')!;
      // profile_image_url = prefs.getString('profile_image_url')!;

      print('emp name $userName');

      userCode = userCode;
      userName = userName;
      designation = designation;
      base_location_name = base_location_name;
      reporting_manager_name = reporting_manager_name;
      location_name = location_name;
    });
  }


  void logoutUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cl

                Fluttertoast.showToast(
                    msg: "Please wait while logging out user");
                final prefs = await SharedPreferences.getInstance();
                prefs.clear(); // close the dialog
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

  CameraController? Camcontroller;
  String imagePath = "";
  bool camVisible = false;

  getPhoto() async {
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
      _cropImage(photo);
    }
    /* String? deviceId = await PlatformDeviceId.getDeviceId;
    print("DeviceID");
    print(deviceId);*/
  }

  XFile? photo;
  var _croppedFile;
  var imageType;
  var imageEncoded;

  Future<void> _cropImage(var photo) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: Platform.isAndroid ? photo : photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        //1080 x 1350//1280 x 720
        maxWidth: 1280,
        maxHeight: 720,
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
          final imagetemp = base64.encode(value);
          setState(() {
            base64img_ = imagetemp;
          });
          print("base64img_");

          print(base64img_);
        });
      }

      setState(() {
        loading = true;
      });

      print("base64img_");
      print(base64img_);
      // cloudstorageRef(imageEncoded);
      try {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            loading = false;
          });
          if (base64img_.isEmpty || base64img_.length == 0) {
            alertFailure("Please retake photo");
          } else {
            upload(base64img_);
            if (kDebugMode) {
              print("upload has data to send");
            }
          }
        });
      } catch (e) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  var base64img_ = '';

  Widget _body() {
    if (_croppedFile != null) {
      return _imageCard();
    } else {
      return const Icon(
        Icons.add_a_photo,
        size: 50,
      );
    }
  }

  Widget _imageCard() {
    return _image();
  }

  Widget _image() {
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return Image.file(
        File(path),
        // fit: BoxFit.cover,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> cloudstorageRef(var empcode, var image) async {
    /*  setState(() {
      loading = true;
    });
*/
    /* String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    */
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("userCode");
    String empCode = empcode;

    // String empCode = empCCode_;

    // final storageRef = FirebaseStorage.instance.ref();
    // FirebaseStorage storageRefd = FirebaseStorage.instanceFor(bucket: "gs://hgstores_rwa_dilo");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();

    var locationCode = prefs.getString('locationCode') ?? '';
    // var locationCode =;

    final imagesRef = storageRef.child(
        "Profile/$userId/$empCode.jpg"); /*
    final imagesRef =
        storageRef.child("$locationCode/Profile/$userId/$empCode.jpg");*/

    // String dataUrl = base64img;
// Create a reference to "mountains.jpg"

// Create a reference to 'images/mountains.jpg'
    try {
      // await imagesRef.putString(img, format: PutStringFormat.dataUrl);
      await imagesRef
          .putString(image,
              format: PutStringFormat.base64,
              metadata: SettableMetadata(contentType: 'image/png'))
          .then((p0) {
        print('uploaded to firebase storage successfully');
        /* setState(() {
          loading = false;
        });*/
      });
      String downloadUrl = (await FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref())
          .toString();
      print("PROFILE URL $downloadUrl");
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      print('FirebaseException');
      print(e.message);
      // ...
    }

    /*  setState(() {
      loading = false;
    });*/
  }

  Future<void> upload(var image) async {
    setState(() {
      loading = true;
    });
    try {
       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/ProfilePhotoUpdate', //
      );
      print("=>");
      print(url);
      String dateForEmpCode_ =
          DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userCode");

      String empCode = "EMP$userId$dateForEmpCode_";
      var params = {
        "userId": userCode,
        "imageName": "$empCode",
        "imageFormat": "jpg",
        "imagebase64": ""
      };

      print("params");
      print(params);

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(milliseconds: 5000));

      var respo = jsonDecode(response.body);
      print(respo);

      cloudstorageRef(empCode, image);

      if (respo['statusCode'] == '200') {
        setState(() {
          loading = false;
        });
        successAlert();
        // Navigator.pop(context, 1);
      } else {
        setState(() {
          loading = false;
        });

        var msg = respo['message'] ?? 'Please try after sometime.';
        alertFailure(msg);
      }
    } catch (w) {
      setState(() {
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> changePassword() async {
    try {
      setState(() {
        changePasswordPopup = false;
        loading = true;
      });

      var params = {
        "username": userCode,
        "password": "${_passwordController.text.toString()}",
      };

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/changepassword', //
      );

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(milliseconds: 5000));

      var respo = jsonDecode(response.body);
      print(respo);
      if (respo['statusCode'] == '200') {
        setState(() {
          loading = false;
          changePasswordPopup = false;
        });
        Fluttertoast.showToast(msg: respo['status']);
        Fluttertoast.showToast(msg: "Please wait while logging out user");

        logoutUser(context);
        // successAlert_alert(respo['status']);
        // Navigator.pop(context, 1);
      } else {
        setState(() {
          loading = false;
          changePasswordPopup = false;
        });

        var msg ="${ respo['statusCode']}:${ respo['message']}" ?? 'Please try after sometime.';
        alertFailure(msg);
      }
    } catch (e) {
      setState(() {
        loading = false;
        changePasswordPopup = false;
      });
      alertFailure(Constants.networkIssue);
    }
    _passwordController.clear();
    _confirmController.clear();
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
            content: Text(msg ?? 'Please try after sometime...'),
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

  TextEditingController mobileNumberController = TextEditingController();

  Future successAlertFalse() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return SizedBox(
          width: 100,
          height: 100,
          child: AlertDialog(
            title: const Text('Alert!'),
            content: const Text(
                "Profile photo upload success\nYou need to Login again to get your profile photo "),
            actions: <Widget>[
              TextButton(
                child: const Text('Logout'),
                onPressed: () {
                  Fluttertoast.showToast(
                      msg: "Please wait while logging out user");

                  logoutUser(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future successAlert() async {
    Get.defaultDialog(
        title: "Info",
        middleText:
            'Profile photo upload success\nYou need to Login again to get your profile photo',
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(color: Colors.black),
        middleTextStyle: const TextStyle(color: Colors.black),
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();
          // logoutUser(context);
          Fluttertoast.showToast(msg: "Please wait while logging out user");
          final prefs = await SharedPreferences.getInstance();
          prefs.clear(); // ose the dialog
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          if (Platform.isIOS) {
            exit(0);
          } else {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }

          Navigator.pop(context);
          // Navigator.pop(context);
        },
        radius: 15);

    /*showSuccessAlert(respo['message'].toString());
        if(context.mounted){
          Navigator.pop(context);

        }*/
  }

  Future successAlert_alert(var msg) async {
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
                child: const Text('Ok'),
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
          .getDownloadURL();

      // final imagesRef =
      //         storageRef.child("Profile/$userId/$empCode.jpg");

      /*   final imageUrl = await storageRef
          .child("$locationCode/Profile/$userCode/$profile_image_url_.jpg")
          .getDownloadURL();*/

      setState(() {
        // attachProof = true;
        profile_image_url = imageUrl;
      });
    } catch (e) {

    }

  }

  var devideId;

 /* Future<void> _getId() async {

    final SharedPreferences pref = await SharedPreferences.getInstance();
    var id = pref.getString(
      "deviceid",
    );
    setState(() {
      devideId = id;
    });
  }*/

  Future<void> checkOtp() async {
    /*final pref = await SharedPreferences.getInstance();
    pref.get("OTP");*/

    if (_passwordController.text.toString().isEmpty) {
      alertFailure("Enter new password");
    } else if (_confirmController.text.toString() !=
        _passwordController.text.toString()) {
      alertFailure("Confirm password not matching");
    } else {
      changePassword();
    }
  }
}
