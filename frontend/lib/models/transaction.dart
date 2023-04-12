//working with uuids?
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMd();

class Transaction {
  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  final int id;
  final String name;
  final double amount;
  final String category;
  final DateTime date;

  String get formattedDate {
    return dateFormatter.format(date);
  }
}
