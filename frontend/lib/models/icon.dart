class IconModel {
  IconModel({
    required this.icon_id,
    required this.name,
  });

  String icon_id;
  String name;

  Map<String, dynamic> toJson() => {
        'icon_id': icon_id,
        'icon_name': name,
      };

  factory IconModel.fromJson(Map<String, dynamic> json) => IconModel(
        icon_id: json["icon_id"],
        name: json["icon_name"],
      );
}
