import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/budget.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/pages/budget/budget_add.dart';
import 'package:frontend/services/budget_service.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/three_dot_menu.dart';
import 'package:frontend/widgets/transactions/transaction_list.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/budget/budget_card.dart';
import '../../widgets/header.dart';
import '../../widgets/text_google.dart';

Future<List<BudgetModel>> getData(BuildContext context) async {
  try {
    Response response = await Dio().get(
        '${Values.serverURL}/budgets/list/${context.read<ProfileService>().getUser().id}');
    List<BudgetModel> fetchedBudgets = [];
    for (var i = 0; i < response.data.length; i++) {
      List<String> categoryIds =
          (response.data[i]['categories'] as List<dynamic>)
              .map((category) => category['category_id'].toString())
              .toList();
      DateTime? startDate =
          DateTime.tryParse(response.data[i]['startdate'] as String);
      DateTime? endDate =
          DateTime.tryParse(response.data[i]['enddate'] as String);
      fetchedBudgets.add(
        BudgetModel(
          budget_id: response.data[i]['budget_id'].toString(),
          budget_name: response.data[i]['budget_name'].toString(),
          budget_amount:
              double.parse(response.data[i]['budget_amount'].toString()),
          startdate: DateTime.parse(response.data[i]['startdate'] as String),
          enddate: DateTime.parse(response.data[i]['enddate'] as String),
          categoryIds: categoryIds,
        ),
      );
    }
    context.read<BudgetService>().setBudgets(fetchedBudgets);

    return fetchedBudgets;
  } catch (e) {
    print(e);
    return [];
  }
}

class BudgetTransactionList extends StatefulWidget {
  BudgetTransactionList({required this.transactions, super.key});

  List<TransactionModel> transactions;

  @override
  State<BudgetTransactionList> createState() => _BudgetTransactionListState();
}

class _BudgetTransactionListState extends State<BudgetTransactionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        onTap: () {
          Navigator.pop(context);
        },
        element: TextGoogle(
          align: TextAlign.center,
          text: Strings.budgetTransactionsList.toUpperCase(),
          style: Fonts.text400,
        ),
      ),
      backgroundColor: AppColor.backgroundFullScreen,
      body: Padding(
        padding: Values.accountHeading,
        child: Container(
          child: SingleChildScrollView(
            child: TransactionList(
              transactions: widget.transactions,
            ),
          ),
        ),
      ),
    );
  }
}
