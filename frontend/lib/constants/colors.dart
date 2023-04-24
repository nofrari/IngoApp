import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';

class AppColor {
  // AppColor._() = private constructor --> prevents Class from being instantiated
  AppColor._();
  static Color backgroundFullScreen = HexColor("#121212");
  static Color backgroundInputField = HexColor("#626262");
  static Color backgroundGray = HexColor("#3B3B3B");
  static Color textColor = HexColor("#d3d1ce");
  static Color blueActive = HexColor("#48BABF");
  static Color blueInactive = HexColor("#318689");

  static Color neutral100 = HexColor("#cfcfcf");
  static Color neutral300 = HexColor("#9e9e9e");
  static Color neutral400 = HexColor("#626262");
  static Color neutral500 = HexColor("#3b3b3b");
  static Color neutral600 = HexColor("#121212");
  static Color neutral700 = HexColor("#585550");
  static Color activeMenu = HexColor("#48BABF");
  static Color neutral800 = HexColor("#33312E");
}
