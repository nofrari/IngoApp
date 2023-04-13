import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/values.dart';

class Button extends StatelessWidget {
  const Button({required this.btnText, required this.onTap, super.key});

  final String btnText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.neutral100,
          backgroundColor: AppColor.neutral500,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Values.buttonRadius),
              side: BorderSide(color: AppColor.blueLight, width: 2)),
        ),
        child: Text(btnText, style: Fonts.button, textAlign: TextAlign.center),
      ),
    );
  }
}
