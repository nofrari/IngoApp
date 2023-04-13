import 'package:flutter/material.dart';
//import constants
import '../constants/colors.dart';
import '../constants/values.dart';
import '../constants/fonts.dart';

class TotalAmountCard extends StatefulWidget {
  TotalAmountCard({required this.totalAmount, super.key});

  double totalAmount;

  @override
  State<TotalAmountCard> createState() => _TotalAmountCardState();
}

class _TotalAmountCardState extends State<TotalAmountCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Values.cardRadius),
          color: AppColor.neutral500),
      padding: Values.smallCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Gesamtvermögen",
            style: Fonts.text300,
          ),
          Text(
            "aus allen Konten",
            style: Fonts.text100,
          ),
          Text(
            widget.totalAmount.toString(),
            style: Fonts.text400,
          )
        ],
      ),
    );
  }
}
