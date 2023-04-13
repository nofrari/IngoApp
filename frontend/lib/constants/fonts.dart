import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class Fonts {
  Fonts._();
  static TextStyle text100 = GoogleFonts.josefinSans(
      color: AppColor.neutral100, fontSize: 12, fontWeight: FontWeight.normal);
  static TextStyle text200 = GoogleFonts.josefinSans(
      color: AppColor.neutral100, fontSize: 15, fontWeight: FontWeight.bold);
  static TextStyle text300 = GoogleFonts.josefinSans(
      color: AppColor.neutral100, fontSize: 18, fontWeight: FontWeight.normal);
  static TextStyle text400 = GoogleFonts.josefinSans(
      color: AppColor.neutral100, fontSize: 25, fontWeight: FontWeight.w500);
  static TextStyle text500 = GoogleFonts.josefinSans(
      color: AppColor.neutral100, fontSize: 30, fontWeight: FontWeight.bold);
  static TextStyle textHeadingBold = GoogleFonts.josefinSans(
      color: AppColor.neutral100, fontSize: 18, fontWeight: FontWeight.bold);

  static TextStyle textDateSmall = GoogleFonts.josefinSans(
    color: AppColor.neutral100,
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  static TextStyle textTransactionName = GoogleFonts.josefinSans(
    color: AppColor.neutral100,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textTransactionDescription = GoogleFonts.josefinSans(
    color: AppColor.neutral100,
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );
  static TextStyle button = GoogleFonts.josefinSans(
    color: AppColor.callToActionLight,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
