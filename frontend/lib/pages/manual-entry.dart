import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/widgets/input_field.dart';

class ManualEntry extends StatefulWidget {
  const ManualEntry({super.key});

  @override
  State<ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters =
      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z+|\s]"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColor.background,
          title: Text(
            "Neuer Eintrag".toUpperCase(),
            style: Fonts.textHeadingBold,
          ),
          titleTextStyle: TextStyle(color: AppColor.neutral100)),
      backgroundColor: AppColor.background,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: Values.bigCardPadding,
          decoration: BoxDecoration(
              border: Border.all(
                  color: AppColor.neutral500,
                  width: 0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(11),
              color: AppColor.neutral500),
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputField(
                  lblText: "Betrag",
                  formatter: digits,
                ),
                InputField(
                  lblText: "Test",
                  formatter: letters,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
