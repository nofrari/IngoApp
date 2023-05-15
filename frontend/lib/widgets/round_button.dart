import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class RoundButton extends StatelessWidget {
  const RoundButton(
      {required this.onTap,
      required this.icon,
      this.padding,
      this.color,
      this.iconSize,
      this.borderWidth,
      super.key});

  final IconData icon;
  final void Function() onTap;
  final double? padding;
  final Color? color;
  final double? iconSize;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: AppColor.neutral800,
        padding: EdgeInsets.all((padding != null) ? padding! : 8),
        shape: const CircleBorder(),
        side: BorderSide(
            width: (borderWidth != null) ? borderWidth! : 2,
            color: (color != null) ? color! : AppColor.blueActive),
      ),
      child: Icon(
        icon,
        color: (color != null) ? color! : AppColor.blueActive,
        size: (iconSize != null) ? iconSize! : 25,
      ),
    );
  }
}
