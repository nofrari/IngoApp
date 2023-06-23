import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/budget.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/pages/budget/budget_add.dart';
import 'package:frontend/pages/budget/budget_transaction_list.dart';
import 'package:frontend/pages/finances.dart';
import 'package:frontend/services/budget_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:provider/provider.dart';

import '../../services/initial_service.dart';
import '../../services/profile_service.dart';
import '../tag.dart';
import '../three_dot_menu.dart';

class BudgetCard extends StatefulWidget {
  BudgetCard({
    required this.budget,
    this.isOld,
    super.key,
  });
  final BudgetModel budget;
  bool? isOld = false;

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  final _formKey = GlobalKey<FormState>();
  Dio dio = Dio();
  double currAmount = 0;
  bool isExceeded = false;
  double? ratioOfBudget;

  double getAnteil(double curr, double limit) {
    double ratio = curr / limit;
    double normalizedRatio = ratio > 1.0 ? 1.0 : ratio;
    setState(() {
      ratioOfBudget = ratio;
    });
    setState(() {
      bool isExceeded = ratio > 1.0;
    });
    return ratio;
  }

  Color colorBar(double ratio) {
    if (ratio > 1) {
      return AppColor.redDark;
    } else if (ratio >= 0.5) {
      return AppColor.orange;
    } else {
      return AppColor.greenLight;
    }
  }

  ThreeDotMenuState _budgetCardState = ThreeDotMenuState.collapsed;
  void onStateChanged(ThreeDotMenuState budgetCardState) {
    setState(() {
      _budgetCardState = budgetCardState;
    });
  }

  @override
  void initState() {
    super.initState();
    getAnteil(widget.budget.curr_amount!, widget.budget.budget_amount);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatDateString(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return '$day.$month.$year';
  }

  String formatCurrency(double value) {
    String formattedValue = value.toStringAsFixed(2).replaceAll('.', ',');
    return '$formattedValue €';
  }

  List<CategoryModel> categories = [];
  @override
  Widget build(BuildContext context) {
    categories = context.watch<InitialService>().getCategories();
    List<CategoryModel> desiredCategories = categories
        .where((category) =>
            widget.budget.categoryIds.contains(category.category_id))
        .toList();
    return GestureDetector(
      onTap: () async {
        List<TransactionModel> fetchedTransactions = [];
        try {
          Response response = await Dio().get(
              '${Values.serverURL}/transactions/budget/${widget.budget.budget_id}');
          var responseData = response.data as Map<String, dynamic>;
          var transactions = responseData['transactions'];

          for (var transaction in transactions) {
            fetchedTransactions.add(
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
                interval_subtype_id:
                    transaction['interval_subtype_id'].toString(),
                account_id: transaction['account_id'].toString(),
                bill_url: transaction['bill_url'].toString(),
              ),
            );
          }
        } catch (e) {
          debugPrint(e.toString());
        }

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BudgetTransactionList(transactions: fetchedTransactions)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          top: 15,
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: (widget.isOld != null && widget.isOld == true)
              ? AppColor.neutral550
              : AppColor.neutral500,
          borderRadius: BorderRadius.circular(Values.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.budget.budget_name, style: Fonts.budgetName),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                        "von ${formatDateString(widget.budget.startdate)} bis ${formatDateString(widget.budget.enddate)}",
                        style: Fonts.budgetLimits),
                  ],
                ),
                (_budgetCardState != ThreeDotMenuState.create)
                    ? Container(
                        margin: const EdgeInsets.only(top: 10.0, right: 10),
                        child: Container(
                          width: Values.roundButtonSize,
                          height: Values.roundButtonSize,
                          child: RoundButton(
                              borderWidth: 1.5,
                              onTap: () async {
                                if (widget.isOld == false) {
                                  await context
                                      .read<BudgetService>()
                                      .setBudget(widget.budget);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BudgetAdd(
                                        isEditMode: true,
                                      ),
                                    ),
                                  );
                                } else {
                                  await dio.delete(
                                      "${Values.serverURL}/budgets/delete/${widget.budget.budget_id}");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Start(
                                              pageId: 4,
                                            )),
                                  );
                                }
                              },
                              icon: widget.isOld == true
                                  ? Icons.delete
                                  : Icons.edit,
                              padding: 0.0,
                              iconSize: 20,
                              color: null),
                        ),
                        // ThreeDotMenu(
                        //   onEdit: () async {
                        //     await context
                        //         .read<BudgetService>()
                        //         .setBudget(widget.budget);
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => BudgetAdd(
                        //           isEditMode: true,
                        //         ),
                        //       ),
                        //     );
                        //     setState(() {
                        //       _budgetCardState = ThreeDotMenuState.collapsed;
                        //     });
                        //   },
                        //   state: _budgetCardState,
                        //   onStateChange: onStateChanged,
                        // ),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "${formatCurrency(widget.budget.curr_amount ?? currAmount)} von ${formatCurrency(widget.budget.budget_amount)} ausgegeben",
              style: (ratioOfBudget != null && ratioOfBudget! > 1)
                  ? Fonts.budgetLimitsOver
                  : Fonts.budgetLimits,
            ),
            const SizedBox(
              height: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: LinearProgressIndicator(
                value: getAnteil(widget.budget.curr_amount ?? currAmount,
                    widget.budget.budget_amount),
                minHeight: 20,
                color: colorBar(ratioOfBudget!),
                backgroundColor: AppColor.neutral400,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Wrap(
              spacing: 8,
              children: desiredCategories.map((category) {
                return Tag(
                  noIcon: true,
                  isSmall: true,
                  isCategory: true,
                  btnText: category.label,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
