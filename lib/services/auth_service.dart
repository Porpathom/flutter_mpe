import '../utils/shared_preferences_helper.dart';
import '../models/user.dart';

class AuthService {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  // ปรับปรุงเมธอด register ให้รองรับฟิลด์ใหม่
  Future<bool> register(
    String username,
    String password, {
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    DateTime? birthDate,
  }) async {
    // ตรวจสอบชื่อผู้ใช้ว่ามีการใช้งานอยู่หรือไม่
    if (await _prefsHelper.isUsernameTaken(username)) {
      return false; // ถ้ามีให้คืนค่า false
    }
    
    // สร้าง User ใหม่โดยใช้ฟิลด์ใหม่
    User newUser = User(
      username: username,
      password: password,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      birthDate: birthDate,
    );
    
    // บันทึก User ใหม่ลง SharedPreferences
    return await _prefsHelper.saveUser(newUser);
  }

  Future<bool> login(String username, String password) async {
    User? user = await _prefsHelper.getUser(username);
    if (user != null && user.password == password) {
      await _prefsHelper.setLoggedIn(true);
      return true; // ลงชื่อเข้าใช้สำเร็จ
    }
    return false; // ลงชื่อเข้าใช้ไม่สำเร็จ
  }

  Future<void> logout() async {
    await _prefsHelper.setLoggedIn(false); // ลงชื่อออก
  }

  Future<bool> isLoggedIn() async {
    return await _prefsHelper.isLoggedIn(); // ตรวจสอบสถานะการลงชื่อเข้าใช้
  }

  Future<bool> deleteAccount(String username) async {
    return await _prefsHelper.deleteUser(username); // ลบบัญชีผู้ใช้
  }

  Future<List<User>> getAllUsers() async {
    return await _prefsHelper.getAllUsers(); // รับรายชื่อผู้ใช้ทั้งหมด
  }
  Future<bool> updateUser(User updatedUser) async {
  return await _prefsHelper.saveUser(updatedUser);
}

Future<User?> getCurrentUser() async {
  // Implement logic to get current logged in user
}
}
