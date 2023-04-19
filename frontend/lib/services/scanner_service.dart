import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ScannerService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  // Future<void> loginUser(String userName) async {
  //   try {
  //     _prefs.setString('userName', userName);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<bool> isLoggedIn() async {
  //   String? username = await _prefs.getString('userName');
  //   if (username == null) return false;
  //   return true;
  // }

  // void logoutUser() {
  //   _prefs.clear();
  // }

  // String? getUserName() {
  //   return _prefs.getString('userName') ?? 'DefaultValue';
  // }

  // void updateUserName(String newName) {
  //   _prefs.setString('userName', newName);
  //   notifyListeners();
  // }

  List<String> getImages() {
    return _prefs.getStringList('images') ?? [];
  }

  Future<void> clearImages() async {
    try {
      _prefs.remove('images');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> setImage(String path) async {
    try {
      List<String> images = _prefs.getStringList('images') ?? [];
      images.add(path);
      _prefs.setStringList('images', images);
      for (var element in images) {
        debugPrint(element);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
