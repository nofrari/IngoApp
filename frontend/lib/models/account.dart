import 'package:intl/intl.dart';

class Account {
  Account({
    required this.id,
    required this.name,
    required this.amount,
  });

  final String id;
  final String name;
  final double amount;

  String formatedAmount(double amount) {
    var formatter = NumberFormat('#,##0.00', 'de_DE');
    String formattedNumber = formatter.format(amount);

    return "$formattedNumber €";
  }

  //convert model to json
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "amount": amount,
      };

  //convert json to model
  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        name: json["name"],
        amount: json["amount"],
      );
}
