import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/interval_subtype.dart';
import 'package:frontend/models/transaction_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/color.dart';
import '../models/icon.dart' as icon;
import '../models/interval.dart' as interval;
import '../models/transaction_type.dart' as type;

class InitialService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setCategories(List<CategoryModel> categories) async {
    try {
      List<String> categoriesStrings =
          categories.map((category) => jsonEncode(category.toJson())).toList();
      _prefs.setStringList('categories', categoriesStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<CategoryModel> getCategories() {
    List<String> categoryStrings = _prefs.getStringList('categories') ?? [];

    List<CategoryModel> categories = categoryStrings
        .map((categoryString) =>
            CategoryModel.fromJson(jsonDecode(categoryString)))
        .toList();

    return categories;
  }

  Future<void> setColors(List<ColorModel> colors) async {
    try {
      List<String> colorStrings =
          colors.map((color) => jsonEncode(color.toJson())).toList();

      debugPrint("length: ${colorStrings.length.toString()}");
      _prefs.setStringList('colors', colorStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<ColorModel> getColors() {
    List<String> colorStrings = _prefs.getStringList('colors') ?? [];

    List<ColorModel> colors = colorStrings
        .map((colorString) => ColorModel.fromJson(jsonDecode(colorString)))
        .toList();

    return colors;
  }

  Future<void> setIcons(List<icon.IconModel> icons) async {
    try {
      List<String> iconsStrings =
          icons.map((icon) => jsonEncode(icon.toJson())).toList();
      _prefs.setStringList('icons', iconsStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<icon.IconModel> getIcons() {
    List<String> iconsStrings = _prefs.getStringList('icons') ?? [];

    List<icon.IconModel> icons = iconsStrings
        .map((iconString) => icon.IconModel.fromJson(jsonDecode(iconString)))
        .toList();

    return icons;
  }

  Future<void> setInterval(List<interval.IntervalModel> interval) async {
    try {
      List<String> intervalStrings =
          interval.map((interval) => jsonEncode(interval.toJson())).toList();
      _prefs.setStringList('interval', intervalStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<interval.IntervalModel> getInterval() {
    List<String> intervalStrings = _prefs.getStringList('interval') ?? [];

    List<interval.IntervalModel> intervals = intervalStrings
        .map((intervalStrings) =>
            interval.IntervalModel.fromJson(jsonDecode(intervalStrings)))
        .toList();

    return intervals;
  }

  Future<void> setIntervalSubtype(List<IntervalSubtypeModel> interval) async {
    try {
      List<String> intervalSubtypeStrings = interval
          .map((intervalSubtype) => jsonEncode(intervalSubtype.toJson()))
          .toList();
      _prefs.setStringList('intervalSubtypes', intervalSubtypeStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<IntervalSubtypeModel> getIntervalSubtypes() {
    List<String> intervalSubtypeStrings =
        _prefs.getStringList('intervalSubtypes') ?? [];

    List<IntervalSubtypeModel> intervalSubtypes = intervalSubtypeStrings
        .map((intervalStrings) =>
            IntervalSubtypeModel.fromJson(jsonDecode(intervalStrings)))
        .toList();

    return intervalSubtypes;
  }

  Future<void> setTransactionType(List<type.TransactionType> type) async {
    try {
      List<String> typeStrings =
          type.map((type) => jsonEncode(type.toJson())).toList();
      _prefs.setStringList('transactionType', typeStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<type.TransactionType> getTransactionType() {
    List<String> typeStrings = _prefs.getStringList('transactionType') ?? [];

    List<type.TransactionType> types = typeStrings
        .map((typeStrings) =>
            type.TransactionType.fromJson(jsonDecode(typeStrings)))
        .toList();

    return types;
  }
}
