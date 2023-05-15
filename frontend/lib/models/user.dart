class User {
  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email});

  final int id;
  String firstName;
  String lastName;
  String email;

  String get abreviationName {
    return firstName[0] + lastName[0];
  }
}
