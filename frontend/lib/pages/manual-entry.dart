import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/input_fields/datepicker_field.dart';
import 'package:frontend/widgets/pdf_preview.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class ManualEntry extends StatefulWidget {
  const ManualEntry({super.key});

  @override
  State<ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));

  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerAmount = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerDate = TextEditingController();

  final DatepickerField datePicker =
      DatepickerField(controller: TextEditingController());

  final _formKey = GlobalKey<FormState>();

  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> manualEntry =
        context.watch<ManualEntryService>().getManualEntry();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: Header(
          onTap: () {
            if (context.mounted) {
              context.read<ManualEntryService>().forgetManualEntry();
            }
            Navigator.pop(context);
          },
          element: Text(
            "neuer eintrag".toUpperCase(),
            style: Fonts.textHeadingBold,
          ),
        ),
        backgroundColor: AppColor.backgroundGray,
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
                      lblText: "Name",
                      formatter: letters,
                      keyboardType: text,
                      controller: controllerName,
                    ),
                    InputField(
                      lblText: "Betrag",
                      formatter: digits,
                      keyboardType: numeric,
                      controller: controllerAmount,
                    ),
                    InputField(
                      lblText: "Beschreibung",
                      formatter: letters,
                      keyboardType: text,
                      controller: controllerDescription,
                    ),
                    DatepickerField(controller: controllerDate),
                    PdfPreview(pdfUrl: manualEntry['pdf_path']),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Daten werden gespeichert')),
                          );

                          final amount = double.tryParse(controllerAmount.text);
                          final date = datePicker.selectedDate;

                          _sendText(controllerName.text, amount!, date,
                              controllerDescription.text);
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
      ),
    );
  }

  Future _sendText(
      String name, double amount, DateTime date, String description) async {
    debugPrint(date.toString());
    Map<String, dynamic> formData = {
      "transaction_name": name,
      "transaction_amount": amount,
      "date": date.toString(),
      "description": description,
      "category_id": "1234",
      "type_id": "1234",
      "interval_id": "1234",
      "account_id": "1234"
    };

    var response = await dio.post("http://localhost:5432/transactions/input",
        data: formData);

    debugPrint(response.toString());
  }
}
