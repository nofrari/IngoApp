import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';

class Header extends StatefulWidget {
  const Header({required this.onTap, required this.element, super.key});

  final Widget element;
  final void Function() onTap;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        children: [
          Container(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColor.neutral100,
                size: 30,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              margin: const EdgeInsets.only(right: 20),
              child: widget.element,
            ),
          ),
        ],
      ),
    );
  }
}
