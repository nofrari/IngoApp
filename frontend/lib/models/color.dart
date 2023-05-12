class Color {
  Color({
    required this.color_id,
    required this.name,
  });

  String color_id;
  String name;

  Map<String, dynamic> toJson() => {
        'color_id': color_id,
        'name': name,
      };

  factory Color.fromJson(Map<String, dynamic> json) =>
      Color(color_id: json["color_id"], name: json['name']);
}
