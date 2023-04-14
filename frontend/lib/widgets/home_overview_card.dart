import 'package:flutter/material.dart';
import 'package:frontend/widgets/accounts/accounts_overview.dart';
import 'package:frontend/widgets/transactions/latest_transactions_list.dart';
//import constants
import '../constants/colors.dart';
import '../constants/values.dart';
import '../constants/fonts.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class HomeOverviewCard extends StatefulWidget {
  const HomeOverviewCard({super.key});

  @override
  State<HomeOverviewCard> createState() => _HomeOverviewCardState();
}

class _HomeOverviewCardState extends State<HomeOverviewCard> {
  final List<Transaction> _latestTransactions = [
    Transaction(
      id: 1,
      name: "EBI",
      amount: 20.00,
      category: "Shop",
      date: DateTime(2022, 9, 9),
      description: "Description",
      transactionType: 0,
    ),
    Transaction(
      id: 2,
      name: "EBI 2",
      amount: 30.30,
      category: "Shop",
      date: DateTime(2021, 9, 9),
      description: "Description",
      transactionType: 1,
    ),
  ];
  final List<Account> _accounts = [
    Account(
      id: 1,
      name: "EBI",
      amount: 20,
    ),
    Account(
      id: 2,
      name: "EBI 2",
      amount: 30.30,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Values.cardRadius),
          color: AppColor.neutral500),
      padding: Values.bigCardPadding,
      child: Column(
        children: [
          LatestTransactionList(transactions: _latestTransactions),
          AccountsOverview(
            accounts: _accounts,
          )
        ],
      ),
    );
  }
}
