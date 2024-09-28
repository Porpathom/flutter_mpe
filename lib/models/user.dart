class User {
  final String username;
  final String password;
  final String? email;
  final String? fullName;

  User({
    required this.username,
    required this.password,
    this.email,
    this.fullName,
  });


  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'fullName': fullName,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      email: map['email'],
      fullName: map['fullName'],
    );
  }
}