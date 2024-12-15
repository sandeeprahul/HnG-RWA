import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hng_flutter/AppPages.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:hng_flutter/HomeScreen.dart';
import 'package:hng_flutter/PageHome.dart';
import 'package:hng_flutter/PageRetail.dart';
import 'package:hng_flutter/ThemeData_.dart';
import 'package:hng_flutter/core/light_theme.dart';
import 'package:hng_flutter/loginBinding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/DeviceIdentifier.dart';
import 'presentation/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GetMaterialApp(
          theme: lightTheme,
          getPages: AppPages.pages,
          // initialBinding: loginBinding(),
          debugShowCheckedModeBanner: false,
          home: const GifScreen())
      // home:  SplashScreen())
      );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // WidgetsBinding.instance;
}

class GifScreen extends StatefulWidget {
  const GifScreen({Key? key}) : super(key: key);

  @override
  State<GifScreen> createState() => _GifScreenState();
}

class _GifScreenState extends State<GifScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceId();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          ));
    });
  }

  getDeviceId() async {

    String id = await DeviceIdentifier.getUniqueId();


    final prefs = await SharedPreferences.getInstance();
    String? deviceId;

    print("device id: $id");

    setState(() {
      deviceId = id;  // Update the UI with the fetched device ID
    });



    FirebaseMessaging.instance.getToken().then((value) {
      var token = value;
      prefs.setString('tokenFCM', token!);
      print('tokenFCM$token');
    });
    prefs.setString("deviceid", deviceId!);


    setState(() {
      prefs.setString("deviceidDDDD", deviceId!);
    });

    Fluttertoast.showToast(
        msg: "DeviceId->$deviceId", toastLength: Toast.LENGTH_LONG);

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/app_icon.gif',
    );
  }
}

bool showProgress = false;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

var staticUrlString = "RWAWEB.HEALTHANDGLOWONLINE.CO.IN";

String? deviceId;

bool am = false;
FirebaseMessaging? messaging;

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messaging = FirebaseMessaging.instance;
    loggedIn();
  }



  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }



  bool loggedIIn = false;
  String flag = '';
  bool loading = true;
  late String userType;

  Future<bool> loggedIn() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    var action;
    action = prefs.getString('logFlag') ?? '-1';
    userType = prefs.getString('userType') ?? '-1';

    print('LogFlag->$action ,userType->$userType');
    var looooggedd;
    if (action == '-1' || action == null) {
      setState(() {
        loggedIIn = false;
        flag = '0';
        looooggedd = false;
        loading = false;
      });
      return looooggedd;
    } else if (action == '1') {
      setState(() {
        loggedIIn = true;
        flag = '1';
        looooggedd = true;
        loading = false;
      });
      // findUserGeoLoc();

      return looooggedd;
    } else if (action == '0') {
      setState(() {
        loggedIIn = false;
        flag = '0';
        looooggedd = false;
        loading = false;
      });
      return looooggedd;
    }
    return looooggedd;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Montserrat',
          ),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                  child: loading
                      ? const CircularProgressIndicator()
                      : loggedIIn
                          ? const HomeScreen()
                          // : PageRetail()
                          : const LoginScreen()))),
    );
  }

  @override
  void dispose() {
    loggedIIn = false;
    flag = '';
    loading = false;
    super.dispose();
  }

  var status_ = 0;
}
