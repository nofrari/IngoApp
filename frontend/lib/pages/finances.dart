import 'dart:io';

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
import 'package:fl_chart/fl_chart.dart';
import '../constants/values.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/initial_service.dart';
import '../services/transaction_service.dart';
import '../widgets/input_fields/datepicker_field.dart';
import '../widgets/input_fields/input_field.dart';

import '../constants/fonts.dart';
import '../widgets/tag.dart';

class Finances extends StatefulWidget {
  Finances({this.accountId, this.onFocusChanged, super.key});
  String? accountId;
  //needed to disable floating action button in menu bar when keyboard appears
  final ValueChanged<bool>? onFocusChanged;
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
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s\.]"));

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
    selectedAccount = values.join(", ");
  }

  void handleCategoryTagsChanged(List<String> tags) {
    setState(() {
      selectedCategoryTags = tags;
    });
  }

  void handleAccountTagsChanged(List<String> tags) {
    setState(() {
      selectedAccountTags = tags;
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
            if (selectedAccountTags.contains(item)) {
              selectedAccountTags.remove(item);
            }
          });
          onAccountSelected(selectedAccountTags);
          debugPrint(
              "selected account tags after remove: ${selectedAccountTags.toList().toString()}");
        },
      );
    }));

    return tags;
  }

  List<FlSpot> generateSpots(List<TransactionModel> transactions) {
    List<FlSpot> spots = [];
    for (var transaction in transactions) {
      spots.add(FlSpot(
        double.parse(transaction.date.millisecondsSinceEpoch.toString()),
        double.parse(transaction.type_id == "1"
            ? transaction.transaction_amount.toString()
            : (transaction.transaction_amount * -1).toString()),
      ));
    }
    return spots;
  }

  double getMinY(List<TransactionModel> transactions) {
    double min = 0;
    for (var transaction in transactions) {
      if (transaction.type_id == "1") {
        if (transaction.transaction_amount < min) {
          min = transaction.transaction_amount;
        }
      } else {
        if ((transaction.transaction_amount * -1) < min) {
          min = transaction.transaction_amount * -1;
        }
      }
    }
    return min - 20;
  }

  double getMaxY(List<TransactionModel> transactions) {
    double max = 0;
    for (var transaction in transactions) {
      if (transaction.type_id == "1") {
        if (transaction.transaction_amount > max) {
          max = transaction.transaction_amount;
        }
      } else {
        if ((transaction.transaction_amount * -1) > max) {
          max = transaction.transaction_amount * -1;
        }
      }
    }
    return max + 20;
  }

  DateTime getOldesTransaction(List<TransactionModel> transactions) {
    DateTime oldest = DateTime.now();
    for (var transaction in transactions) {
      if (transaction.date.isBefore(oldest)) {
        oldest = transaction.date;
      }
    }
    return oldest;
  }

//function that takes the current transactions list and returns a list of transactions, where transactions with the same date are combined
  List<TransactionModel> combineTransactions(
      List<TransactionModel> transactions) {
    List<TransactionModel> combinedTransactions = [];
    List<DateTime> dates = [];
    for (var transaction in transactions) {
      if (!dates.contains(transaction.date)) {
        dates.add(transaction.date);
      }
    }
    for (var date in dates) {
      double amount = 0;
      for (var transaction in transactions) {
        if (transaction.date == date) {
          amount = transaction.type_id == "1"
              ? transaction.transaction_amount + amount
              : transaction.transaction_amount * -1 + amount;
          //transactions.remove(transaction);
        }
      }
      combinedTransactions.add(
        TransactionModel(
          transaction_id: "1",
          transaction_name: "Test",
          transaction_amount: amount,
          date: date,
          type_id: amount < 0 ? "2" : "1",
          category_id: "clirgqhkk0001dy50dboh7b9l",
          interval_id: "1",
          account_id: "",
        ),
      );
    }
    return combinedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    transactions = context.watch<TransactionService>().getTransactions();
    categories = context.watch<InitialService>().getCategories();
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
    accounts = context.watch<AccountsService>().getAccounts();

    if (widget.accountId != null && widget.accountId != "") {
      accountSelectedFromHome =
          context.watch<AccountsService>().getAccount(widget.accountId ?? "");
      debugPrint(
          "account selected name: ${accountSelectedFromHome!.name.toString()}");

      setState(() {
        selectedAccountTags = [accountSelectedFromHome!.name];
      });

      onAccountSelected(selectedAccountTags);
      handleAccountTagsChanged(selectedAccountTags);

      setState(() {
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
            Container(
                // height: filteredTransactions.length * 55,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.neutral500,
                    width: 0,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  color: AppColor.neutral500,
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        enabled: false,
                      ),
                      gridData: FlGridData(
                        show: false,
                      ),
                      titlesData: FlTitlesData(
                        show: false,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      minY: getMinY(transactions),
                      maxY: getMaxY(transactions),
                      maxX: DateTime.now().millisecondsSinceEpoch.toDouble(),
                      minX: getOldesTransaction(transactions)
                          .millisecondsSinceEpoch
                          .toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots:
                              generateSpots(combineTransactions(transactions)),
                          // [
                          //   FlSpot(0, 0),
                          //   FlSpot(1, 1),
                          //   FlSpot(2, 2),
                          //   FlSpot(3, 3),
                          //   FlSpot(4, 4),
                          //   FlSpot(5, -5),
                          //   FlSpot(6, 6),
                          //   FlSpot(7, 7),
                          //   FlSpot(8, 8),
                          //   FlSpot(9, 9),
                          //   FlSpot(10, 10),
                          //   FlSpot(11, 11),
                          //   FlSpot(12, 12),
                          //   FlSpot(13, 13),
                          //   FlSpot(14, 14),
                          //   FlSpot(15, 15),
                          //   FlSpot(16, 16),
                          //   FlSpot(17, 17),
                          //   FlSpot(18, 18),
                          //   FlSpot(19, 19),
                          //   FlSpot(20, 20),
                          //   FlSpot(21, 21),
                          //   FlSpot(22, 22),
                          //   FlSpot(23, 23),
                          //   FlSpot(24, 24),
                          //   FlSpot(25, 25),
                          //   FlSpot(26, 26),
                          //   FlSpot(27, 27),
                          //   FlSpot(28, 28),
                          //   FlSpot(29, 29),
                          //   FlSpot(30, 30),
                          //   FlSpot(31, 31),
                          // ],
                          isCurved: true,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
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
              onFocusChanged: widget.onFocusChanged ?? (value) {},
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
                            return "Startdatum darf nicht\nnach dem Enddatum\nliegen";
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
                            return "Enddatum darf nicht\nvor dem Startdatum\nliegen";
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
                      hintText: "Kategorie",
                      width: (MediaQuery.of(context).size.width -
                                  Values.bigCardMargin.horizontal) /
                              2 -
                          5,
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
                      hintText: "Konto",
                      width: (MediaQuery.of(context).size.width -
                                  Values.bigCardMargin.horizontal) /
                              2 -
                          5,
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
                ? Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: TransactionList(
                      accounts: selectedAccount,
                      selectedCategory: selectedCategory,
                      startDate: selectedStartDate,
                      endDate: selectedEndDate,
                      transactions: filteredTransactions.isEmpty
                          ? transactions //combineTransactions(transactions) //
                          : filteredTransactions,
                    ),
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
