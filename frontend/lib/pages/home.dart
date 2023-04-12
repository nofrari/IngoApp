import 'package:flutter/material.dart';
import 'package:frontend/widgets/transactions/latest_transactions_list.dart';
//import constants
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/values.dart';

import '../models/transaction.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Transaction> _latestTransactions = [
    Transaction(
      id: 1,
      name: "EBI",
      amount: 20,
      category: "Shop",
      date: DateTime(2022, 9, 9),
    ),
    Transaction(
      id: 2,
      name: "EBI 2",
      amount: 30.30,
      category: "Shop",
      date: DateTime(2021, 9, 9),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      color: AppColor.neutral500,
      child: Column(
        children: <Widget>[
          LatestTransactionList(transactions: _latestTransactions),
        ],
      ),
    );
  }
}
