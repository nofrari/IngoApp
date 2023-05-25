class Interval {
  Interval({
    required this.interval_id,
    required this.name,
  });

  String interval_id;
  String name;

  Map<String, dynamic> toJson() => {
        'interval_id': interval_id,
        'name': name,
      };

  factory Interval.fromJson(Map<String, dynamic> json) =>
      Interval(interval_id: json["interval_id"], name: json['name']);
}
