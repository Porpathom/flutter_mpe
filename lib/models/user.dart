class User {
  final String username;
  final String password; // ในการใช้งานจริง ควรเก็บเฉพาะ hashed password
  final String? email;
  final String? fullName;

  User({
    required this.username,
    required this.password,
    this.email,
    this.fullName,
  });

  // แปลงข้อมูล User เป็น Map เพื่อเก็บใน SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'fullName': fullName,
    };
  }

  // สร้าง User จาก Map ที่ได้จาก SharedPreferences
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      email: map['email'],
      fullName: map['fullName'],
    );
  }
}