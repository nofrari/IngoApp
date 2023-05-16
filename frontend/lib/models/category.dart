class CategoryModel {
  CategoryModel({
    required this.category_id,
    required this.bgColor,
    required this.isWhite,
    required this.icon,
    required this.label,
  });

  String category_id;
  String bgColor;
  bool isWhite;
  String icon;
  String label;

  Map<String, dynamic> toJson() => {
        'category_id': category_id,
        'bgColor': bgColor,
        'isBlack': isWhite,
        'icon': icon,
        'label': label,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        category_id: json["category_id"],
        bgColor: json["bgColor"],
        isWhite: json["isWhite"],
        icon: json["icon"],
        label: json['label'],
      );
}
