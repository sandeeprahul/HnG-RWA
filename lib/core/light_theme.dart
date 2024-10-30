import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData
lightTheme = ThemeData(
  useMaterial3: true,
  primaryColor: Colors.orange,

  // colorScheme: lightColorScheme,
  textTheme: GoogleFonts.aBeeZeeTextTheme().apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 4.0,
    backgroundColor: Color(0xffF5F5F5),
    // backgroundColor: Color.fromARGB(255, 242, 242, 247),
    foregroundColor: Colors.black,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: const Color.fromRGBO(237, 237, 237, 1.0),
    surfaceTintColor: const Color.fromRGBO(237, 237, 237, 1.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    modalBackgroundColor: const Color.fromRGBO(237, 237, 237, 1.0),
  ),
  cardTheme: CardTheme(
    elevation: 4.0,
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6.0),
    ),
  ),
  canvasColor: Colors.white,
  dialogTheme: DialogTheme(
    backgroundColor: const Color.fromRGBO(237, 237, 237, 1.0),
    surfaceTintColor: const Color.fromRGBO(237, 237, 237, 1.0),
    titleTextStyle: GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
    ),
    contentTextStyle: GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),

  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      // foregroundColor: Colors.blue,
      backgroundColor: Colors.blue,// Button text color
      textStyle: const TextStyle(fontSize: 16,color: Colors.white), // Button text style
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    backgroundColor: const Color(0xfff76613),
    textStyle: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white),
  )),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      textStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16.0,
      ),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.black,
    size: 24.0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 16.0,
    ),
    floatingLabelStyle: GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 16.0,
    ),
    errorStyle: GoogleFonts.poppins(
      color: Colors.red,
      fontSize: 14.0,
    ),
    hintStyle: GoogleFonts.poppins(
      color: const Color.fromARGB(153, 61, 61, 66),
      fontSize: 16.0,
    ),
    helperStyle: GoogleFonts.poppins(
      color: const Color.fromARGB(153, 61, 61, 66),
      fontSize: 16.0,
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    //todo
    // focusedBorder: OutlineInputBorder(
    //   borderSide: BorderSide(color: darkPrimaryColor),
    // ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    textColor: Colors.black,
    iconColor: Colors.black,
  ),
  navigationBarTheme: NavigationBarThemeData(
    // backgroundColor: const Color.fromRGBO(237, 237, 237, 1.0),
    // backgroundColor: const Color.fromRGBO(237, 237, 237, 1.0),
    backgroundColor: const Color(0xffffffff),
    // selectedIconBackgroundColor: Colors.grey,

    iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
      if (states.contains(MaterialState.selected)) {
        return const IconThemeData(
          color: Colors.white,
        );
      }
      return const IconThemeData(
        color: Colors.black,
      );
    }),
    labelTextStyle: MaterialStateTextStyle.resolveWith((states) {
      return GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 14.0,
      );
    }),
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 247),

/*  extensions: [
    GoogleButtonTheme(
      backgroundColor: ColorUtils().gmailSignInButton.color,
      foregroundColor: Colors.black,
    ),
    AppleButtonTheme(
      backgroundColor: ColorUtils().appleSignInButton.color,
      foregroundColor: Colors.black,
    ),
  ],*/
);
