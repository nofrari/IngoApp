import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/models/account.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';
import 'package:provider/provider.dart';
import '../../services/initial_service.dart';

class TransactionList extends StatefulWidget {
  const TransactionList(
      {super.key,
      this.selectedCategory,
      this.accounts,
      required this.transactions});
  final String? selectedCategory;
  final String? accounts;
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

    filteredTransactions = filteredTransactions.where((transaction) {
      bool categoryFilter = true;
      bool accountFilter = true;

      if (desiredCategories.isNotEmpty) {
        categoryFilter = desiredCategories
            .any((category) => transaction.category_id == category.category_id);
      }

      if (desiredAccounts.isNotEmpty) {
        accountFilter = desiredAccounts
            .any((account) => transaction.account_id == account.id);
      }

      return categoryFilter && accountFilter;
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
