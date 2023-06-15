import 'package:intl/intl.dart';

class BudgetModel {
  BudgetModel({
    required this.budget_id,
    required this.budget_name,
    required this.budget_amount,
    required this.categoryIds, // Update to store category IDs
    required this.startdate,
    required this.enddate,
  });

  final String budget_id;
  final String budget_name;
  double budget_amount;
  List<String>
      categoryIds; // Store category IDs instead of CategoryModel objects
  final DateTime startdate;
  final DateTime enddate;

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

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        "budget_id": budget_id,
        "budget_name": budget_name,
        "budget_amount": budget_amount,
        'categoryIds': categoryIds,
        "startdate": startdate,
        "enddate": enddate,
      };

  // Convert JSON to model
  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        budget_id: json["budget_id"],
        budget_name: json["budget_name"],
        budget_amount: json["budget_amount"],
        categoryIds:
            List<String>.from(json["categoryIds"]), // Deserialize category IDs
        startdate: json["startdate"],
        enddate: json["enddate"],
      );

  bool isCompleted() {
    if (budget_name != "" &&
        budget_amount != 0 &&
        categoryIds.isNotEmpty &&
        startdate != DateTime(2000) &&
        enddate != DateTime(2000)) {
      return true;
    } else {
      return false;
    }
  }
}
