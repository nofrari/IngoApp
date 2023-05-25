import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Tag extends StatelessWidget {
  const Tag({required this.btnText, this.onTap, this.isCategory, super.key});

  final String btnText;
  final void Function()? onTap;
  final bool? isCategory;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    backgroundColor = isCategory != null && isCategory == true
        ? AppColor.violett
        : AppColor.blueActive;

    return IntrinsicWidth(
      child: Container(
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  btnText,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: AppColor.neutral600,
                  ),
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
