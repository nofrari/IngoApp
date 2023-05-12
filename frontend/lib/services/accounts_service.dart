import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setManualEntry(String pdfName, String pdfPath, int pdfHeight,
      String supplierName, int amount, String date, String category) async {
    try {
      Map<String, dynamic> manualEntryMap = {
        "pdf_name": pdfName,
        "pdf_path": pdfPath,
        "pdf_height": pdfHeight,
        "supplier_name": supplierName,
        "amount": amount,
        "date": date,
        "category": category
      };
      _prefs.setString('manualEntry', jsonEncode(manualEntryMap));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map<String, dynamic> getManualEntry() {
    try {
      Map<String, dynamic> manualEntryMap =
          jsonDecode(_prefs.getString('manualEntry') ?? '{}');
      return manualEntryMap;
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<void> forgetManualEntry() async {
    try {
      _prefs.remove('manualEntry');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<String> getImages() {
    debugPrint("gotImages");
    return _prefs.getStringList('images') ?? [];
  }

  Future<void> clearImages() async {
    try {
      _prefs.remove('images');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

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

    debugPrint(accounts.length.toString());

    return accounts;
  }

  Account getAccount(String id) {
    List<Account> accounts = getAccounts();

    //get account where id == id
    Account account = accounts.firstWhere((account) => account.id == id);

    return account;
  }

  //delete account
  Future<void> deleteAccount(String id) async {
    try {
      List<Account> accounts = getAccounts();

      //get account where id == id
      Account account = accounts.firstWhere((account) => account.id == id);

      //get index of account
      int index = accounts.indexOf(account);

      //remove account from accounts
      accounts.removeAt(index);

      setAccounts(accounts: accounts);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      List<String> images = _prefs.getStringList('images') ?? [];
      if (images.isNotEmpty) images.remove(path);
      _prefs.setStringList('images', images);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
