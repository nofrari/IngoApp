import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/color.dart';
import '../models/icon.dart' as icon;

class InitialService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  Future<void> setCategories(List<Category> categories) async {
    try {
      List<String> categoriesStrings =
          categories.map((category) => jsonEncode(category.toJson())).toList();
      _prefs.setStringList('categories', categoriesStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Category> getCategories() {
    List<String> categoryStrings = _prefs.getStringList('categories') ?? [];

    List<Category> categories = categoryStrings
        .map((categoryString) => Category.fromJson(jsonDecode(categoryString)))
        .toList();

    return categories;
  }

  Future<void> setColors(List<Color> colors) async {
    try {
      List<String> categoriesStrings =
          colors.map((color) => jsonEncode(color.toJson())).toList();
      _prefs.setStringList('colors', categoriesStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Color> getColors() {
    List<String> colorStrings = _prefs.getStringList('colors') ?? [];

    List<Color> colors = colorStrings
        .map((colorString) => Color.fromJson(jsonDecode(colorString)))
        .toList();

    return colors;
  }

  Future<void> setIcons(List<icon.Icon> icons) async {
    try {
      List<String> iconsStrings =
          icons.map((icon) => jsonEncode(icon.toJson())).toList();
      _prefs.setStringList('icons', iconsStrings);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<icon.Icon> getIcons() {
    List<String> iconsStrings = _prefs.getStringList('icons') ?? [];

    List<icon.Icon> icons = iconsStrings
        .map((iconString) => icon.Icon.fromJson(jsonDecode(iconString)))
        .toList();

    return icons;
  }
}
