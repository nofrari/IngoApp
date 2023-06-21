import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/budget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setBudgets(List<BudgetModel> budgets) async {
    try {
      List<String> budgetsString =
          budgets.map((budget) => jsonEncode(budget.toJson())).toList();
      _prefs.setStringList('budgets', budgetsString);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> setBudget(BudgetModel budget) async {
    try {
      String budgetString = jsonEncode(budget.toJson());
      _prefs.setString('budget', budgetString);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearBudget() async {
    try {
      _prefs.remove('budget');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  BudgetModel? getBudget() {
    String budgetString = _prefs.getString('budget') ?? "";

    try {
      BudgetModel budget = BudgetModel.fromJson(jsonDecode(budgetString));
      return budget;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  List<BudgetModel> getBudgets() {
    List<String> budgetStrings = _prefs.getStringList('budgets') ?? [];

    List<BudgetModel> budgets = budgetStrings
        .map((budgetString) => BudgetModel.fromJson(jsonDecode(budgetString)))
        .toList();

    return budgets;
  }
}
