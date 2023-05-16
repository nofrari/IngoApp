class ColorModel {
  ColorModel({
    required this.color_id,
    required this.name,
  });

  String color_id;
  String name;

  Map<String, dynamic> toJson() => {
        'color_id': color_id,
        'color_name': name,
      };

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      ColorModel(color_id: json["color_id"], name: json['color_name']);
}
