import 'package:frontend/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';

class LatestTransactionList extends StatefulWidget {
  const LatestTransactionList({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  State<LatestTransactionList> createState() => _LatestTransactionListState();
}

class _LatestTransactionListState extends State<LatestTransactionList> {
  @override
  Widget build(BuildContext context) {
    //for long lists use ListView
    return Column(
      children: widget.transactions
          .map((transaction) => TransactionItem(
                transaction: transaction,
              ))
          .toList(),
    );
  }
}
