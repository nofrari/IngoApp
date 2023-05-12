import 'package:flutter/material.dart';
import 'package:frontend/widgets/accounts/accounts_overview.dart';
import 'package:frontend/widgets/transactions/latest_transactions_list.dart';
import 'package:dio/dio.dart';
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
  @override
  void initState() {
    super.initState();
    _getTransactions();
    _getAccounts();
  }

  final List<Account> accounts = [];

  void _getTransactions() async {
    try {
      Response response =
          await Dio().get('http://localhost:5432/transactions/list/1234');
      List<Transaction> transactions = [];

      for (var i = 0; i < 2 && i < response.data.length; i++) {
        transactions.add(
          Transaction(
              id: response.data[i]['transaction_id'].toString(),
              name: response.data[i]['transaction_name'].toString(),
              amount: double.parse(
                  response.data[i]['transaction_amount'].toString()),
              category: response.data[i]['category_id'].toString(),
              date: DateTime.parse(response.data[i]['date']),
              transactionType: (response.data[i]['type_id']).toString(),
              description: response.data[i]['description'].toString()),
        );
      }
      setState(() {
        _latestTransactions = transactions;
      });
    } catch (e) {
      print("fehler");
      print(e);
    }
  }

  void _getAccounts() async {
    try {
      Response response =
          await Dio().get('http://localhost:5432/accounts/list/1234');

      for (var i = 0; i < response.data.length; i++) {
        accounts.add(Account(
          id: response.data[i]['account_id'].toString(),
          name: response.data[i]['account_name'].toString(),
          amount: double.parse(response.data[i]['account_balance'].toString()),
        ));
      }

      setState(() {
        _allAccounts = accounts;
      });
    } catch (e) {
      print(e);
    }
  }

  List<Transaction> _latestTransactions = [];
  List<Account> _allAccounts = [];

  //  List<Transaction> _latestTransactions = [
  //   Transaction(
  //     id: 1,
  //     name: "EBI",
  //     amount: 20.00,
  //     category: "Shop",
  //     date: DateTime(2022, 9, 9),
  //     description: "Description",
  //     transactionType: 0,
  //   ),
  //   Transaction(
  //     id: 2,
  //     name: "EBI 2",
  //     amount: 30.30,
  //     category: "Shop",
  //     date: DateTime(2021, 9, 9),
  //     description: "Description",
  //     transactionType: 1,
  //   ),
  // ];
  // final List<Account> _accounts = [
  //   Account(
  //     id: 1,
  //     name: "EBI",
  //     amount: 20,
  //   ),
  //   Account(
  //     id: 2,
  //     name: "EBI 2",
  //     amount: 30.30,
  //   ),
  // ];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Values.cardRadius),
          color: AppColor.neutral500),
      padding: Values.bigCardPadding,
      child: Column(
        children: [
          LatestTransactionList(transactions: _latestTransactions),
          AccountsOverview(
            accounts: accounts,
          )
        ],
      ),
    );
  }
}
