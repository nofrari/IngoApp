import 'package:flutter/widgets.dart';

class Values {
  // AppColor._() = private constructor --> prevents Class from being instantiated
  Values._();
  static const double iconSize = 30;
  static const double leadingWidth = 70;
  static const double actionsWidth = 70;
  static const double notchMargin = 5;
  static const double menuBarHeight = 60;
  static const double menuBarItemMinWidth = 40;
  static const double buttonRadius = 30;
  static const double cardRadius = 20;
  static const double popupRadius = 5;
  static const double inputRadius = 5;
  static const double inputBorder = 2;
  static const double inputWidth = 315;
  static const double roundButtonSize = 28;
  static const double accountCardHeight = 120;

  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(vertical: 15, horizontal: 20);
  static const EdgeInsets smallCardPadding =
      EdgeInsets.symmetric(vertical: 20, horizontal: 60);
  static const EdgeInsets bigCardPadding =
      EdgeInsets.symmetric(vertical: 10, horizontal: 10);
  static const EdgeInsets bigCardMargin = EdgeInsets.all(20);

  static const EdgeInsets paddingHorizontal =
      EdgeInsets.symmetric(vertical: 0, horizontal: 25);

  static const EdgeInsets accountHeading = EdgeInsets.fromLTRB(10, 20, 10, 40);

  static const String serverURL = 'https://data.ingoapp.at';
  //  'http://10.0.2.2:5432';
  //'http://localhost:5432';
}
