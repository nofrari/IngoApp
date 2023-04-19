import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({required this.onTap, required this.icon, super.key});

  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.neutral800,
        padding: const EdgeInsets.all(8),
        shape: const CircleBorder(),
        side: BorderSide(width: 3, color: AppColor.blueLight),
      ),
      child: Icon(
        icon,
        color: AppColor.blueLight,
        size: 40,
      ),
    );
  }
}
