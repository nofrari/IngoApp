import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static IconData barChart = Icons.bar_chart;
  static IconData cookie = Icons.cookie;
  static IconData add = Icons.add;
  static IconData delete = Icons.delete;
  static IconData dollar = Icons.attach_money_outlined;
  static IconData train = Icons.train_outlined;
  static IconData workBag = Icons.work_outline_outlined;
  static IconData stroller = Icons.child_friendly_outlined;
  static IconData gift = Icons.redeem_outlined;
  static IconData banknote = Icons.local_atm_outlined;
  static IconData restaurant = Icons.restaurant_outlined;
  static IconData car = Icons.directions_car_outlined;
  static IconData music = Icons.play_circle_outline;

  static Map<String, IconData> icons = {
    'dollar': dollar,
    'train': train,
    'workBag': workBag,
    'stroller': stroller,
    'gift': gift,
    'banknote': banknote,
    'restaurant': restaurant,
    'car': car,
    'music': music,
  };

  static IconData? getIconFromString(String iconName) {
    return icons[iconName];
  }
}
