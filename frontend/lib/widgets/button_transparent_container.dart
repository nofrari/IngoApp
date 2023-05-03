import 'package:flutter/material.dart';

class ButtonTransparentContainer extends StatelessWidget {
//place this widget in a stack with alignment: Alignment.bottomCenter and pass the button as the child

  const ButtonTransparentContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0.1,
            0.5,
          ],
          colors: [Colors.transparent, Colors.black],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: child,
    );
  }
}
