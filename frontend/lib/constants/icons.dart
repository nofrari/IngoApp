import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static IconData barChart = Icons.bar_chart;
  static IconData cookie = Icons.cookie;
  static IconData add = Icons.add;
  static IconData delete = Icons.delete;

  static Map<String, IconData> icons = {
    'barChart': barChart,
    'cookie': cookie,
    'add': add,
    'delete': delete
  };

  static IconData? getIconFromString(String iconName) {
    return icons[iconName];
  }
}
