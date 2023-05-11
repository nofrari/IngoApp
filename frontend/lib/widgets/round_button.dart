import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class RoundButton extends StatelessWidget {
  RoundButton(
      {this.isTransparent, required this.onTap, required this.icon, super.key});

  final IconData icon;
  final void Function() onTap;
  bool? isTransparent;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isTransparent != null && isTransparent == true
            ? Colors.transparent
            : AppColor.neutral800,
        padding: const EdgeInsets.all(8),
        shape: const CircleBorder(),
        side: BorderSide(width: 2, color: AppColor.blueActive),
      ),
      child: Icon(
        icon,
        color: AppColor.blueActive,
        size: 25,
      ),
    );
  }
}
