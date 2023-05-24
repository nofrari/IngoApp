import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/pages/categories/categories.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/services/profile_service.dart';
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
import '../models/interval.dart' as TransactionInterval;
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
  final List<TransactionInterval.IntervalModel> interval = [];
  List<TransactionModel> _latestTransactions = [];

  void _getTransactions() async {
    try {
      Response response = await Dio().get(
          '${Values.serverURL}/transactions/list/${context.read<ProfileService>().getUser().id}');

      var latestFiveTransactions = await Dio().get(
          '${Values.serverURL}/transactions/fivelatest/${context.read<ProfileService>().getUser().id}');

      List<TransactionModel> transactions = [];
      List<TransactionModel> latestTransactions = [];

      for (var transaction in response.data) {
        transactions.add(
          TransactionModel(
              transaction_id: transaction['transaction_id'].toString(),
              transaction_name: transaction['transaction_name'].toString(),
              transaction_amount:
                  double.parse(transaction['transaction_amount'].toString()),
              category_id: transaction['category_id'].toString(),
              date: DateTime.parse(transaction['date']),
              type_id: (transaction['type_id']).toString(),
              description: transaction['description'].toString(),
              interval_id: transaction['interval_id'].toString(),
              account_id: transaction['account_id'].toString()),
        );
      }
      for (var latestTransaction in latestFiveTransactions.data) {
        latestTransactions.add(
          TransactionModel(
              transaction_id: latestTransaction['transaction_id'].toString(),
              transaction_name:
                  latestTransaction['transaction_name'].toString(),
              transaction_amount: double.parse(
                  latestTransaction['transaction_amount'].toString()),
              category_id: latestTransaction['category_id'].toString(),
              date: DateTime.parse(latestTransaction['date']),
              type_id: (latestTransaction['type_id']).toString(),
              description: latestTransaction['description'].toString(),
              interval_id: latestTransaction['interval_id'].toString(),
              account_id: latestTransaction['account_id'].toString()),
        );
      }
      await context.read<TransactionService>().setTransactions(transactions);
      setState(() {
        _latestTransactions = latestTransactions;
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
      Response response = await Dio().get(
          '${Values.serverURL}/categories/${context.read<ProfileService>().getUser().id}');
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
      Response response = await Dio().get(
          '${Values.serverURL}/accounts/list/${context.read<ProfileService>().getUser().id}');

      for (var i = 0; i < response.data.length; i++) {
        accounts.add(Account(
          id: response.data[i]['account_id'].toString(),
          name: response.data[i]['account_name'].toString(),
          amount: double.parse(response.data[i]['account_balance'].toString()),
        ));
      }

      await context.read<AccountsService>().setAccounts(accounts: accounts);

      setState(() {
        allAccounts = accounts;
      });
    } catch (e) {
      print(e);
    }
  }

  List<Account> allAccounts = [];

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
