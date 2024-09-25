import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/presentation/login/login_screen.dart';
import 'package:hng_flutter/loginBinding.dart';

import 'ThemeData_.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: ThemeData_.LoginScreen,
      page: () => const LoginScreen(),
      binding: loginBinding(),
    ),

  ];
}
