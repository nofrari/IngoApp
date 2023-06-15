import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/categories/categories.dart';
import 'package:frontend/pages/userauth.dart';
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
    Dio dio = Dio();
    User user = context.read<ProfileService>().getUser();
    dio.options.headers['authorization'] = 'Bearer ${user.token}';
    Response response =
        await dio.get('${Values.serverURL}/transactions/list/${user.id}');

    debugPrint(response.data.toString());

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
            transfer_account_id: transaction['transfer_account_id'].toString()),
      );
    }
    //add the top five transactions from transaction list to latestTransactions
    var count = 0;
    for (var i = 0; i < transactions.length; i++) {
      latestTransactions.add(transactions[i]);
      count++;
      if (count == 5) {
        break;
      }
    }
    await context.read<TransactionService>().setTransactions(transactions);
    return latestTransactions;
  } on DioError catch (dioError) {
    debugPrint(dioError.toString());
    logOut(dioError, context);
    return [];
  } catch (e) {
    print("fehler");
    debugPrint(e.toString());
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
      Dio dio = Dio();
      User user = context.read<ProfileService>().getUser();
      dio.options.headers['authorization'] = 'Bearer ${user.token}';
      Response response =
          await dio.get('${Values.serverURL}/categories/${user.id}');
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
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      logOut(dioError, context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getAccounts() async {
    try {
      Dio dio = Dio();
      User user = context.read<ProfileService>().getUser();
      dio.options.headers['authorization'] = 'Bearer ${user.token}';
      Response response =
          await dio.get('${Values.serverURL}/accounts/list/${user.id}');

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
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      logOut(dioError, context);
    } catch (e) {
      debugPrint(e.toString());
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
