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
    this.interval_subtype_id,
    required this.account_id,
    this.transfer_account_id,
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
  String? interval_subtype_id;
  String account_id;
  String? transfer_account_id;

  Map<String, dynamic> toJson() => {
        'transaction_id': transaction_id,
        'transaction_name': transaction_name,
        'transaction_amount': transaction_amount,
        'date': date.toIso8601String(),
        'description': description,
        'bill_url': bill_url,
        'category_id': category_id,
        'type_id': type_id,
        'interval_id': interval_id,
        'interval_subtype_id': interval_subtype_id,
        'account_id': account_id,
        'transfer_account_id': transfer_account_id
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
          transaction_id: json["transaction_id"],
          transaction_name: json["transaction_name"],
          transaction_amount: json["transaction_amount"],
          date: DateTime.parse(json["date"]),
          description: json["description"],
          bill_url: json['bill_url'],
          category_id: json['category_id'],
          type_id: json['type_id'],
          interval_id: json['interval_id'],
          interval_subtype_id: json['interval_subtype_id'],
          account_id: json['account_id'],
          transfer_account_id: json['transfer_account_id']);

  String get formattedDate {
    return dateFormatter.format(date);
  }

  String formattedAmount(double? amount, String? action) {
    if (action == "2") {
      return "- ${amount?.toStringAsFixed(2)} € ";
    } else {
      return " ${amount?.toStringAsFixed(2)} € ";
    }
  }

  bool isCompleted() {
    if (transaction_name != "" &&
        transaction_amount != 0 &&
        date != DateTime(2000) &&
        category_id != "" &&
        type_id != "" &&
        interval_id != "" &&
        account_id != "") {
      return true;
    } else {
      return false;
    }
  }
}
