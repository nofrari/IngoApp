import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/widgets/categories/category_icon.dart';
import 'package:frontend/widgets/text_google.dart';

class CategoryItem extends StatelessWidget {
  CategoryItem(
      {required this.onTap,
      required this.bgColor,
      required this.isWhite,
      required this.icon,
      required this.label,
      required this.isSmall,
      this.isSelected,
      super.key});

  final String icon;
  final String bgColor;
  final bool isWhite;
  final void Function() onTap;
  final String label;
  final bool isSmall;
  bool? isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColor.neutral600,
              width: 1.5, // adjust the width as per your need
            ),
          ),
          color: isSelected != null && isSelected == true
              ? AppColor.categorySelected
              : Colors.transparent,
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 15),
              child: CategoryIcon(
                bgColor: AppColor.getColorFromString(bgColor),
                isWhite: isWhite,
                icon: AppIcons.getIconFromString(icon),
                isSmall: isSmall,
              ),
            ),
            TextGoogle(
              align: TextAlign.start,
              text: label,
              style: Fonts.text300,
            )
          ],
        ),
      ),
    );
  }
}
