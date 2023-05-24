import 'package:flutter/material.dart';
import 'package:frontend/widgets/text_google.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/values.dart';

class Tag extends StatelessWidget {
  const Tag(
      {required this.btnText,
      required this.onTap,
      this.isTransparent,
      super.key});

  final String btnText;
  final void Function() onTap;
  final bool? isTransparent;

  @override
  Widget build(BuildContext context) {
    TextStyle buttonText;
    Color backgroundColor;
    Color borderColor;

    buttonText = Fonts.primaryButton;
    backgroundColor = AppColor.blueActive;
    borderColor = AppColor.blueActive;

    return IntrinsicWidth(
      child: Container(
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: borderColor, width: 2),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  btnText,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: AppColor.neutral600),
                ),
                Icon(
                  Icons.close,
                  color: AppColor.neutral500,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
