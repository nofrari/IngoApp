import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/text_google.dart';

class CategoryToggleBlack extends StatefulWidget {
  CategoryToggleBlack({this.isBlack, required this.onToggleChange, super.key});
  final void Function() onToggleChange;
  bool? isBlack;

  @override
  _CategoryToggleBlackState createState() => _CategoryToggleBlackState();
}

class _CategoryToggleBlackState extends State<CategoryToggleBlack> {
  bool isBlack = false;

  void changeIsBlack(bool isBlackToggle) {
    setState(() {
      isBlack = isBlackToggle;
    });

    widget.onToggleChange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextGoogle(
            align: TextAlign.start,
            text: "Iconfarbe:",
            style: Fonts.text300,
          ),
          Switch(
              activeColor: AppColor.neutral700,
              activeTrackColor: Color.fromARGB(255, 76, 76, 76),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade400,
              splashRadius: 60.0,
              value: widget.isBlack ?? isBlack,
              onChanged: (value) => changeIsBlack(value)),
        ],
      ),
    );
  }
}
