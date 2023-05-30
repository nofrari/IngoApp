import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setAccount(
      {required String id,
      required String heading,
      required double balance}) async {
    try {
      List<String> accounts = _prefs.getStringList('accounts') ?? [];
      Account newAccount = Account(id: id, name: heading, amount: balance);
      String newAccountString = jsonEncode(newAccount.toJson());

      accounts.add(newAccountString);
      _prefs.setStringList('accounts', accounts);
      debugPrint("setAccount: ${accounts.length}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //update account
  Future<void> updateAccount(
      {required String id,
      required String heading,
      required double balance}) async {
    try {
      List<Account> accounts = getAccounts();
      Account newAccount = Account(id: id, name: heading, amount: balance);

      //get account where id == id
      Account account = accounts.firstWhere((account) => account.id == id);

      //get index of account
      int index = accounts.indexOf(account);

      //replace account with new account
      accounts[index] = account;

      setAccounts(accounts: accounts);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> setAccounts({required List<Account> accounts}) async {
    try {
      List<String> accountsStrings =
          accounts.map((account) => jsonEncode(account.toJson())).toList();
      _prefs.setStringList('accounts', accountsStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Account> getAccounts() {
    List<String> accountsStrings = _prefs.getStringList('accounts') ?? [];

    List<Account> accounts = accountsStrings
        .map((accountString) => Account.fromJson(jsonDecode(accountString)))
        .toList();

    return accounts;
  }

  Account getAccount(String id) {
    List<Account> accounts = getAccounts();

    //get account where id == id
    Account account = accounts.firstWhere((account) => account.id == id);

    return account;
  }

  //delete account
  Future<void> deleteAccount({required String id, String? newId}) async {
    try {
      List<Account> accounts = getAccounts();

      //get account where id == id
      Account oldAccount = accounts.firstWhere((account) => account.id == id);

      //get index of account
      int indexOldAccount = accounts.indexOf(oldAccount);

      //FIXME: this is not working
      if (newId != null) {
        //get account where id == id
        Account newAccount =
            accounts.firstWhere((account) => account.id == newId);

        //get index of account
        int indexNewAccount = accounts.indexOf(newAccount);

        //add amounts together to new account
        accounts[indexNewAccount].amount =
            newAccount.amount + oldAccount.amount;
      }

      //remove account from accounts
      accounts.removeAt(indexOldAccount);

      for (var account in accounts) {
        debugPrint("account: ${account.name}");
        debugPrint("account amount: ${account.amount}");
      }

      setAccounts(accounts: accounts);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
