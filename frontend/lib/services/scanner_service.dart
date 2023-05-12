import 'package:flutter/material.dart';
import 'package:frontend/services/custom_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:provider/provider.dart';

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

  Future<void> setImage({required String path, int? position}) async {
    try {
      List<String> images = _prefs.getStringList('images') ?? [];
      if (images.isNotEmpty && position != null) {
        images[position] = path;
      } else {
        images.add(path);
      }
      _prefs.setStringList('images', images);
      for (var element in images) {
        debugPrint(element);
      }
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

  Future<void> rememberPosition(int position) async {
    try {
      _prefs.setInt('position', position);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> forgetPosition() async {
    try {
      _prefs.remove('position');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  int? getPosition() {
    return _prefs.getInt('position');
  }
}
