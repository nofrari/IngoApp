import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/constants/colors.dart';

class CategoryIcon extends StatelessWidget {
  CategoryIcon({
    required this.bgColor,
    required this.isWhite,
    this.icon,
    this.border,
    required this.isSmall,
    Key? key,
  }) : super(key: key);

  final IconData? icon;
  final Color bgColor;
  final bool isWhite;
  final bool isSmall;
  final bool? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSmall ? 35 : 150,
      height: isSmall ? 35 : 150,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: isSmall ? const EdgeInsets.all(10) : const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: bgColor,
        border: border != null && border == true
            ? Border.all(color: AppColor.blueActive, width: 2)
            : null,
      ),
      child: Align(
        alignment: Alignment.center,
        child: FaIcon(
          icon,
          color: isWhite ? AppColor.neutral100 : AppColor.neutral600,
          size: isSmall ? 13 : 75,
        ),
      ),
    );
  }
}
