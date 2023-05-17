import 'package:frontend/constants/colors.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';
import 'package:provider/provider.dart';
import '../../models/account.dart';
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
  List<CategoryModel> categories = [];
  List<Account> accounts = [];

  @override
  Widget build(BuildContext context) {
    categories = context.watch<InitialService>().getCategories();
    accounts = context.watch<AccountsService>().getAccounts();

    List<TransactionModel> filteredTransactions = widget.transactions;

    if ((widget.selectedCategory != null && widget.selectedCategory != "") ||
        (widget.accounts != null && widget.accounts != "")) {
      List<String> selectedCategories = widget.selectedCategory!
          .split(',')
          .map((category) => category.trim())
          .toList();
      List<String> selectedAccounts =
          widget.accounts!.split(',').map((account) => account.trim()).toList();
      List<CategoryModel> desiredCategories = categories
          .where((category) => selectedCategories.contains(category.label))
          .toList();
      List<Account> desiredAccounts = accounts
          .where((account) => selectedAccounts.contains(account.name))
          .toList();

      filteredTransactions = filteredTransactions.where((transaction) {
        bool categoryFilter = true;
        bool accountFilter = true;

        if (desiredCategories.isNotEmpty) {
          categoryFilter = desiredCategories.any(
              (category) => transaction.category_id == category.category_id);
        }

        if (desiredAccounts.isNotEmpty) {
          accountFilter = desiredAccounts
              .any((account) => transaction.account_id == account.id);
        }

        return categoryFilter && accountFilter;
      }).toList();
    }
    //for long lists use ListView
    return Container(
      margin: const EdgeInsets.only(top: 20),
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
    );
  }
}
