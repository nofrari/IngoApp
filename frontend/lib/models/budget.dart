import 'package:intl/intl.dart';

class BudgetModel {
  BudgetModel(
      {required this.budget_id,
      required this.budget_name,
      required this.budget_limit,
      required this.category_id,
      this.budget_currAmount,
      required this.budget_start,
      required this.interval_id});

  final String budget_id;
  final String budget_name;
  double budget_limit;
  String category_id;
  double? budget_currAmount;
  final DateTime budget_start;
  String interval_id;

  String formatedAmount(double amount) {
    var formatter = NumberFormat('#,##0.00', 'de_DE');
    String formattedNumber = formatter.format(amount);

    return "$formattedNumber €";
  }

  String formatedDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return '$day.$month.$year';
  }

  //convert model to json
  Map<String, dynamic> toJson() => {
        "id": budget_id,
        "name": budget_name,
        "limit": budget_limit,
        'category_id': category_id,
        "amount": budget_currAmount,
        "start": budget_start,
        'interval_id': interval_id,
      };

  //convert json to model
  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        budget_id: json["id"],
        budget_name: json["name"],
        budget_limit: json["limit"],
        category_id: json["category_id"],
        budget_currAmount: json["amount"],
        budget_start: json["start"],
        interval_id: json["interval_id"],
      );

  bool isCompleted() {
    if (budget_name != "" &&
        budget_limit != 0 &&
        category_id != "" &&
        budget_start != DateTime(2000) &&
        interval_id != "") {
      return true;
    } else {
      return false;
    }
  }
}
