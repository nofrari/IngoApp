import 'package:intl/intl.dart';

class BudgetModel {
  BudgetModel(
      {required this.id,
      required this.name,
      required this.limit,
      required this.start,
      required this.end,
      this.currAmount});

  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  double? currAmount;
  double limit;

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
  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "limit": limit, "start": start, "end": end};

  //convert json to model
  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json["id"],
        name: json["name"],
        limit: json["limit"],
        start: json["start"],
        end: json["end"],
      );
}
