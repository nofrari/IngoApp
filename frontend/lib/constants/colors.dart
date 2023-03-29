import 'package:flutter/widgets.dart';

class AppColor {
  // AppColor._() = private constructor --> prevents Class from being instantiated
  AppColor._();
  static const Color blueColor = Color.fromARGB(255, 46, 57, 203);
  static const Color currentTab = Color.fromARGB(255, 7, 211, 166);
  static const Color defaultTab = Color.fromARGB(255, 86, 86, 86);
  static const Color appBarBackgroundColor = Color.fromARGB(255, 50, 50, 50);
  static const Color white = Color.fromARGB(255, 253, 253, 253);
  static const Color transparant = Color.fromARGB(0, 255, 255, 255);
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
      Color(0xffff9a9e),
      Color(0xfffad0c4),
      Color(0xfffad0c4),
    ],
  );
}
