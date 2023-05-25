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

  Future<void> setTransaction(TransactionModel transaction) async {
    try {
      String transactionString = jsonEncode(transaction.toJson());
      _prefs.setString('transaction', transactionString);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  TransactionModel? getTransaction() {
    String transactionString = _prefs.getString('transaction') ?? "";

    try {
      TransactionModel transaction =
          TransactionModel.fromJson(jsonDecode(transactionString));
      return transaction;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> clearTransaction() async {
    try {
      _prefs.remove('transaction');
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
