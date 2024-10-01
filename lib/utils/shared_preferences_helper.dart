import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';




class SharedPreferencesHelper {
  static const String _kUsersKey = 'users';
  static const String _kLoggedInKey = 'logged_in';

  // บันทึกผู้ใช้พร้อมข้อมูลใหม่
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> users = await _getUsers();
    users[user.username] = user.toMap(); // ใช้ toMap ที่อัปเดตแล้ว
    return await prefs.setString(_kUsersKey, json.encode(users));
  }

  // ดึงข้อมูลผู้ใช้จากชื่อผู้ใช้
  Future<User?> getUser(String username) async {
    Map<String, dynamic> users = await _getUsers();
    if (users.containsKey(username)) {
      return User.fromMap(users[username]); // ใช้ fromMap ที่อัปเดตแล้ว
    }
    return null;
  }

  // ดึงข้อมูลผู้ใช้ทั้งหมด
  Future<List<User>> getAllUsers() async {
    Map<String, dynamic> users = await _getUsers();
    return users.values.map((userData) => User.fromMap(userData)).toList(); // ใช้ fromMap
  }

  // ดึงข้อมูลผู้ใช้ทั้งหมดจาก SharedPreferences
  Future<Map<String, dynamic>> _getUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(_kUsersKey);
    if (usersJson != null) {
      return json.decode(usersJson);
    }
    return {};
  }

  // ลบผู้ใช้
  Future<bool> deleteUser(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> users = await _getUsers();
    if (users.containsKey(username)) {
      users.remove(username);
      await prefs.setString(_kUsersKey, json.encode(users));
      return true;
    }
    return false;
  }

  // ตั้งค่าการล็อกอิน
  Future<void> setLoggedIn(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedInKey, value);
  }

  // ตรวจสอบสถานะล็อกอิน
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedInKey) ?? false;
  }

  // ล้างข้อมูลทั้งหมด
  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ตรวจสอบว่าชื่อผู้ใช้ซ้ำหรือไม่
  Future<bool> isUsernameTaken(String username) async {
    Map<String, dynamic> users = await _getUsers();
    return users.containsKey(username);
  }
}
