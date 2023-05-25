class TransactionType {
  TransactionType({
    required this.type_id,
    required this.name,
  });

  String type_id;
  String name;

  Map<String, dynamic> toJson() => {
        'type_id': type_id,
        'name': name,
      };

  factory TransactionType.fromJson(Map<String, dynamic> json) =>
      TransactionType(type_id: json["type_id"], name: json['name']);
}
