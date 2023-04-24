import 'package:flutter/material.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';

class PopUp extends StatelessWidget {
  const PopUp({super.key, this.actions, this.title, required this.content});

  final String? title;
  final String? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Values.popupRadius),
      ),
      backgroundColor: AppColor.neutral500,
      title: title != null && title!.isNotEmpty
          ? Center(
              child: Text(
                title!,
                style: Fonts.text300,
                textAlign: TextAlign.center,
              ),
            )
          : null,
      contentPadding: title != null && title!.isNotEmpty
          ? Values.bigCardPadding
          : const EdgeInsets.fromLTRB(10, 20, 10, 0),
      content: content != null && content!.isNotEmpty
          ? Text(
              content!,
              style: Fonts.popupText,
              textAlign: TextAlign.center,
            )
          : null,
      actions: actions,
      actionsPadding: const EdgeInsets.symmetric(vertical: 0),
    );
  }
}
