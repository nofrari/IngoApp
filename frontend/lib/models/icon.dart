class Icon {
  Icon({
    required this.icon_id,
    required this.name,
  });

  String icon_id;
  String name;

  Map<String, dynamic> toJson() => {
        'icon_id': icon_id,
        'name': name,
      };

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
        icon_id: json["icon_id"],
        name: json["name"],
      );
}
