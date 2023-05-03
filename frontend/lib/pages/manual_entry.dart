import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/scanner/scanner_camera.dart';
import 'package:frontend/services/custom_cache_manager.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/input_fields/dropdown_field.dart';
import 'package:frontend/widgets/input_fields/datepicker_field.dart';
import 'package:frontend/widgets/pdf_preview.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ManualEntry extends StatefulWidget {
  const ManualEntry({super.key});

  @override
  State<ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  TextInputFormatter currency =
      TextInputFormatter.withFunction((oldValue, newValue) {
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    int value = int.tryParse(cleanText) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'de', name: "EUR", symbol: '€');
    String newText = formatter.format(value / 100);
    int cursorPos = newText.length;
    if (newValue.selection.baseOffset == newValue.selection.extentOffset) {
      cursorPos = formatter.format(value / 100).length - 2;
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  });

  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));

  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerAmount = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerDate = TextEditingController();

  String? Function(String?) required = (value) {
    if (value == null) {
      return 'Das Feld darf nicht leer sein';
    }
    return null;
  };

  final DatepickerField datePicker =
      DatepickerField(controller: TextEditingController());

  final pdfPreview = PdfPreview();

  final _formKey = GlobalKey<FormState>();

  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> manualEntry =
        context.watch<ManualEntryService>().getManualEntry();
    List<String> images = context.watch<ScannerService>().getImages();

    if (manualEntry.isNotEmpty) {
      controllerName.text = manualEntry['supplier_name'];
      controllerAmount.text = manualEntry['amount'].toString();
      controllerDate.text = DateFormat("dd / MM / yyyy")
          .format(DateFormat("yyyy-MM-dd").parse(manualEntry['date']));
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: Header(
          onTap: () async {
            if (images.isNotEmpty) {
              // warning dialog
              showDialog(
                context: context,
                builder: (BuildContext context) => PopUp(
                  content:
                      "Wenn du diese Seite verlässt, verliest du den Fortschritt mit dieser Eingabe. Bist du sicher, dass du zurück zum Scanner möchtest?",
                  actions: [
                    Container(
                      margin: Values.buttonPadding,
                      child: Column(
                        children: [
                          Button(
                              btnText: "ABBRECHEN",
                              onTap: () {
                                Navigator.pop(context);
                              },
                              theme: ButtonColorTheme.secondary),
                          Button(
                              btnText: "FORTFAHREN",
                              onTap: () async {
                                if (context.mounted) {
                                  try {
                                    await CustomCacheManager.clearCache(
                                        context, images);
                                    await context
                                        .read<ManualEntryService>()
                                        .forgetManualEntry();
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ScannerCamera(),
                                  ),
                                );
                              },
                              theme: ButtonColorTheme.primary),
                        ],
                      ),
                    )
                  ],
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Start(),
                ),
              );
            }
          },
          element: Text(
            "neuer eintrag".toUpperCase(),
            style: Fonts.textHeadingBold,
          ),
        ),
        backgroundColor: AppColor.backgroundFullScreen,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Align(
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
                          reqFormatter: letters,
                          keyboardType: text,
                          controller: controllerName,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          maxLength: 50,
                        ),
                        InputField(
                          lblText: "Betrag",
                          reqFormatter: currency,
                          keyboardType: numeric,
                          controller: controllerAmount,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          maxLength: 15,
                        ),
                        InputField(
                          lblText: "Beschreibung",
                          reqFormatter: letters,
                          keyboardType: text,
                          controller: controllerDescription,
                          maxLines: 4,
                          alignLabelLeftCorner: true,
                          maxLength: 250,
                        ),
                        const Dropdown(
                          dropdownItems: [
                            'Essen',
                            'Freizeit',
                            'Lebensmittel',
                            'Shopping',
                            'awef',
                            'asdfasdfasdf',
                            'ölkdjföjrö',
                            'jkrgh alhfiu',
                          ],
                        ),
                        DatepickerField(
                          controller: controllerDate,
                          serverDate: manualEntry['date'],
                        ),
                        PdfPreview(
                          pdfUrl: manualEntry['pdf_path'],
                          pdfHeight: manualEntry['pdf_height'],
                        ),
                        //Maximaler Pfusch damit der Button unter dem Transparenten Overlay klickbar ist
                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ButtonTransparentContainer(
              child: Container(
                margin: Values.buttonPadding,
                child: Button(
                    isTransparent: true,
                    btnText: "SPEICHERN",
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Daten werden gespeichert')),
                        );

                        final refactoredAmount = controllerAmount.text
                            .replaceAll("€", "")
                            .replaceAll(" ", "")
                            .replaceAll(",", ".");

                        final amount = double.tryParse(refactoredAmount);
                        final date = datePicker.selectedDate;

                        String? pdf_path = ""; //PdfName.getName();

                        // final pdf_pathRefactored = pdf_path!
                        //     .replaceAll('"', "")
                        //     .replaceAll(
                        //         "/Users/norariglthaler/Library/Developer/CoreSimulator/Devices/20E001D3-ECF9-4A9F-BDD3-1DD818636A4E/data/Containers/Data/Application",
                        //         "");

                        print(pdf_path);

                        // final pdfFile = File(pdf_path!);
                        // final pdfBytes = pdfFile.readAsBytes();

                        // final List<int> codeUnits = pdf_path!.codeUnits;
                        // final Uint8List unit8List =
                        //     Uint8List.fromList(codeUnits);

                        _sendText(controllerName.text, amount!, date,
                            controllerDescription.text, pdf_path!);
                        List<String> images =
                            context.read<ScannerService>().getImages();

                        await CustomCacheManager.clearCache(context, images);

                        if (context.mounted) {
                          await context
                              .read<ManualEntryService>()
                              .forgetManualEntry();
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Start(),
                          ),
                        );
                      }
                    },
                    theme: ButtonColorTheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _sendText(String name, double amount, DateTime date,
      String description, String pdf_name) async {
    Map<String, dynamic> formData = {
      "transaction_name": name,
      "transaction_amount": amount,
      "date": date.toString(),
      "description": description,
      "bill_url": pdf_name,
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
