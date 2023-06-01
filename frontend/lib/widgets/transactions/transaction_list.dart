import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/models/account.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/initial_service.dart';

class TransactionList extends StatefulWidget {
  const TransactionList(
      {super.key,
      this.selectedCategory,
      this.accounts,
      this.startDate,
      this.endDate,
      required this.transactions});
  final String? selectedCategory;
  final String? accounts;
  final String? startDate;
  final String? endDate;
  final List<TransactionModel> transactions;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<CategoryModel> categoriesList = [];
  List<Account> accountList = [];

  @override
  Widget build(BuildContext context) {
    categoriesList = context.watch<InitialService>().getCategories();
    accountList = context.watch<AccountsService>().getAccounts();

    List<TransactionModel> filteredTransactions = widget.transactions;
    List<String> selectedCategories = [];
    List<String> selectedAccounts = [];
    List<CategoryModel> desiredCategories = [];
    List<Account> desiredAccounts = [];

    String formatDate(String inputDate) {
      if (inputDate.contains("/")) {
        DateFormat inputFormat = DateFormat('dd / MM / yyyy');
        DateFormat outputFormat = DateFormat('yyyy-MM-dd');
        DateTime date = inputFormat.parse(inputDate);

        String outputDate = outputFormat.format(date);

        return outputDate;
      } else {
        return inputDate;
      }
    }

    if (widget.selectedCategory != null && widget.selectedCategory != "") {
      selectedCategories = widget.selectedCategory!
          .split(',')
          .map((category) => category.trim())
          .toList();
      desiredCategories = categoriesList
          .where((category) => selectedCategories.contains(category.label))
          .toList();
    }

    if (widget.accounts != null && widget.accounts != "") {
      selectedAccounts =
          widget.accounts!.split(',').map((account) => account.trim()).toList();
      desiredAccounts = accountList
          .where((account) => selectedAccounts.contains(account.name))
          .toList();
    }

    String? formateStartDate;
    if (widget.startDate != null && widget.startDate != "") {
      formateStartDate = formatDate(widget.startDate!);
    }
    String? formateEndDate;
    if (widget.endDate != null && widget.endDate != "") {
      formateEndDate = formatDate(widget.endDate!);
    }

    filteredTransactions = filteredTransactions.where((transaction) {
      bool categoryFilter = true;
      bool accountFilter = true;
      bool dateFilter = true;

      if (desiredCategories.isNotEmpty) {
        categoryFilter = desiredCategories
            .any((category) => transaction.category_id == category.category_id);
      }

      if (desiredAccounts.isNotEmpty) {
        accountFilter = desiredAccounts
            .any((account) => transaction.account_id == account.id);
      }

      if (formateEndDate != null && formateEndDate != "" ||
          formateStartDate != null && formateStartDate != "") {
        if (formateEndDate != null &&
            formateEndDate != "" &&
            formateStartDate != null &&
            formateStartDate != "") {
          dateFilter = transaction.date
                  .isAfter(DateTime.parse(formateStartDate)) &&
              transaction.date.isBefore(
                  DateTime.parse(formateEndDate).add(const Duration(days: 1)));
        } else {
          if (formateEndDate != null && formateEndDate != "") {
            dateFilter = transaction.date.isBefore(
                DateTime.parse(formateEndDate).add(const Duration(days: 1)));
          } else {
            dateFilter =
                transaction.date.isAfter(DateTime.parse(formateStartDate!));
          }
        }
      }

      return categoryFilter && accountFilter && dateFilter;
    }).toList();

    //for long lists use ListView
    return filteredTransactions.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.neutral500,
                width: 0,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(30),
              color: AppColor.neutral500,
            ),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return TransactionItem(transaction: transaction);
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text("Kein Ergebnis gefunden", style: Fonts.text300),
          );
  }
}
