import 'package:intl/intl.dart';

final dateFormatter = DateFormat('dd / MM / yyyy');

class TransactionModel {
  TransactionModel({
    required this.transaction_id,
    required this.transaction_name,
    required this.transaction_amount,
    required this.date,
    this.description,
    this.bill_url,
    required this.category_id,
    required this.type_id,
    required this.interval_id,
    required this.account_id,
  });

  String transaction_id;
  String transaction_name;
  double transaction_amount;
  DateTime date;
  String? description;
  String? bill_url;
  String category_id;
  String type_id;
  String interval_id;
  String account_id;

  Map<String, dynamic> toJson() => {
        'transaction_id': transaction_id,
        'transaction_name': transaction_name,
        'transaction_amount': transaction_amount,
        'date': date,
        'description': description,
        'bill_url': bill_url,
        'category_id': category_id,
        'type_id': type_id,
        'interval_id': interval_id,
        'account_id': account_id,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        transaction_id: json["transaction_id"],
        transaction_name: json["transaction_name"],
        transaction_amount: json["transaction_amount"],
        date: json["date"],
        description: json["description"],
        bill_url: json['bill_url'],
        category_id: json['category_id'],
        type_id: json['type_id'],
        interval_id: json['interval_id'],
        account_id: json['account_id'],
      );

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
