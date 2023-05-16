import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/text_google.dart';

class CategoryToggleBlack extends StatefulWidget {
  CategoryToggleBlack({this.isWhite, required this.onToggleChange, super.key});
  final void Function() onToggleChange;
  bool? isWhite;

  @override
  _CategoryToggleBlackState createState() => _CategoryToggleBlackState();
}

class _CategoryToggleBlackState extends State<CategoryToggleBlack> {
  bool isWhite = false;

  void changeIsBlack(bool isBlackToggle) {
    setState(() {
      isWhite = isBlackToggle;
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
            activeColor: Color.fromARGB(255, 255, 255, 255),
            activeTrackColor: Colors.white,
            inactiveThumbColor: Color.fromARGB(255, 76, 76, 76),
            inactiveTrackColor: Color.fromARGB(255, 173, 173, 173),
            splashRadius: 60.0,
            value: widget.isWhite ?? isWhite,
            onChanged: (value) => changeIsBlack(value),
          ),
        ],
      ),
    );
  }
}
