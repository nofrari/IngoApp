import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setTransactions(List<TransactionModel> transactions) async {
    try {
      List<String> transactionsString = transactions
          .map((transaction) => jsonEncode(transaction.toJson()))
          .toList();
      _prefs.setStringList('transactions', transactionsString);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<TransactionModel> getTransactions() {
    List<String> transactionStrings =
        _prefs.getStringList('transactions') ?? [];

    List<TransactionModel> transactions = transactionStrings
        .map((transactionString) =>
            TransactionModel.fromJson(jsonDecode(transactionString)))
        .toList();

    return transactions;
  }
}
