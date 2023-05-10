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
    return "$amount €";
  }
}
