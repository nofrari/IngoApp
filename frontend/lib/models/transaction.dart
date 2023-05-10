//working with uuids?
import 'package:intl/intl.dart';

final dateFormatter = DateFormat('dd / MM / yyyy');

class Transaction {
  Transaction(
      {required this.id,
      required this.name,
      required this.amount,
      required this.category,
      required this.date,
      required this.description,
      required this.transactionType});

  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  final int transactionType;
  final String description;

  String get formattedDate {
    return dateFormatter.format(date);
  }

  String formattedAmount(double? amount, String? action) {
    if (action == "0") {
      return "- ${amount?.toStringAsFixed(2)} € ";
    } else {
      return " ${amount?.toStringAsFixed(2)} € ";
    }
  }
}
