import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class Header extends StatefulWidget with PreferredSizeWidget {
  const Header({required this.onTap, required this.element, super.key});

  final Widget element;
  final void Function() onTap;

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      elevation: 0,
      backgroundColor: AppColor.neutral600,
      centerTitle: true,
      title: widget.element,
      leading: GestureDetector(
        onTap: widget.onTap,
        child: Icon(
          Icons.arrow_back_ios,
          color: AppColor.neutral100,
          size: 30,
        ),
      ),
    );
  }
}
