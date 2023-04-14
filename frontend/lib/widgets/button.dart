import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/values.dart';

enum ButtonColorTheme {
  primary,
  secondary,
}

class Button extends StatelessWidget {
  const Button(
      {required this.btnText,
      required this.onTap,
      required this.theme,
      super.key});

  final String btnText;
  final void Function() onTap;
  final ButtonColorTheme theme;

  @override
  Widget build(BuildContext context) {
    TextStyle buttonText;
    Color backgroundColor;
    Color borderColor;

    if (theme == ButtonColorTheme.primary) {
      buttonText = Fonts.primaryButton;
      backgroundColor = AppColor.blueLight;
      borderColor = AppColor.blueLight;
    } else {
      buttonText = Fonts.secondaryButton;
      backgroundColor = AppColor.neutral500;
      borderColor = AppColor.blueLight;
    }

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Values.buttonRadius),
              side: BorderSide(color: borderColor, width: 2)),
        ),
        child: Text(btnText, style: buttonText, textAlign: TextAlign.center),
      ),
    );
  }
}
