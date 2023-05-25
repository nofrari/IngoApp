import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/interval.dart' as transaction_interval;
import 'package:frontend/models/interval_subtype.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/models/transaction_type.dart';
import 'package:frontend/pages/scanner/scanner_camera.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/custom_cache_manager.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/services/transaction_service.dart';
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

int getWeekdayCount() {
  DateTime now = DateTime.now();
  DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
  int weekday = firstDayOfMonth.weekday;
  int currentWeekday = now.weekday;

  int weeks = ((now.day - weekday) / 7).floor();
  int extraDays = (now.day - weekday) % 7;

  if (currentWeekday < weekday) {
    return weeks + 1;
  } else if (currentWeekday >= weekday && extraDays >= currentWeekday) {
    return weeks + 2;
  } else {
    return weeks + 1;
  }
}

String getWeekDay() {
  switch (DateTime.now().weekday) {
    case 0:
      return "Montag";
    case 1:
      return "Dienstag";
    case 2:
      return "Mittwoch";
    case 3:
      return "Donnerstag";
    case 4:
      return "Freitag";
    case 5:
      return "Samstag";
    case 6:
      return "Sonntag";
    default:
      return "";
  }
}

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

  Account? selectedAccount; // = Account(id: "", name: "", amount: 0);
  CategoryModel?
      selectedCategory; //= CategoryModel(category_id: "", bgColor: "", isWhite: false, icon: icon, label: label);
  transaction_interval.IntervalModel? selectedInterval;
  IntervalSubtypeModel? selectedIntervalSubtype;
  TransactionType? selectedType;

  Dio dio = Dio();

  bool _isFocused = false;
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
    updateCurrentTransaction();
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

  List<CategoryModel> allCategories = [];
  List<TransactionType> allTypes = [];
  List<Account> allAccounts = [];
  List<transaction_interval.IntervalModel> allIntervals = [];
  String? _initialType;
  String? _initialCategory;
  String? _initialAccount;
  String? _initialFrequency;

  TransactionModel _currentTransaction = TransactionModel(
      transaction_id: "",
      transaction_name: "",
      transaction_amount: 0,
      date: DateTime(2000),
      category_id: "",
      type_id: "",
      interval_id: "",
      account_id: "");

  void updateCurrentTransaction() async {
    setState(() {
      _currentTransaction = TransactionModel(
          transaction_id: "",
          transaction_name: controllerTitle.text,
          transaction_amount: currencyToDouble(controllerAmount.text),
          description: controllerDescription.text,
          date: controllerDate.text != ""
              ? DateFormat("dd / MM / yyyy").parse(controllerDate.text)
              : DateTime(2000),
          account_id: selectedAccount != null ? selectedAccount!.id : "",
          category_id:
              selectedCategory != null ? selectedCategory!.category_id : "",
          interval_id:
              selectedInterval != null ? selectedInterval!.interval_id : "1",
          interval_subtype_id: selectedIntervalSubtype != null
              ? selectedIntervalSubtype!.interval_subtype_id
              : "",
          type_id: selectedType != null ? selectedType!.type_id : "");
    });
    await context
        .read<TransactionService>()
        .setTransaction(_currentTransaction);
  }

  void loadTransaction() {
    TransactionModel? loadedTransaction =
        context.read<TransactionService>().getTransaction();
    if (loadedTransaction == null) return;
    setState(() {
      _currentTransaction = loadedTransaction;
      controllerTitle.text = loadedTransaction.transaction_name;
      controllerAmount.text = loadedTransaction.transaction_amount == 0
          ? ""
          : loadedTransaction.transaction_amount.toString();
      controllerDescription.text = loadedTransaction.description ?? "";
      controllerDate.text = loadedTransaction.date == DateTime(2000)
          ? ""
          : DateFormat("dd / MM / yyyy").format(loadedTransaction.date);

      allTypes = context.read<InitialService>().getTransactionType();
      allAccounts = context.read<AccountsService>().getAccounts();
      allIntervals = context.read<InitialService>().getInterval();
      allCategories = context.read<InitialService>().getCategories();

      if (loadedTransaction.type_id != "") {
        _initialType = allTypes
            .firstWhere((type) => type.type_id == loadedTransaction.type_id)
            .name;
      }
      if (loadedTransaction.account_id != "") {
        _initialAccount = allAccounts
            .firstWhere((account) => account.id == loadedTransaction.account_id)
            .name;
      }
      if (loadedTransaction.interval_id != "") {
        _initialFrequency = allIntervals
            .firstWhere((interval) =>
                interval.interval_id == loadedTransaction.interval_id)
            .name;
      }
      if (loadedTransaction.category_id != "") {
        _initialCategory = allCategories
            .firstWhere((category) =>
                category.category_id == loadedTransaction.category_id)
            .label;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadTransaction();
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

    allAccounts = context.watch<AccountsService>().getAccounts();
    List<String> accountNames =
        allAccounts.map((account) => account.name).toList();

    setState(() {
      allCategories = context.watch<InitialService>().getCategories();
    });
    List<String> categoryNames =
        allCategories.map((category) => category.label).toList();

    allIntervals = context.watch<InitialService>().getInterval();
    List<String> intervalNames =
        allIntervals.map((interval) => interval.name).toList();

    List<IntervalSubtypeModel> allIntervalSubtypes =
        context.watch<InitialService>().getIntervalSubtypes();

    List<String> allIntervalSubtypesNames() {
      //montalich, quartalsweise, halbjärhlich, jährlich
      List<String> names = [];
      if (selectedInterval != null && selectedInterval!.name == "Monatlich") {
        names.clear();
        names.add("${DateTime.now().day}. des Monats");
        names.add("${getWeekdayCount()}. ${getWeekDay()} des Monats");
      }
      return names;
    }

    allTypes = context.watch<InitialService>().getTransactionType();
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
                                    await context
                                        .read<TransactionService>()
                                        .clearTransaction();
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }
                                manualEntry.isNotEmpty
                                    ? await deletePdfFile(
                                        manualEntry['pdf_name'])
                                    : null;
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
                          initialValue: _initialType,
                          setValue: (value) {
                            setState(() {
                              selectedType = allTypes
                                  .firstWhere((type) => type.name == value);
                            });
                            updateCurrentTransaction();
                          },
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
                          initialValue: _initialCategory,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          setValue: (value) {
                            setState(() {
                              selectedCategory = allCategories.firstWhere(
                                  (category) => category.label == value);
                            });
                            updateCurrentTransaction();
                          },
                        ),
                        Dropdown(
                          label: Strings.dropdownAccount1,
                          dropdownItems: accountNames,
                          needsNewCategoryButton: false,
                          initialValue: _initialAccount,
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
                            setState(() {
                              selectedAccount = allAccounts.firstWhere(
                                  (account) => account.name == value);
                            });
                            updateCurrentTransaction();
                          },
                        ),
                        (selectedType != null &&
                                selectedType!.name == 'Transfer')
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
                                setValue: (value) {
                                  updateCurrentTransaction();
                                },
                              )
                            : Container(),
                        DatepickerField(
                          controller: controllerDate,
                          serverDate: manualEntry['date'],
                          //TODO: Add callback to call updateCurrentTransaction
                        ),
                        Dropdown(
                          dropdownItems: intervalNames,
                          label: Strings.dropdownFrequency,
                          needsNewCategoryButton: false,
                          initialValue: _initialFrequency ?? intervalNames[0],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Das Feld darf nicht leer sein';
                            }
                            return null;
                          },
                          setValue: (value) {
                            setState(() {
                              selectedInterval = allIntervals.firstWhere(
                                  (interval) => interval.name == value);
                            });
                            updateCurrentTransaction();
                          },
                        ),
                        (selectedInterval != null &&
                                selectedInterval!.name == intervalNames[2])
                            ? Dropdown(
                                dropdownItems: allIntervalSubtypesNames(),
                                label: Strings.dropdownPattern,
                                needsNewCategoryButton: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Das Feld darf nicht leer sein';
                                  }
                                  return null;
                                },
                                setValue: (value) {
                                  setState(() {
                                    selectedIntervalSubtype =
                                        allIntervalSubtypes[
                                            allIntervalSubtypesNames()
                                                .indexOf(value)];
                                  });
                                  debugPrint(
                                      "Selected interval subtype: ${selectedIntervalSubtype!.name} id: ${selectedIntervalSubtype!.interval_subtype_id}");
                                  updateCurrentTransaction();
                                },
                              )
                            : Container(),
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
                            updateCurrentTransaction();
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Daten werden gespeichert')),
                              );
                              final date = datePicker.selectedDate;

                              String? pdf_name = PdfFile.getName();

                              if (_currentTransaction.isCompleted()) {
                                //! is allowed because isCompleted() checks if thats empty
                                _sendData(
                                    manualEntry.isNotEmpty
                                        ? manualEntry['pdf_name']
                                        : pdf_name ?? " ",
                                    _currentTransaction);
                              } else {
                                debugPrint(
                                    "current Transaction Id: ${_currentTransaction.transaction_id} name: ${_currentTransaction.transaction_name} amount: ${_currentTransaction.transaction_amount} date: ${_currentTransaction.date} description: ${_currentTransaction.description} category_id: ${_currentTransaction.category_id} type_id: ${_currentTransaction.type_id} interval_id: ${_currentTransaction.interval_id} interval_subtype_id: ${_currentTransaction.interval_subtype_id} account_id: ${_currentTransaction.account_id}");
                              }

                              List<String> images =
                                  context.read<ScannerService>().getImages();

                              await CustomCacheManager.clearCache(
                                  context, images);

                              if (context.mounted) {
                                await context
                                    .read<ManualEntryService>()
                                    .forgetManualEntry();
                                await context
                                    .read<TransactionService>()
                                    .clearTransaction();
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

  Future _sendData(String pdfName, TransactionModel transaction) async {
    Map<String, dynamic> formData = {
      "transaction_name": transaction.transaction_name,
      "transaction_amount": transaction.transaction_amount,
      "date": transaction.date.toString(),
      "description": transaction.description,
      "bill_url": pdfName,
      "category_id": transaction.category_id,
      "type_id": transaction.type_id,
      "interval_id": transaction.interval_id,
      "interval_subtype_id": transaction.interval_subtype_id,
      "account_id": transaction.account_id
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
