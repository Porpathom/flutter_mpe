class User {
  final String username;
  final String password;
  final String? email;
  final String? fullName;
  final String? phoneNumber;  // เพิ่มหมายเลขโทรศัพท์
  final String? address;      // เพิ่มที่อยู่
  final DateTime? birthDate;  // เพิ่มวันเกิด

  User({
    required this.username,
    required this.password,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.address,
    this.birthDate,
  });

  // แปลงเป็น Map เพื่อบันทึก
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'birthDate': birthDate?.toIso8601String(), // แปลงวันที่เป็น String
    };
  }

  // สร้างจาก Map ที่อ่านจาก SharedPreferences หรือแหล่งข้อมูลอื่น
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      email: map['email'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
    );
  }
}
