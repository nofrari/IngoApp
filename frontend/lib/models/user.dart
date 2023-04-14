class User {
  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email});

  final int id;
  final String firstName;
  final String lastName;
  final String email;

  String get abreviationName {
    return firstName[0] + lastName[0];
  }
}
