class IntervalSubtypeModel {
  IntervalSubtypeModel({
    required this.interval_subtype_id,
    required this.name,
  });

  String interval_subtype_id;
  String name;

  Map<String, dynamic> toJson() => {
        'interval_subtype_id': interval_subtype_id,
        'interval_subtype_name': name,
      };

  factory IntervalSubtypeModel.fromJson(Map<String, dynamic> json) =>
      IntervalSubtypeModel(
          interval_subtype_id: json["interval_subtype_id"],
          name: json['interval_subtype_name']);
}
