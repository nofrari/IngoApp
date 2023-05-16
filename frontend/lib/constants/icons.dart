import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcons {
  AppIcons._();

  //Icons for categories
  static IconData gift = FontAwesomeIcons.gift;
  static IconData dolllarSign = FontAwesomeIcons.dollarSign;
  static IconData train = FontAwesomeIcons.train;
  static IconData babyCarriage = FontAwesomeIcons.babyCarriage;
  static IconData shoppingBag = FontAwesomeIcons.bagShopping;
  static IconData suitcase = FontAwesomeIcons.suitcase;
  static IconData scissors = FontAwesomeIcons.scissors;
  static IconData eating = FontAwesomeIcons.utensils;
  static IconData car = FontAwesomeIcons.car;
  static IconData baby = FontAwesomeIcons.baby;
  static IconData shirt = FontAwesomeIcons.shirt;
  static IconData plane = FontAwesomeIcons.plane;
  static IconData paw = FontAwesomeIcons.paw;
  static IconData parking = FontAwesomeIcons.squareParking;
  static IconData music = FontAwesomeIcons.music;
  static IconData dumbbell = FontAwesomeIcons.dumbbell;
  static IconData drinking = FontAwesomeIcons.martiniGlassCitrus;
  static IconData wine = FontAwesomeIcons.wineBottle;
  static IconData beer = FontAwesomeIcons.beerMugEmpty;
  static IconData smoking = FontAwesomeIcons.smoking;
  static IconData graduation = FontAwesomeIcons.graduationCap;
  static IconData home = FontAwesomeIcons.house;
  static IconData phone = FontAwesomeIcons.phone;
  static IconData people = FontAwesomeIcons.users;
  static IconData amazon = FontAwesomeIcons.amazon;
  static IconData spotify = FontAwesomeIcons.spotify;
  static IconData video = FontAwesomeIcons.video;
  static IconData book = FontAwesomeIcons.book;
  static IconData gasPump = FontAwesomeIcons.gasPump;
  static IconData coffee = FontAwesomeIcons.mugSaucer;
  static IconData wrench = FontAwesomeIcons.wrench;
  static IconData medical = FontAwesomeIcons.briefcaseMedical;
  static IconData running = FontAwesomeIcons.personRunning;
  static IconData swimming = FontAwesomeIcons.personSwimming;
  static IconData shoppingCart = FontAwesomeIcons.cartShopping;
  static IconData star = FontAwesomeIcons.star;

  static Map<String, IconData> icons = {
    "gift": gift,
    "dollarSign": dolllarSign,
    "train": train,
    "babyCarriage": babyCarriage,
    "shoppingBag": shoppingBag,
    "suitcase": suitcase,
    "scissors": scissors,
    "eating": eating,
    "car": car,
    "baby": baby,
    "shirt": shirt,
    "plane": plane,
    "paw": paw,
    "parking": parking,
    "music": music,
    "dumbbell": dumbbell,
    "driking": drinking,
    "wine": wine,
    "beer": beer,
    "smoking": smoking,
    "graduation": graduation,
    "home": home,
    "phone": phone,
    "people": people,
    "amazon": amazon,
    "spotify": spotify,
    "video": video,
    "book": book,
    "gasPump": gasPump,
    "coffee": coffee,
    "wrench": wrench,
    "medical": medical,
    "running": running,
    "swimming": swimming,
    "shoppingCart": shoppingCart,
    "star": star,
  };

  static IconData? getIconFromString(String iconName) {
    return icons[iconName];
  }
}
