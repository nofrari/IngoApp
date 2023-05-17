class User {
  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email});

  final String id;
  String firstName;
  String lastName;
  String email;

  String get abreviationName {
    return firstName[0] + lastName[0];
  }

  //convert model to json
  Map<String, dynamic> toJson() => {
        "user_id": id,
        "user_name": firstName,
        "user_sirname": lastName,
        "email": email,
      };

  //convert json to model
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["user_id"],
        firstName: json["user_name"],
        lastName: json["user_sirname"],
        email: json["email"],
      );
}
