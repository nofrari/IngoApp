import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class CategoryIcon extends StatelessWidget {
  CategoryIcon(
      {required this.bgColor,
      required this.isBlack,
      this.icon,
      this.border,
      required this.isSmall,
      super.key});

  IconData? icon;
  final Color bgColor;
  final bool isBlack;
  final bool isSmall;
  bool? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: isSmall ? const EdgeInsets.all(8) : const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: bgColor,
        border: border != null && border == true
            ? Border.all(color: AppColor.blueActive, width: 2)
            : null,
      ),
      child: Icon(
        icon,
        color: isBlack ? AppColor.neutral600 : AppColor.neutral100,
        size: isSmall ? 25 : 80,
      ),
    );
  }
}
