class CategoryModel {
  CategoryModel({
    required this.category_id,
    required this.bgColor,
    required this.isBlack,
    required this.icon,
    required this.label,
  });

  String category_id;
  String bgColor;
  bool isBlack;
  String icon;
  String label;

  Map<String, dynamic> toJson() => {
        'category_id': category_id,
        'bgColor': bgColor,
        'isBlack': isBlack,
        'icon': icon,
        'label': label,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        category_id: json["category_id"],
        bgColor: json["bgColor"],
        isBlack: json["isBlack"],
        icon: json["icon"],
        label: json['label'],
      );
}
