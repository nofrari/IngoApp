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
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/initial_service.dart';
import '../services/transaction_service.dart';
import '../widgets/input_fields/datepicker_field.dart';
import '../widgets/input_fields/input_field.dart';

import '../constants/fonts.dart';
import '../widgets/tag.dart';

class Finances extends StatefulWidget {
  Finances({this.accountId, super.key});
  String? accountId;
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
  List<String> selectedCategoryTags = [];
  List<String> selectedAccountTags = [];
  String? selectedEndDate;
  Account? accountSelectedFromHome;
  bool? previouslySelected = true;

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

  void onEndDateSelected(String endDate) {
    setState(() {
      selectedEndDate = endDate;
    });
  }

  void onCategorySelected(List<String> values) {
    setState(() {
      selectedCategory = values.join(", ");
    });
  }

  void onAccountSelected(List<String> values) {
    setState(() {
      if (widget.accountId == null && previouslySelected == true) {
        selectedAccount = "$selectedAccount, ${values.join(", ")}";
        previouslySelected = false;
      } else {
        selectedAccount = values.join(", ");
      }
    });
    debugPrint("selectedAccounts: ${selectedAccount.toString()}");
  }

  void handleCategoryTagsChanged(List<String> tags) {
    setState(() {
      selectedCategoryTags = tags;
    });
  }

  void handleAccountTagsChanged(List<String> tags) {
    setState(() {
      selectedAccountTags.addAll(tags);
    });
  }

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();
  TextEditingController controllerSearch = TextEditingController();

  List<TransactionModel> filteredTransactions = [];
  bool matchFound = true;

  List<TransactionModel> filterTransactions(
      List<TransactionModel> transactions, String filter) {
    filteredTransactions.clear();

    List<String> searchTerms = filter.toLowerCase().split(" ");

    matchFound = false;

    for (var transaction in transactions) {
      bool transactionMatchFound = true;

      for (var term in searchTerms) {
        if (!transaction.transaction_name.toLowerCase().contains(term) &&
            !transaction.transaction_amount
                .toString()
                .toLowerCase()
                .contains(term)) {
          transactionMatchFound = false;
        }
        break;
      }

      if (transactionMatchFound) {
        filteredTransactions.add(transaction);
        matchFound = true;
      }
    }

    setState(() {});

    return filteredTransactions;
  }

  List<Widget> generateTags() {
    List<Widget> tags = [];
    tags.addAll(selectedCategoryTags.map((String item) {
      return Tag(
        btnText: item,
        isCategory: true,
        onTap: () {
          setState(() {
            selectedCategoryTags.remove(item);
          });
          onCategorySelected(selectedCategoryTags);
        },
      );
    }));
    tags.addAll(selectedAccountTags.map((String item) {
      return Tag(
        btnText: item,
        isCategory: false,
        onTap: () {
          setState(() {
            selectedAccountTags.remove(item);
          });
          onAccountSelected(selectedAccountTags);
        },
      );
    }));

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    transactions = context.watch<TransactionService>().getTransactions();
    categories = context.watch<InitialService>().getCategories();
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
    accounts = context.watch<AccountsService>().getAccounts();
    if (widget.accountId != null) {
      accountSelectedFromHome =
          context.watch<AccountsService>().getAccount(widget.accountId ?? "");
      debugPrint(accountSelectedFromHome?.name);

      setState(() {
        selectedAccount = accountSelectedFromHome?.name ?? "";

        selectedAccountTags.add(selectedAccount!);

        debugPrint("selectedTags: ${selectedAccountTags.toList()}");
        onAccountSelected(selectedAccountTags);
        widget.accountId = null;
      });
    }
    List<Widget> tags = generateTags();

    String test = DateFormat('yyyy-MM-dd')
        .format(DateFormat('dd / MM / yyyy').parse("07 / 05 / 2023"));
    DateTime test2 = DateTime.parse(test);
    print(test2.runtimeType);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            InputField(
              hidePassword: false,
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
                filterTransactions(transactions, controllerSearch.text);
              },
              maxLength: 50,
              onFocusChanged: (value) {},
            ),
            Container(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: DatepickerField(
                      label: "Start",
                      controller: controllerStartDate,
                      errorMsgBgColor: AppColor.backgroundFullScreen,
                      onChanged: (value) {
                        onStartDateSelected(value);
                        (controllerEndDate.text == "")
                            ? onEndDateSelected(controllerEndDate.text)
                            : onEndDateSelected(
                                formatDate(controllerEndDate.text));
                      },
                      validator: (value) {
                        if (controllerEndDate.text.isNotEmpty && value != "") {
                          String startDateString = DateFormat('yyyy-MM-dd')
                              .format(
                                  DateFormat('dd / MM / yyyy').parse(value!));
                          String endDateString = DateFormat('yyyy-MM-dd')
                              .format(DateFormat('dd / MM / yyyy')
                                  .parse(controllerEndDate.text));

                          DateTime startDate = DateTime.parse(startDateString);
                          DateTime endDate = DateTime.parse(endDateString);

                          if (endDate.isBefore(startDate)) {
                            return "Startdatum < Enddatum";
                          } else {
                            return null;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: DatepickerField(
                      label: "End",
                      controller: controllerEndDate,
                      errorMsgBgColor: AppColor.backgroundFullScreen,
                      onChanged: (value) {
                        onEndDateSelected(value);
                        (controllerStartDate.text == "")
                            ? onStartDateSelected(controllerStartDate.text)
                            : onStartDateSelected(
                                formatDate(controllerStartDate.text));
                      },
                      validator: (value) {
                        if (controllerStartDate.text.isNotEmpty &&
                            value != "") {
                          String startDateString = DateFormat('yyyy-MM-dd')
                              .format(DateFormat('dd / MM / yyyy')
                                  .parse(controllerStartDate.text));
                          String endDateString = DateFormat('yyyy-MM-dd')
                              .format(
                                  DateFormat('dd / MM / yyyy').parse(value!));

                          DateTime startDate = DateTime.parse(startDateString);
                          DateTime endDate = DateTime.parse(endDateString);

                          if (endDate.isBefore(startDate)) {
                            return "Enddatum darf nicht vor dem Startdatum liegen";
                          } else {
                            return null;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownMultiselect(
                      dropdownItems:
                          categories.map((category) => category.label).toList(),
                      setValues: (value) {
                        onCategorySelected(value);
                      },
                      label: "Kategorie",
                      selectedTags: selectedCategoryTags,
                      onTagsChanged: handleCategoryTagsChanged,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: DropdownMultiselect(
                      dropdownItems:
                          accounts.map((account) => account.name).toList(),
                      setValues: (value) {
                        onAccountSelected(value);
                      },
                      label: "Konto",
                      selectedTags: selectedAccountTags,
                      onTagsChanged: handleAccountTagsChanged,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 8,
                children: tags,
              ),
            ),
            (matchFound)
                ? TransactionList(
                    accounts: selectedAccount,
                    selectedCategory: selectedCategory,
                    startDate: selectedStartDate,
                    endDate: selectedEndDate,
                    transactions: filteredTransactions.isEmpty
                        ? transactions
                        : filteredTransactions,
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      "Kein Ergebnis gefunden",
                      style: Fonts.text300,
                    ),
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
