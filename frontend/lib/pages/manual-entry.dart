import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/input_fields/datepicker_field.dart';
import 'package:frontend/widgets/pdf_preview.dart';

class ManualEntry extends StatefulWidget {
  const ManualEntry({super.key});

  @override
  State<ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters =
      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9#+:()&/^\-{2}|\s]"));
  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColor.backgroundFullScreen,
          title: Text(
            "neuer eintrag".toUpperCase(),
            style: Fonts.textHeadingBold,
          ),
          titleTextStyle: TextStyle(color: AppColor.neutral100)),
      backgroundColor: AppColor.backgroundFullScreen,
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  InputField(
                    lblText: "Betrag",
                    formatter: digits,
                    keyboardType: numeric,
                  ),
                  InputField(
                    lblText: "Unternehmen",
                    formatter: letters,
                    keyboardType: text,
                  ),
                  InputField(
                    lblText: "Beschreibung",
                    formatter: letters,
                    keyboardType: text,
                  ),
                  const DatepickerField(),
                  const PdfPreview(pdfUrl: '/assets/pdf/sample.pdf'),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
