import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
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

  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerAmount = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerDate = TextEditingController();

  String? Function(String?) required = (value) {
    if (value == null) {
      return 'Das Feld darf nicht leer sein';
    }
    return null;
  };

  final _formKey = GlobalKey<FormState>();

  Dio dio = Dio();

  bool _isFocused = false;
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
  }

  final _focusNodes = <FocusNode>[
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNodes.forEach((node) => node.addListener(_scrollToFocusedField));
  }

  @override
  void dispose() {
    controllerTitle.dispose();
    controllerAmount.dispose();
    controllerDescription.dispose();
    controllerDate.dispose();
    _focusNodes.forEach((node) => node.removeListener(_scrollToFocusedField));
    super.dispose();
  }

  void _scrollToFocusedField() {
    // Get the current focused field
    final focusedField = FocusScope.of(context).focusedChild;
    if (focusedField == null) {
      return;
    }

    // Get the index of the focused field
    final index = _focusNodes.indexOf(focusedField);

    // Scroll the ScrollController to the focused field
    _scrollController.animateTo(
      index * 80.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    //     .then((_) {
    //   // Get the position of the focused field
    //   final renderObject =
    //       focusedField!.context?.findRenderObject() as RenderBox;
    //   final offset = renderObject.localToGlobal(Offset.zero).dy;

    //   List<double> dropdowns = [2, 3, 4, 5, 7];

    //   // Update the offset value in the state
    //   if (dropdowns.contains(index)) {
    //     setState(() {
    //       _offset = offset;
    //     });
    //     debugPrint('offset: $_offset');
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final DatepickerField datePicker = DatepickerField(
      controller: TextEditingController(),
      focusNode: _focusNodes[6],
    );

    final pdfPreview = PdfPreview(
      focusNode: _focusNodes[9],
    );
    Map<String, dynamic> manualEntry =
        context.watch<ManualEntryService>().getManualEntry();
    List<String> images = context.watch<ScannerService>().getImages();

    if (manualEntry.isNotEmpty) {
      controllerTitle.text = manualEntry['supplier_name'];
      controllerAmount.text = manualEntry['amount'].toString();
      controllerDate.text = DateFormat("dd / MM / yyyy")
          .format(DateFormat("yyyy-MM-dd").parse(manualEntry['date']));
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isFocused = false;
        });
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
                                deletePdfFile(manualEntry['pdf_name']);
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
              child: SingleChildScrollView(
                controller: _scrollController,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputField(
                          lblText: "Titel",
                          reqFormatter: letters,
                          keyboardType: text,
                          controller: controllerTitle,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          maxLength: 50,
                          onFocusChanged: onTextFieldFocusChanged,
                          focusNode: _focusNodes[0],
                        ),
                        InputField(
                          lblText: "Betrag in €",
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
                          onFocusChanged: onTextFieldFocusChanged,
                          focusNode: _focusNodes[1],
                        ),
                        Dropdown(
                          label: Strings.dropdownTypeCategory,
                          dropdownItems: const [
                            'Einnahme',
                            'Ausgabe',
                            'Transfer',
                          ],
                          needsNewCategoryButton: false,
                          focusNode: _focusNodes[2],
                        ),
                        Dropdown(
                          label: Strings.dropdownCategory,
                          dropdownItems: const [
                            'Essen',
                            'Freizeit',
                            'Lebensmittel',
                            'Shopping',
                            'awef',
                            'asdfasdfasdf',
                            'ölkdjföjrö',
                            'jkrgh alhfiu',
                          ],
                          needsNewCategoryButton: true,
                          focusNode: _focusNodes[3],
                        ),
                        //TODO: Kontos aus DB holen
                        Dropdown(
                          label: Strings.dropdownAccount1,
                          dropdownItems: const [
                            'Gelbörse',
                            'Bank',
                            'Kreditkarte',
                          ],
                          needsNewCategoryButton: false,
                          focusNode: _focusNodes[4],
                        ),
                        //TODO: Konditional machen
                        Dropdown(
                          label: Strings.dropdownAccount2,
                          dropdownItems: const [
                            'Gelbörse',
                            'Bank',
                            'Kreditkarte',
                          ],
                          needsNewCategoryButton: false,
                          focusNode: _focusNodes[5],
                        ),
                        DatepickerField(
                          controller: controllerDate,
                          serverDate: manualEntry['date'],
                          focusNode: _focusNodes[6],
                        ),
                        Dropdown(
                          dropdownItems: const [
                            'Nie',
                            'Wöchentlich',
                            'Alle zwei Wochen',
                            'Monatlich',
                            'Quartalsweise',
                            'Jährlich',
                          ],
                          label: "Wiederholen",
                          needsNewCategoryButton: false,
                          initialValue: 'Nie',
                          focusNode: _focusNodes[7],
                        ),
                        InputField(
                          lblText: "Beschreibung",
                          reqFormatter: letters,
                          keyboardType: text,
                          controller: controllerDescription,
                          maxLines: 4,
                          alignLabelLeftCorner: true,
                          maxLength: 250,
                          onFocusChanged: onTextFieldFocusChanged,
                          focusNode: _focusNodes[8],
                        ),
                        PdfPreview(
                          pdfUrl: manualEntry['pdf_path'],
                          pdfHeight: manualEntry['pdf_height'],
                          focusNode: _focusNodes[9],
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        const SizedBox(
                          height: 300,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            (_isFocused == false)
                ? ButtonTransparentContainer(
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

                              String? pdf_name = PdfFile.getName();

                              if (manualEntry.isNotEmpty) {
                                _sendData(
                                    controllerTitle.text,
                                    amount!,
                                    date,
                                    controllerDescription.text,
                                    manualEntry['pdf_name']);
                              } else {
                                _sendData(controllerTitle.text, amount!, date,
                                    controllerDescription.text, pdf_name!);
                                savePDFToServer(PdfFile.getPath().toString());
                              }

                              // print("Name from Gallery: ${PdfFile.getName()}");
                              // print("Path from Camera: " +
                              //     manualEntry['pdf_name'].toString());
                              // print(
                              //     "Name from Gallery: ${PdfFile.getPath().toString()}");
                              // print("Path from Camera: " +
                              //     manualEntry['pdf_path'].toString());

                              List<String> images =
                                  context.read<ScannerService>().getImages();

                              await CustomCacheManager.clearCache(
                                  context, images);

                              if (context.mounted) {
                                await context
                                    .read<ManualEntryService>()
                                    .forgetManualEntry();
                              }
                              // ignore: use_build_context_synchronously
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
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future _sendData(String name, double amount, DateTime date,
      String description, String pdfName) async {
    Map<String, dynamic> formData = {
      "transaction_name": name,
      "transaction_amount": amount,
      "date": date.toString(),
      "description": description,
      "bill_url": pdfName,
      "category_id": "1234",
      "type_id": "1234",
      "interval_id": "1234",
      "account_id": "1234"
    };

    var response = await dio.post("http://10.0.2.2:5432/transactions/input",
        data: formData);
    debugPrint(response.toString());
  }

  Future savePDFToServer(String filePath) async {
    final formData = FormData.fromMap({
      'pdf': await MultipartFile.fromFile(filePath),
    });

    var response = await dio.post(
        "http://localhost:5432/transactions/pdfUpload",
        data: formData,
        options: Options(responseType: ResponseType.json));

    debugPrint(response.toString());
  }

  Future deletePdfFile(String pdfName) async {
    try {
      await dio.delete(
        "http://10.0.2.2:5432/transactions/$pdfName",
      );
      print('PDF file deleted successfully!');
    } catch (e) {
      print('Error while deleting PDF file: $e');
    }
  }
}
