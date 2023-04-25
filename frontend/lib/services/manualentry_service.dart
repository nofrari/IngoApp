import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualEntryService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setManualEntry(String pdfName, String pdfPath,
      String supplierName, int amount, String date, String category) async {
    try {
      Map<String, dynamic> manualEntryMap = {
        "pdf_name": pdfName,
        "pdf_path": pdfPath,
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
}
