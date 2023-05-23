import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/interval.dart' as transaction_interval;
import 'package:frontend/models/transaction_type.dart';
import 'package:frontend/pages/scanner/scanner_camera.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/custom_cache_manager.dart';
import 'package:frontend/services/initial_service.dart';
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

  String? selectedAccount;
  String? selectedCategory;
  String? selectedInterval;

  Dio dio = Dio();

  bool _isFocused = false;
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
  }

  bool _enableExitPopUp(List<String> images) {
    if (images.isNotEmpty ||
        controllerTitle.text.isNotEmpty ||
        controllerAmount.text.isNotEmpty ||
        controllerDescription.text.isNotEmpty ||
        controllerDate.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  String _selectedType = "";
  void setSelectedType(String type) {
    setState(() {
      _selectedType = type;
    });
    debugPrint("Selected Type: $_selectedType");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controllerTitle.dispose();
    controllerAmount.dispose();
    controllerDescription.dispose();
    controllerDate.dispose();
    super.dispose();
  }

  final DatepickerField datePicker = DatepickerField(
    controller: TextEditingController(),
  );

  final pdfPreview = PdfPreview();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> manualEntry =
        context.watch<ManualEntryService>().getManualEntry();
    List<String> images = context.watch<ScannerService>().getImages();

    List<Account> allAccounts = context.watch<AccountsService>().getAccounts();
    List<String> accountNames =
        allAccounts.map((account) => account.name).toList();

    List<CategoryModel> allCategories =
        context.watch<InitialService>().getCategories();
    List<String> categoryNames =
        allCategories.map((category) => category.label).toList();

    List<transaction_interval.IntervalModel> allIntervals =
        context.watch<InitialService>().getInterval();
    List<String> intervalNames =
        allIntervals.map((interval) => interval.name).toList();

    List<TransactionType> allTypes =
        context.watch<InitialService>().getTransactionType();
    List<String> typeNames = allTypes.map((type) => type.name).toList();

    String? valueAccount1;
    String? valueAccount2;

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
            if (_enableExitPopUp(images)) {
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
                              theme: ButtonColorTheme.secondaryLight),
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
                                await deletePdfFile(manualEntry['pdf_name']);
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
              //TODO: check if this causes problems
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const Start(),
              //   ),
              // );
              Navigator.pop(context);
            }
          },
          element: Text(
            (controllerTitle.text.isNotEmpty)
                ? controllerTitle.text.toUpperCase()
                : "NEUER EINTRAG",
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
                child: Container(
                  padding: Values.bigCardPadding,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColor.neutral500,
                          width: 0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(11),
                      color: AppColor.neutral500),
                  margin: Values.bigCardMargin,
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
                          hidePassword: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          maxLength: 50,
                          onFocusChanged: onTextFieldFocusChanged,
                        ),
                        InputField(
                          lblText: "Betrag in €",
                          reqFormatter: currencyFormatter,
                          keyboardType: numeric,
                          controller: controllerAmount,
                          maxLines: 1,
                          hidePassword: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          maxLength: 15,
                          onFocusChanged: onTextFieldFocusChanged,
                        ),
                        Dropdown(
                          label: Strings.dropdownTypeCategory,
                          dropdownItems: typeNames,
                          needsNewCategoryButton: false,
                          setValue: setSelectedType,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                        ),
                        Dropdown(
                          label: Strings.dropdownCategory,
                          dropdownItems: categoryNames,
                          needsNewCategoryButton: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          setValue: (value) {
                            selectedCategory = value;
                          },
                        ),
                        //TODO: Kontos aus DB holen
                        Dropdown(
                          label: Strings.dropdownAccount1,
                          dropdownItems: accountNames,
                          needsNewCategoryButton: false,
                          validator: (value) {
                            valueAccount1 = value;
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }

                            if (valueAccount1 == valueAccount2) {
                              return 'Zeimal dasselbe Konto ausgewählt';
                            }
                            return null;
                          },
                          setValue: (value) {
                            selectedAccount = value;
                          },
                        ),

                        //TODO: String als Constante anlegen und bei Registrieren mitschicken
                        (_selectedType == 'Transfer')
                            ? Dropdown(
                                label: Strings.dropdownAccount2,
                                dropdownItems: accountNames,
                                needsNewCategoryButton: false,
                                validator: (value) {
                                  valueAccount2 = value;
                                  if (value == null || value.isEmpty) {
                                    return 'Das Feld darf nicht leer sein';
                                  }

                                  if (valueAccount1 == valueAccount2) {
                                    return 'Zeimal dasselbe Konto ausgewählt';
                                  }
                                  return null;
                                },
                              )
                            : Container(),
                        DatepickerField(
                          controller: controllerDate,
                          serverDate: manualEntry['date'],
                        ),
                        Dropdown(
                          dropdownItems: intervalNames,
                          label: Strings.dropdownFrequency,
                          needsNewCategoryButton: false,
                          initialValue: intervalNames[0],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          setValue: (value) {
                            selectedInterval = value;
                          },
                        ),
                        InputField(
                          lblText: "Beschreibung",
                          reqFormatter: letters,
                          keyboardType: text,
                          controller: controllerDescription,
                          maxLines: 4,
                          hidePassword: false,
                          alignLabelLeftCorner: true,
                          maxLength: 250,
                          onFocusChanged: onTextFieldFocusChanged,
                        ),
                        PdfPreview(
                          pdfUrl: manualEntry['pdf_path'],
                          pdfHeight: manualEntry['pdf_height'],
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
                              final date = datePicker.selectedDate;

                              String? pdf_name = PdfFile.getName();

                              late String selectedAccountID;
                              late String selectedCategoryID;
                              late String selectedIntervalID;
                              late String selectedTypeID;

                              for (Account account in allAccounts) {
                                if (account.name == selectedAccount) {
                                  selectedAccountID = account.id;
                                  break;
                                }
                              }

                              for (CategoryModel category in allCategories) {
                                if (category.label == selectedCategory) {
                                  selectedCategoryID = category.category_id;
                                  break;
                                }
                              }

                              for (transaction_interval.IntervalModel interval
                                  in allIntervals) {
                                if (interval.name == selectedInterval) {
                                  selectedIntervalID = interval.interval_id;
                                  break;
                                }
                              }

                              for (TransactionType type in allTypes) {
                                if (type.name == _selectedType) {
                                  selectedTypeID = type.type_id;
                                  break;
                                }
                              }

                              if (manualEntry.isNotEmpty) {
                                _sendData(
                                    controllerTitle.text,
                                    currencyToDouble(controllerAmount.text),
                                    date,
                                    controllerDescription.text,
                                    manualEntry['pdf_name'],
                                    selectedCategoryID,
                                    selectedTypeID,
                                    selectedIntervalID,
                                    selectedAccountID);
                              } else {
                                if (pdf_name != null) {
                                  _sendData(
                                      controllerTitle.text,
                                      currencyToDouble(controllerAmount.text),
                                      date,
                                      controllerDescription.text,
                                      pdf_name,
                                      selectedCategoryID,
                                      selectedTypeID,
                                      selectedIntervalID,
                                      selectedAccountID);

                                  savePDFToServer(PdfFile.getPath().toString());
                                } else {
                                  _sendData(
                                      controllerTitle.text,
                                      currencyToDouble(controllerAmount.text),
                                      date,
                                      controllerDescription.text,
                                      " ",
                                      selectedCategoryID,
                                      selectedTypeID,
                                      selectedIntervalID,
                                      selectedAccountID);
                                }
                              }

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
                          theme: ButtonColorTheme.secondaryLight),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future _sendData(
      String name,
      double amount,
      DateTime date,
      String description,
      String pdfName,
      String categoryID,
      String typeID,
      String intervalID,
      String accountID) async {
    Map<String, dynamic> formData = {
      "transaction_name": name,
      "transaction_amount": amount,
      "date": date.toString(),
      "description": description,
      "bill_url": pdfName,
      "category_id": categoryID,
      "type_id": typeID,
      "interval_id": intervalID,
      "account_id": accountID
    };

    var response = await dio.post("${Values.serverURL}/transactions/input",
        data: formData);
    debugPrint(response.toString());
  }

  Future savePDFToServer(String filePath) async {
    final formData = FormData.fromMap({
      'pdf': await MultipartFile.fromFile(filePath),
    });

    var response = await dio.post("${Values.serverURL}/transactions/pdfUpload",
        data: formData, options: Options(responseType: ResponseType.json));

    debugPrint(response.toString());
  }

  Future deletePdfFile(String pdfName) async {
    try {
      await dio.delete(
        "${Values.serverURL}/transactions/$pdfName",
      );
      print('PDF file deleted successfully!');
    } catch (e) {
      print('Error while deleting PDF file: $e');
    }
  }
}
