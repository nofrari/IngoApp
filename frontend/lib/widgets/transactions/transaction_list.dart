import 'package:frontend/constants/colors.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';
import 'package:provider/provider.dart';
import '../../services/initial_service.dart';

class TransactionList extends StatefulWidget {
  const TransactionList(
      {super.key, this.selectedCategory, required this.transactions});
  final String? selectedCategory;
  final List<TransactionModel> transactions;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<CategoryModel> categories = [];

  @override
  Widget build(BuildContext context) {
    categories = context.watch<InitialService>().getCategories();

    List<TransactionModel> filteredTransactions = widget.transactions;

    if (widget.selectedCategory != null) {
      CategoryModel desiredCategory = categories
          .firstWhere((category) => category.label == widget.selectedCategory);
      filteredTransactions = filteredTransactions
          .where((transaction) =>
              transaction.category_id == desiredCategory.category_id)
          .toList();
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
