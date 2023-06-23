import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Tag extends StatelessWidget {
  const Tag({
    required this.btnText,
    this.onTap,
    this.isCategory,
    this.noIcon = false,
    this.isSmall,
    super.key,
  });

  final String btnText;
  final void Function()? onTap;
  final bool? isCategory;
  final bool? noIcon;
  final bool? isSmall;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    backgroundColor = isCategory != null && isCategory == true
        ? AppColor.violett
        : AppColor.blueActive;

    return IntrinsicWidth(
      child: ElevatedButton(
        onPressed: onTap != null ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          padding: isSmall == true
              ? const EdgeInsets.symmetric(vertical: 0, horizontal: 0)
              : const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                btnText,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: AppColor.neutral600,
                ),
              ),
              noIcon != true
                  ? Icon(
                      Icons.close,
                      color: AppColor.neutral500,
                      size: 18,
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
