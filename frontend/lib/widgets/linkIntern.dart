import 'package:flutter/material.dart';

import '../constants/fonts.dart';

class LinkIntern extends StatefulWidget {
  const LinkIntern(
      {super.key, required this.linkInternTo, required this.linkInternText});

  final Widget linkInternTo;
  final String linkInternText;

  @override
  State<LinkIntern> createState() => _LinkInternState();
}

class _LinkInternState extends State<LinkIntern> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => widget.linkInternTo,
          ),
        ),
        child: Text(
          widget.linkInternText,
          style: Fonts.textLink,
        ),
      ),
    );
  }
}
