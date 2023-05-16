import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/categories/categories.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';

import '../../constants/values.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
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
        itemCount: widget.transactions.length,
        itemBuilder: (context, index) {
          final transaction = widget.transactions[index];
          return TransactionItem(transaction: transaction);
        },
      ),
    );
  }
}
