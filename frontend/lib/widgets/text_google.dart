import 'package:flutter/material.dart';

class TextGoogle extends StatelessWidget {
  const TextGoogle(
      {required this.align,
      required this.text,
      required this.style,
      super.key});

  final TextStyle style;
  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: style,
        textAlign: align,
      ),
    );
  }
}
