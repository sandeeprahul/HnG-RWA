import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hng_flutter/AppPages.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:hng_flutter/HomeScreen.dart';
import 'package:hng_flutter/PageHome.dart';
import 'package:hng_flutter/PageRetail.dart';
import 'package:hng_flutter/ThemeData_.dart';
import 'package:hng_flutter/core/light_theme.dart';
import 'package:hng_flutter/loginBinding.dart';

// import 'package:hng_flutter/presentation/ai_home_page.dart';
import 'package:hng_flutter/presentation/order_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'controllers/ScreenTracker.dart';
import 'controllers/app_resume_controller.dart';
import 'controllers/camerapageController.dart';
import 'core/DeviceIdentifier.dart';
import 'helper/DatabaseHelper.dart';
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
  // Add this for Android initialization

  final dbPath = await getDatabasesPath();
  print('Database path: $dbPath');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(CameraPageController()); // Register the controller once

  runApp(GetMaterialApp(
      theme: lightTheme,
      getPages: AppPages.pages,
      // initialBinding: loginBinding(),
      debugShowCheckedModeBanner: false,
      // home: const OrderListScreen())
      home: const GifScreen()));
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // WidgetsBinding.instance;
}

class GifScreen extends StatefulWidget {
  const GifScreen({super.key});

  @override
  State<GifScreen> createState() => _GifScreenState();
}

class _GifScreenState extends State<GifScreen> {
  // final AppResumeController _appResumeController = Get.put(AppResumeController());

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
    String id = await getOrGenerateDeviceId();
    // String id = "1754551800138130000138";
    print("Generated Device ID: $id");

    final prefs = await SharedPreferences.getInstance();

    String? deviceId;

    setState(() {
      deviceId = id; // Update the UI with the fetched device ID
    });
    prefs.setString("deviceid", deviceId!);

    FirebaseMessaging.instance.getToken().then((value) {
      var token = value;
      prefs.setString('tokenFCM', token!);
    });

    Fluttertoast.showToast(
        msg: "DeviceId->$deviceId", toastLength: Toast.LENGTH_LONG);

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  }

  Future<String> getOrGenerateDeviceId() async {
    const String deviceIdKey = 'device_id';

    // Access SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Check if a device ID already exists
    String? deviceId = prefs.getString(deviceIdKey);
    final dbHelper = DatabaseHelper();

    if (deviceId == null) {
      deviceId = await dbHelper.getDeviceId();

      if (deviceId == null) {
        // Generate a new Device ID
        DateTime now = DateTime.now();

        // Base milliseconds since epoch
        String timestamp = now.millisecondsSinceEpoch.toString();

        // Append time (hour, minute, second, millisecond)
        String additionalTime = now.hour.toString().padLeft(2, '0') +
            now.minute.toString().padLeft(2, '0') +
            now.second.toString().padLeft(2, '0') +
            now.millisecond.toString().padLeft(3, '0');

        // Combine to form the unique Device ID
        deviceId = timestamp + additionalTime;

        // Save it in SharedPreferences
        await prefs.setString(deviceIdKey, deviceId);
        await dbHelper.insertDeviceId(deviceId);
      }
    }

    return deviceId;
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
          theme: lightTheme,

          /*theme: ThemeData(

            primarySwatch: Colors.blue,
            fontFamily: 'Montserrat',
          ),*/
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                  child: loading
                      ? const CircularProgressIndicator()
                      : loggedIIn
                          // ? const HomePage()
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
