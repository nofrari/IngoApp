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

Future<List<TransactionModel>> getTransactions(BuildContext context) async {
  try {
    Response response = await Dio().get(
        '${Values.serverURL}/transactions/list/${context.read<ProfileService>().getUser().id}');

    Response latestFiveTransactions = await Dio().get(
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
          interval_subtype_id: transaction['interval_subtype_id'].toString(),
          account_id: transaction['account_id'].toString(),
          bill_url: transaction['bill_url'].toString(),
        ),
      );
    }
    for (var latestTransaction in latestFiveTransactions.data) {
      latestTransactions.add(
        TransactionModel(
          transaction_id: latestTransaction['transaction_id'].toString(),
          transaction_name: latestTransaction['transaction_name'].toString(),
          transaction_amount:
              double.parse(latestTransaction['transaction_amount'].toString()),
          category_id: latestTransaction['category_id'].toString(),
          date: DateTime.parse(latestTransaction['date']),
          type_id: (latestTransaction['type_id']).toString(),
          description: latestTransaction['description'].toString(),
          interval_id: latestTransaction['interval_id'].toString(),
          interval_subtype_id:
              latestTransaction['interval_subtype_id'].toString(),
          account_id: latestTransaction['account_id'].toString(),
          bill_url: latestTransaction['bill_url'].toString(),
        ),
      );
    }
    await context.read<TransactionService>().setTransactions(transactions);
    return latestTransactions;
  } catch (e) {
    print("fehler");
    print(e);
    return [];
  }
}

class HomeOverviewCard extends StatefulWidget {
  const HomeOverviewCard({super.key});

  @override
  State<HomeOverviewCard> createState() => _HomeOverviewCardState();
}

class _HomeOverviewCardState extends State<HomeOverviewCard> {
  late Future<bool> _loaded;
  @override
  void initState() {
    super.initState();
    _loaded = _loadData();
  }

  Future<bool> _loadData() async {
    await _getCategories();
    List<TransactionModel> latestTransactionsTemp =
        await getTransactions(context);
    setState(() {
      _latestTransactions = latestTransactionsTemp;
    });
    await _getAccounts();
    return Future.value(true);
  }

  final List<Account> accounts = [];
  final List<TransactionInterval.IntervalModel> interval = [];
  List<TransactionModel> _latestTransactions = [];

  List<IconModel> icons = [];
  List<ColorModel> colors = [];

  Future<void> _getCategories() async {
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
        await context.read<InitialService>().setCategories(categoryList);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getAccounts() async {
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
      child: FutureBuilder(
        future: _loaded,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                LatestTransactionList(transactions: _latestTransactions),
                AccountsOverview(
                  accounts: accounts,
                )
              ],
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(30.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
