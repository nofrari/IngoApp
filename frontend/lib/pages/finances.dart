import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/color.dart';
import 'package:frontend/models/icon.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/input_fields/dropdown_field_multi.dart';

import 'package:frontend/widgets/transactions/transaction_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/values.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/initial_service.dart';
import '../services/transaction_service.dart';
import '../widgets/input_fields/datepicker_field.dart';
import '../widgets/input_fields/dropdown_field.dart';
import '../widgets/input_fields/input_field.dart';

import '../constants/fonts.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  List<TransactionModel> transactions = [];
  List<ColorModel> colors = [];
  List<IconModel> icons = [];
  List<CategoryModel> categories = [];
  List<Account> accounts = [];
  String? selectedCategory;
  String? selectedAccount;
  String? selectedStartDate;

  String? validatorDate;

  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s\.]"));

  TextInputType text = TextInputType.text;

  Dio dio = Dio();

  void onStartDateSelected(String startDate) {
    setState(() {
      selectedStartDate = startDate;
    });
  }

  void onCategorySelected(List<String> values) {
    setState(() {
      selectedCategory = values.join(", ");
    });
    debugPrint(selectedCategory);
  }

  void onAccountSelected(List<String> values) {
    setState(() {
      selectedAccount = values.join(", ");
    });
    debugPrint(selectedAccount);
  }

  List<TransactionModel> filteredTransactions = [];
  bool matchFound = true;

  List<TransactionModel> filterTransactionsByDateRange(
      List<TransactionModel> transactions, String startDate, String endDate) {
    filteredTransactions.clear();
    matchFound = false;

    for (var transaction in transactions) {
      bool transactionMatchFound = true;

      if (endDate.isEmpty) {
        if (transaction.date.isBefore(DateTime.parse(startDate))) {
          transactionMatchFound = false;
        }
      } else if (startDate.isEmpty) {
        if (transaction.date
            .isAfter(DateTime.parse(endDate).add(const Duration(days: 1)))) {
          transactionMatchFound = false;
        }
      } else {
        if (transaction.date.isBefore(DateTime.parse(startDate)) ||
            transaction.date.isAfter(
                DateTime.parse(endDate).add(const Duration(days: 1)))) {
          transactionMatchFound = false;
        }
      }

      if (transactionMatchFound) {
        filteredTransactions.add(transaction);
        matchFound = true;
      }
    }

    setState(() {});

    return filteredTransactions;
  }

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();
  TextEditingController controllerSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    transactions = context.watch<TransactionService>().getTransactions();
    categories = context.watch<InitialService>().getCategories();
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
    accounts = context.watch<AccountsService>().getAccounts();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            InputField(
              lblText: "Suche",
              reqFormatter: letters,
              keyboardType: text,
              controller: controllerSearch,
              maxLines: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Das Feld darf nicht leer sein';
                }
                return null;
              },
              onChanged: (value) {
                // filterTransactions(transactions, controllerSearch.text);
              },
              maxLength: 50,
              onFocusChanged: (value) {},
            ),
            DatepickerField(
              label: "Start",
              controller: controllerStartDate,
              errorMsgBgColor: AppColor.backgroundFullScreen,
              onChanged: (value) {
                if (controllerEndDate.text.isNotEmpty) {
                  if (isStartDateBeforeEndDate(value, controllerEndDate.text)) {
                    filterTransactionsByDateRange(
                        transactions,
                        formatDate(value),
                        (controllerEndDate.text == "")
                            ? controllerEndDate.text
                            : formatDate(controllerEndDate.text));
                    setState(() {
                      validatorDate = null;
                    });
                  } else {
                    setState(() {
                      validatorDate =
                          'Das Startdatum muss vor dem Enddatum liegen';
                    });
                  }
                } else {
                  filterTransactionsByDateRange(
                      transactions,
                      DateFormat('yyyy-MM-dd')
                          .format(DateFormat('dd / MM / yyyy').parse(value)),
                      (controllerEndDate.text == "")
                          ? controllerEndDate.text
                          : formatDate(controllerEndDate.text));
                  setState(() {
                    validatorDate = null;
                  });
                }
              },
              validator: (value) {
                return validatorDate;
              },
            ),
            DatepickerField(
              label: "End",
              controller: controllerEndDate,
              errorMsgBgColor: AppColor.backgroundFullScreen,
              onChanged: (value) {
                if (controllerStartDate.text.isNotEmpty) {
                  if (isStartDateBeforeEndDate(
                      controllerStartDate.text, value)) {
                    filterTransactionsByDateRange(
                      transactions,
                      (controllerStartDate.text.isEmpty)
                          ? controllerStartDate.text
                          : formatDate(controllerStartDate.text),
                      formatDate(value),
                    );
                    setState(() {
                      validatorDate = null;
                    });
                  } else {
                    setState(() {
                      validatorDate =
                          'Das Startdatum muss vor dem Enddatum liegen';
                    });
                  }
                } else {
                  filterTransactionsByDateRange(
                    transactions,
                    (controllerStartDate.text.isEmpty)
                        ? controllerStartDate.text
                        : formatDate(controllerStartDate.text),
                    formatDate(value),
                  );
                  setState(() {
                    validatorDate = null;
                  });
                }
              },
              validator: (value) {
                return validatorDate;
              },
            ),
            DropdownMultiselect(
              dropdownItems:
                  categories.map((category) => category.label).toList(),
              setValues: (value) {
                onCategorySelected(value);
              },
              label: "Kategorie",
            ),
            DropdownMultiselect(
              dropdownItems: accounts.map((account) => account.name).toList(),
              setValues: (value) {
                onAccountSelected(value);
              },
              label: "Konto",
            ),
            (matchFound)
                ? TransactionList(
                    accounts: selectedAccount,
                    selectedCategory: selectedCategory,
                    transactions: filteredTransactions.isEmpty
                        ? transactions
                        : filteredTransactions,
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text("Kein Ergebnis gefunden", style: Fonts.text300),
                  ),
          ],
        ),
      ),
    );
  }

  String formatDate(String inputDate) {
    DateFormat inputFormat = DateFormat('dd / MM / yyyy');
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    DateTime date = inputFormat.parse(inputDate);

    String outputDate = outputFormat.format(date);

    return outputDate;
  }

  bool isStartDateBeforeEndDate(String startDate, String endDate) {
    DateTime start = DateTime.parse(formatDate(startDate));
    DateTime end = DateTime.parse(formatDate(endDate));

    return start.isBefore(end);
  }
}
