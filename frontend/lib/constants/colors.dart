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
  static Color categorySelected = HexColor("#5068B8BD");

  static Color blueDark = HexColor("#3746B7");
  static Color blueLight = HexColor("#37A3B7");
  static Color yellowDark = HexColor("#FFC400");
  static Color greenLight = HexColor("#77B737");
  static Color greenAcid = HexColor("#BCC924");
  static Color redDark = HexColor("#A34242");
  static Color pink = HexColor("#B73786");
  static Color orange = HexColor("#E07B16");
  static Color violett = HexColor("#9886C1");
  static Color greenKadmium = HexColor("#1F4B49");
  static Color greenNavy = HexColor("#242F16");

  static Map<String, Color> colors = {
    'blueDark': blueDark,
    'blueLight': blueLight,
    'yellowDark': yellowDark,
    'greenLight': greenLight,
    'greenAcid': greenAcid,
    'redDark': redDark,
    'pink': pink,
    'orange': orange,
    'violett': violett,
    'greenKadmium': greenKadmium,
    'greenNavy': greenNavy
    // add more color mappings as needed
  };

  static Color getColorFromString(String colorName) {
    return colors[colorName] ??
        neutral100; // return the corresponding color object if it exists, otherwise return black
  }
}
