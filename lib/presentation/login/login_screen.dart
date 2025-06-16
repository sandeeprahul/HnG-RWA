import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/HomeScreen.dart';
import 'package:hng_flutter/loginController.dart';
import 'package:hng_flutter/main.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/constants.dart';
import '../../common/my_cusotm_clipper.dart';
import '../../common/my_custom_clip_painter.dart';
import '../../widgets/custom_elevated_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

TextEditingController uname = TextEditingController();
TextEditingController password = TextEditingController();

TextEditingController mobileNumberController = TextEditingController();
TextEditingController usernameController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _confirmController = TextEditingController();
TextEditingController otpController = TextEditingController();

bool showpass = false;
GlobalKey _selectableTextKey = GlobalKey();

bool loading = false;
FocusNode _unameFocus = FocusNode();
FocusNode _passFocus = FocusNode();
bool _keyboardVisible = false;

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newKeyboardVisible =
          WidgetsBinding.instance!.window.viewInsets.bottom > 0;
      if (_keyboardVisible != newKeyboardVisible) {
        setState(() {
          _keyboardVisible = newKeyboardVisible;
        });
        if (_keyboardVisible) {
          print('Keyboard is open');
        } else {
          print('Keyboard is closed');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/home_curve.jpeg',
                      fit: BoxFit.fill,
                      height: 300,
                      width: double.infinity,
                    ),
                    Container(
                        height: 200,
                        padding: const EdgeInsets.all(56),
                        child: SvgPicture.network(
                          'https://ik.imagekit.io/hng/desktop-assets/svgs/logo.svg',
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              Visibility(
                visible: false,
                child: ClipPath(
                  clipper: MyCustomClipper(),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: MyCustomClipPainter(),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      // style: TextStyle(fontSize: 32, color: Color(0xfff76613)),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 32),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    /* const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Username',
                          style: TextStyle(color: Colors.black),
                        )),*/
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(26.0)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: uname,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          isDense: true,

                          // this will remove the default content padding
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.black),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    /*    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(color: Colors.black),
                          )),
                    ),*/
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(26.0)),
                      child: Stack(
                        children: [
                          TextField(
                            textAlign: TextAlign.center,
                            controller: password,
                            obscureText: showpass ? false : true,
                            onTap: () => print('TextField onTap'),
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              /*suffixIcon: IconButton(
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
                              ),*/
                              isDense: true,
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.black),

                              // this will remove the default content padding
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
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
                                  ? const Icon(
                                      Icons.visibility,
                                      size: 18,
                                    )
                                  : const Icon(
                                      Icons.visibility_off,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              alertMobileNumber();
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Colors.grey),
                            )),
                      ],
                    ),
                    /*const SizedBox(
                      height: 20,
                    ),*/

                    Container(
                      margin: const EdgeInsets.only(top: 26),
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfff76613),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26.0),
                            ),
                          ),
                          onPressed: () {
                            // clearAllPref();

                            if (uname.text.toString().isEmpty) {
                              /*  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Enter Username')),

                                );*/
                              _showMyDialog('Enter Username');
                            } else if (password.text.toString().isEmpty) {
                              /*  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Enter Password')),
                                );*/
                              _showMyDialog('Enter Password');
                            } else {
                              callLoginUser();
                              // http.Response response = await callLoginUser();
                              // print(response.body);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: showProgress
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.white),
                                  ),
                          )),
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height > 600 ? 100 : 50,
                    ),
                    Column(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Version: ${Constants.appVersionCode}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: SelectableText(
                            'DeviceId: $deviceId',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                            // key: _selectableTextKey,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              // textAlign: TextAlign.center,
                              controller: otpController,
                              decoration: const InputDecoration(
                                labelText: 'Enter OTP',
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            top: 1,
                            child: TextButton(
                                onPressed: () {
                                  otpController.clear();
                                  sendOtpApi();
                                },
                                child: const Text('RESEND OTP')),
                          )
                        ],
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
                              icon: !showpass
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
                              icon: !showpass_confim
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

                              // backgroundColor: Colors.b,
                              ),
                          onPressed: () {
                            checkOtp();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Reset Password',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
              // visible: true,
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
          /* Visibility(
            visible: !_keyboardVisible,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Version: 31',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: SelectableText(

                      'DeviceId: $deviceId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),

                      key: _selectableTextKey,
                    )),
                    Visibility(
                      visible: false,
                      child: IconButton(
                          onPressed: () {
                            copyDeviceId(devideId);
                          },
                          icon: const Icon(
                            Icons.file_copy_sharp,
                            size: 15,
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          )*/
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    showpass = false;
    loading = false;
    getappVersion();
    // deviceId = await PlatformDeviceId.getDeviceId;
    _getId();
  }

  bool camVisible = false;

  var deviceId   = "";

  Future<String> _getId() async {
    /* if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceId = iosDeviceInfo.identifierForVendor;
      });
      // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      setState(() {
        // deviceId = androidDeviceInfo.id; // unique ID on Android
      });
    }*/
    final SharedPreferences pref = await SharedPreferences.getInstance();

    String? id = pref.getString(
      "deviceid",
    );

    // var Myid;

    setState(() {
      deviceId = id!;
      devideId = id;
      // deviceId = "55ec53ccf5a40648";
    });

    return devideId;
  }

  var version_ = '';

  Future getappVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print('build no:$buildNumber , version:$version');
    var dd = buildNumber.split('');
    if (dd.length == 4) {
      var gg = dd[3];
      setState(() {
        version_ = '$version($gg)';
      });
    }

/*
    Get.showSnackbar(GetSnackBar(messageText: Text(
      'build no:$buildNumber , version:$version',
      style: TextStyle(color: Colors.white),),));*/
  }

  Future<void> _showMyDialog(String msg) async {
    return Get.dialog(
      AlertDialog(
        title: const Text('Alert!'),
        content: Text(msg),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomElevatedButton(
              text: 'Got it',
              onPressed: () {
                Get.back(); // Close the dialog
              },
            ),
          ),
        ],
      ),
      barrierDismissible: false, // To prevent closing the dialog by tapping outside
    );
  }

  late String devideId;

  bool showProgress = false;
  int tried = 0;

  Future<void> _showRetryAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text(Constants.networkIssue),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Ok',
                onPressed: () {
                  Navigator.of(context).pop();
                  password.clear();
                  uname.clear();
                }),
          ],
        );
      },
    );
  }

  callLoginUser() async {
    setState(() {
      showProgress = true;
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    var tokenFCM = prefs.getString("tokenFCM");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    var release;
    var number;

    if (Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      print('build no:$buildNumber , version:$version');

      var androidInfo = await DeviceInfoPlugin().androidInfo;
      release = androidInfo.version.release;
      // var sdkInt = androidInfo.version.sdkInt;

      var dd = buildNumber.split('');
      if (dd.length == 4) {
        var gg = dd[3];
        setState(() {
          number = gg;
        });
      }
    } else {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      release = iosInfo.systemVersion;
      // var sdkInt = androidInfo.version.sdkInt;
    }


    String urll =
        "${Constants.apiHttpsUrl}/Login/validateLogin";

    // Uri.parse(url)
    try {
      var response = await http.post(
        Uri.parse(urll),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': uname.text.toString(),
          'password': password.text.toString(),
          // 'deviceid': '55ec53ccf5a40648',
          'deviceid': deviceId,
          'osVersion': '$release',
          'osType': Platform.isAndroid ? 'Android' : 'Ios',
          "appVersion": Constants.appVersionString, //(1.0.62)
          // "appVersion": "$number",
          "fcmToken": "$tokenFCM"
          // 'deviceid': '123',
        }),

        /*  body: jsonEncode({
          'username': uname.text.toString(),
          'password': password.text.toString(),
          'deviceid': '$deviceId',
          'osVersion': '$release',
          'osType': Platform.isAndroid ? 'Andriod' : 'Ios',
          "appVersion": "$buildNumber"
          // 'deviceid': '123',
        }),*/
      );

      if (response.statusCode == 200) {
        var respo = jsonDecode(response.body);
        print(respo);

        // "statusCode": "201",
        if (respo['statusCode'] == "200") {
          setState(() {
            showProgress = false;
            loading = false;
            showpass = false;
          });
          if (respo['status'] == 'success') {
            setState(() {
              showProgress = false;
              loading = false;
              showpass = false;
            });

            await prefs.setString('logFlag', '1');
            await prefs.setString('userType', '0');
            await prefs.setString('userCode', uname.text.toString());
            //

            await prefs.setString(
                'locationCode', respo['location']['location_code'].toString());
            await prefs.setString('profile_image_url',
                respo['user']['profile_image_url'].toString());
            await prefs.setString(
                'latitude', respo['location']['latitude'].toString());
            await prefs.setString(
                'longitude', respo['location']['longitude'].toString());
            await prefs.setString('loginResponse', respo.toString());
            await prefs.setString(
                'user_name', respo['user']['user_name'].toString());
            await prefs.setString(
                'designation', respo['user']['designation'].toString());
            await prefs.setString('base_location_name',
                respo['user']['base_location_name'].toString());
            await prefs.setString('reporting_manager_name',
                respo['user']['reporting_manager_name'].toString());
            await prefs.setString(
                'location_name', respo['location']['location_name'].toString());
            await prefs.setString(
                'wecare_userid', respo['location']['wecare_userid'].toString());
            await prefs.setString(
                'wecare_location_code',
                respo['location']['wecare_location_code']
                    .toString()); // "wecare_userid": "hg200",
            // "wecare_location_code": ""

            // findUserGeoLoc();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ).then((value) {
                _getId();
                getappVersion();
              });
            }
          }
        } else if (respo['statusCode'] == "201") {
          print(respo);

          setState(() {
            showProgress = false;
            loading = false;

            showpass = false;
          });
          await prefs.setString('logFlag', '0');

          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(respo['status'])),
          );*/
          uname.clear();
          password.clear();
          _showMyDialog(respo['status']);
        }
      } else if (response.statusCode == 201) {
        setState(() {
          showProgress = false;
          loading = false;
          showpass = false;
        });

        var respo = jsonDecode(response.body);
        print(respo);
        /*if (respo['status'] == 'success'){

        }*/
        _showMyDialog(
            'Something went wrong\nStatus code: ${response.statusCode}\nPlease contact IT support');
        uname.clear();
        password.clear();
      } else {
        _showMyDialog(
            'Something went wrong\nStatus code: ${response.statusCode}\nPlease contact IT support');
        uname.clear();
        password.clear();
      }
    } catch (e) {
      setState(() {
        showProgress = false;
        loading = false;
      });
      _showRetryAlert();
    }
  }


  var status_ = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    showpass = false;
    loading = false;
    uname.clear();
    password.clear();
    super.dispose();

    // EasyGeofencing.stopGeofenceService();
    // geofenceStatusStream?.cancel();
  }

  Future alertMobileNumber() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 75,
          child: WillPopScope(
            onWillPop: () async {
              mobileNumberController.clear();
              usernameController.clear();

              Navigator.of(context).pop();
              return Future.value(true);
            },
            child: AlertDialog(
              /* title: const Text(
                '',
                textAlign: TextAlign.center,
              ),
              content: const Text(
                "",
                textAlign: TextAlign.center,
              ),*/
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const CircleAvatar(
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    )),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Enter Username & Mobile number to get OTP",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      TextField(
                        // textAlign: TextAlign.center,
                        controller: usernameController,
                        textInputAction: TextInputAction.next,
                        // maxLength: 10,
                        // keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Username/UserCode',
                        ),
                      ),
                      TextField(
                        // textAlign: TextAlign.center,
                        controller: mobileNumberController,
                        maxLength: 10,
                        textInputAction: TextInputAction.done,

                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Mobile Number',
                        ),
                      ),
                      ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22))
                              ),
                          onPressed: () {
                            if (usernameController.text.toString().isEmpty) {
                              alertFailure("Please Enter Username/UserCode");
                            } else if (mobileNumberController.text
                                    .toString()
                                    .isEmpty ||
                                mobileNumberController.text.toString().length !=
                                    10) {
                              Fluttertoast.showToast(
                                  msg: "Enter 10 digit mobile number");
                            } else {
                              Navigator.pop(context);
                              sendOtpApi();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Get OTP',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> sendOtpApi() async {
    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      var params = {
        "username": usernameController.text.toString(),
        "deviceid": deviceId,
        // "deviceid": "55ec53ccf5a40648",
        // "mobile": "",
        "mobile": mobileNumberController.text.toString(),
      };
      print(params);

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/ForgotPasssms', //
      );
      print(url);

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
      if (respo['statusCode'] == '200') {
        Fluttertoast.showToast(msg: respo['status']);
        prefs.setString("OTP", respo['otp']);
        setState(() {
          loading = false;
          changePasswordPopup = true;
        });
      } else {
        setState(() {
          loading = false;
        });

        var msg = "${respo['statusCode']}\n${respo['status']}" ?? 'Please try after sometime.';
        alertFailure(msg);
      }
    } catch (e) {
      setState(() {
        loading = false;
        changePasswordPopup = false;
      });
      alertFailure(e.toString());
    }
    mobileNumberController.clear();
    // usernameController.clear();
  }

  bool changePasswordPopup = false;

  bool showpass = true;
  bool showpass_confim = true;

  Future<void> changePassword() async {
    try {
      setState(() {
        changePasswordPopup = false;
        loading = true;
      });

      var params = {
        "username": usernameController.text.toString(),
        "password": _passwordController.text.toString(),
        "otp": otpController.text.toString(),
      };

      print("PARAMS->$params");
       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/forgotpassword',
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
        // Fluttertoast.showToast(msg:respo['status'] );
        // logoutUser(context);
        alertFailure(respo['status']);
        // Navigator.pop(context, 1);
      } else {
        setState(() {
          loading = false;
          changePasswordPopup = false;
        });

        var msg = respo['message'] ?? 'Please try after sometime.';
        alertFailure(msg);
      }
    } catch (e) {
      setState(() {
        loading = false;
        changePasswordPopup = false;
      });
      alertFailure(e.toString());
    }
    _passwordController.clear();
    _confirmController.clear();
    otpController.clear();
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

  Future<void> checkOtp() async {
    final pref = await SharedPreferences.getInstance();
    pref.get("OTP");

    if (pref.get("OTP") != otpController.text.toString()) {
      alertFailure("Enter valid otp");
    } else {
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

  Future<void> copyDeviceId(String dev) async {
    /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${_selectableTextKey.}"),
    ));*/
  }

  Future<void> clearAllPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await clearAllDatabase();
  }
  Future<void> clearAllDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/app_database.db'; // Replace with your database name// my_database

    // Delete the database file
    await deleteDatabase(path);

    print('Database cleared: $path');
  }
}
