import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/category.dart';

import '../tag.dart';

class BudgetCard extends StatefulWidget {
  BudgetCard({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.limit,
    required this.currAmount,
    super.key,
  });

  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<CategoryModel> categories;
  final double limit;
  double currAmount;

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  final _formKey = GlobalKey<FormState>();
  Dio dio = Dio();
  List<String> versuch = ["kat1", "kat2", "kat3"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatDateString(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return '$day.$month.$year';
  }

  String formatCurrency(double value) {
    String formattedValue = value.toStringAsFixed(2).replaceAll('.', ',');
    return '$formattedValue €';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 15,
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColor.neutral500,
        borderRadius: BorderRadius.circular(Values.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name, style: Fonts.budgetName),
          const SizedBox(
            height: 3,
          ),
          Text(
              "von ${formatDateString(widget.startDate)} bis ${formatDateString(widget.endDate)}",
              style: Fonts.budgetLimits),
          const SizedBox(
            height: 20,
          ),
          Text(
            "${formatCurrency(widget.currAmount)} von ${formatCurrency(widget.limit)} ausgegeben",
            style: Fonts.budgetLimits,
          ),
          const SizedBox(
            height: 5,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: 0.05,
              minHeight: 20,
              color: AppColor.blueActive,
              backgroundColor: AppColor.neutral400,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Wrap(
            spacing: 8,
            children: versuch.map((String item) {
              return Tag(
                noIcon: true,
                isSmall: true,
                btnText: item,
                onTap: () {
                  // Perform any action when the tag is tapped
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
