import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hng_flutter/AmOutletSelectScreen.dart';
import 'package:hng_flutter/presentation/login/login_screen.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';

class ThemeData_ {
  var textBold = TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
  var textWhite = TextStyle(color: Colors.white);
  var themeOrange = Colors.orange;
  static const LoginScreen = '/LoginScreen';
  static const checkInOutScreen = '/checkInOutScreen';
  static const checkListScreen = '/checkListScreen';
  static const AmOutletSelectionScreen = '/AmOutletSelectionScreen';
  static const AmOutletScreen = '/AmOutletScreen';
  static const submitCheckListScreen = '/submitCheckListScreen';
}
