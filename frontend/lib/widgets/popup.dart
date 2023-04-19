import 'package:flutter/material.dart';

class PopUp extends StatelessWidget {
  const PopUp(
      {super.key,
      required this.onTap,
      required this.btnTextUpper,
      required this.btnTextLower});

  final String btnTextUpper;
  final String btnTextLower;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Titel"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[Text("Hello")],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onTap,
          child: Text(btnTextUpper),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(btnTextLower),
        ),
      ],
    );
  }
}
