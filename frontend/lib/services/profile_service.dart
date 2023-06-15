import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _prefs;

  //set User
  Future<void> setUser({
    required String id,
    required String firstname,
    required String lastname,
    required String email,
    required String token,
  }) async {
    try {
      User user = User(
        id: id,
        firstName: firstname,
        lastName: lastname,
        email: email,
        token: token,
      );
      _prefs.setString('user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //get User
  User getUser() {
    try {
      String userString = _prefs.getString('user') ?? "";
      User user = User.fromJson(jsonDecode(userString));
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return User(id: "", firstName: "", lastName: "", email: "", token: "");
    }
  }
}
