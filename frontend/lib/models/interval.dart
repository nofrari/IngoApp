class IntervalModel {
  IntervalModel({
    required this.interval_id,
    required this.name,
  });

  String interval_id;
  String name;

  Map<String, dynamic> toJson() => {
        'interval_id': interval_id,
        'name': name,
      };

  factory IntervalModel.fromJson(Map<String, dynamic> json) =>
      IntervalModel(interval_id: json["interval_id"], name: json['name']);
}
