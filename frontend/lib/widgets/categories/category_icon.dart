import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/constants/colors.dart';

class CategoryIcon extends StatelessWidget {
  CategoryIcon(
      {required this.bgColor,
      required this.isWhite,
      this.icon,
      this.border,
      required this.isSmall,
      super.key});

  IconData? icon;
  final Color bgColor;
  final bool isWhite;
  final bool isSmall;
  bool? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSmall ? 50 : 150,
      height: isSmall ? 50 : 150,
      margin: const EdgeInsets.only(left: 10),
      padding: isSmall ? const EdgeInsets.all(10) : const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: bgColor,
        border: border != null && border == true
            ? Border.all(color: AppColor.blueActive, width: 2)
            : null,
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: isWhite ? AppColor.neutral100 : AppColor.neutral600,
          size: isSmall ? 25 : 80,
        ),
      ),
    );
  }
}
