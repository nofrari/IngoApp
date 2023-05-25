import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';

class Option extends StatelessWidget {
  const Option({required this.child, required this.onTap, super.key});
  final Widget child;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          child,
          Icon(Icons.arrow_forward_ios_rounded,
              size: 20, color: AppColor.neutral100),
        ],
      ),
    );
  }
}
