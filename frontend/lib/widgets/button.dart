import 'package:flutter/material.dart';
import 'package:frontend/widgets/text_google.dart';
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
      this.isTransparent,
      super.key});

  final String btnText;
  final void Function() onTap;
  final ButtonColorTheme theme;
  final bool? isTransparent;

  @override
  Widget build(BuildContext context) {
    TextStyle buttonText;
    Color backgroundColor;
    Color borderColor;

    if (theme == ButtonColorTheme.primary) {
      buttonText = Fonts.primaryButton;
      backgroundColor = AppColor.blueActive;
      borderColor = AppColor.blueActive;
    } else {
      buttonText = Fonts.secondaryButton;
      backgroundColor = (isTransparent != null && isTransparent!)
          ? Colors.transparent
          : AppColor.neutral500;
      borderColor = AppColor.blueActive;
    }

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Values.buttonRadius),
            side: BorderSide(color: borderColor, width: 2),
          ),
        ),
        child: TextGoogle(
            text: btnText, style: buttonText, align: TextAlign.center),
      ),
    );
  }
}
