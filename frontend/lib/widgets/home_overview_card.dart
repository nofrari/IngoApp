import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/services/transaction_service.dart';
import 'package:frontend/widgets/accounts/accounts_overview.dart';
import 'package:frontend/widgets/transactions/latest_transactions_list.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
//import constants
import '../constants/colors.dart';
import '../constants/values.dart';
import '../models/category.dart';
import '../models/color.dart';
import '../models/icon.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../services/initial_service.dart';

class HomeOverviewCard extends StatefulWidget {
  const HomeOverviewCard({super.key});

  @override
  State<HomeOverviewCard> createState() => _HomeOverviewCardState();
}

class _HomeOverviewCardState extends State<HomeOverviewCard> {
  @override
  void initState() {
    super.initState();
    _getCategories();
    _getTransactions();
    _getAccounts();
  }

  final List<Account> accounts = [];
  List<TransactionModel> _latestTransactions = [];

  void _getTransactions() async {
    try {
      Response response =
          await Dio().get('${Values.serverURL}/transactions/list/1');
      List<TransactionModel> transactions = [];

      for (var i = 0; i < 5 && i < response.data.length; i++) {
        transactions.add(
          TransactionModel(
              transaction_id: response.data[i]['transaction_id'].toString(),
              transaction_name: response.data[i]['transaction_name'].toString(),
              transaction_amount: double.parse(
                  response.data[i]['transaction_amount'].toString()),
              category_id: response.data[i]['category_id'].toString(),
              date: DateTime.parse(response.data[i]['date']),
              type_id: (response.data[i]['type_id']).toString(),
              description: response.data[i]['description'].toString(),
              interval_id: response.data[i]['interval_id'].toString(),
              account_id: response.data[i]['account_id'].toString()),
        );
      }
      await context.read<TransactionService>().setTransactions(transactions);
      setState(() {
        _latestTransactions = transactions;
      });
    } catch (e) {
      print("fehler");
      print(e);
    }
  }

  List<IconModel> icons = [];
  List<ColorModel> colors = [];

  void _getCategories() async {
    try {
      Response response = await Dio().get('${Values.serverURL}/categories/1');
      List<CategoryModel> categoryList = [];

      if (response.data['categories'] != null) {
        for (var category in response.data['categories']) {
          IconModel desiredIcon =
              icons.firstWhere((icon) => icon.icon_id == category['icon_id']);

          ColorModel desiredColor = colors
              .firstWhere((color) => color.color_id == category['color_id']);
          categoryList.add(
            CategoryModel(
              category_id: category['category_id'],
              bgColor: desiredColor.name,
              isWhite: category['is_white'],
              icon: desiredIcon.name,
              label: category['category_name'],
            ),
          );
        }
        context.read<InitialService>().setCategories(categoryList);
      }
    } catch (e) {
      print(e);
    }
  }

  void _getAccounts() async {
    try {
      Response response =
          await Dio().get('${Values.serverURL}/accounts/list/1');

      for (var i = 0; i < response.data.length; i++) {
        accounts.add(Account(
          id: response.data[i]['account_id'].toString(),
          name: response.data[i]['account_name'].toString(),
          amount: double.parse(response.data[i]['account_balance'].toString()),
        ));
      }

      await context.read<AccountsService>().setAccounts(accounts: accounts);

      setState(() {
        _allAccounts = accounts;
      });
    } catch (e) {
      print(e);
    }
  }

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
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
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
