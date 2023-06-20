import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/budget.dart';
import 'package:frontend/pages/budget/budget_add.dart';
import 'package:frontend/services/budget_service.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/three_dot_menu.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/budget/budget_card.dart';

Future<List<BudgetModel>> getData(BuildContext context) async {
  try {
    Response response = await Dio().get(
        '${Values.serverURL}/budgets/list/${context.read<ProfileService>().getUser().id}');
    List<BudgetModel> fetchedBudgets = [];
    for (var i = 0; i < response.data.length; i++) {
      Response budgetTransactions = await Dio().get(
          '${Values.serverURL}/transactions/budget/${response.data[i]['budget_id']}');
      debugPrint(budgetTransactions.data['transactionSum'].toString());

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
          curr_amount: budgetTransactions.data['transactionSum'].toDouble(),
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

class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  late List<BudgetModel> currentBudgets;
  late List<BudgetModel> pastBudgets;
  late Future<List<BudgetModel>> _budgetsFuture;

  @override
  void initState() {
    currentBudgets = [];
    pastBudgets = [];
    _budgetsFuture = getData(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundFullScreen,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: Values.accountHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    Strings.budgetHeading,
                    style: Fonts.textHeadingBold,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<BudgetModel>>(
                    future: _budgetsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        currentBudgets = snapshot.data!.where((budget) {
                          final currentDate = DateTime.now();
                          return currentDate.isBefore(budget.enddate);
                        }).toList();

                        pastBudgets = snapshot.data!.where((budget) {
                          final currentDate = DateTime.now();
                          return currentDate.isAfter(budget.enddate);
                        }).toList();

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentBudgets.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Aktuelle Budgets:',
                                    style: Fonts.text200,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              for (final budget in currentBudgets)
                                BudgetCard(
                                  budget: budget,
                                  isOld: false,
                                ),
                              if (pastBudgets.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Vergangene Budgets:',
                                    style: Fonts.text200,
                                  ),
                                ),
                              for (final budget in pastBudgets)
                                BudgetCard(
                                  budget: budget,
                                  isOld: true,
                                ),
                              SizedBox(
                                height: 80,
                              )
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          ButtonTransparentContainer(
            child: Container(
              margin: Values.buttonPadding,
              child: Button(
                isTransparent: true,
                btnText: Strings.budgetButton,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetAdd(),
                    ),
                  );
                },
                theme: ButtonColorTheme.secondaryDark,
              ),
            ),
          )
        ],
      ),
    );
  }
}
