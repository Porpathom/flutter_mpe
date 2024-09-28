import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class SharedPreferencesHelper {
  static const String _kUsersKey = 'users';
  static const String _kLoggedInKey = 'logged_in';

  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> users = await _getUsers();
    users[user.username] = user.toMap();
    return await prefs.setString(_kUsersKey, json.encode(users));
  }

  Future<User?> getUser(String username) async {
    Map<String, dynamic> users = await _getUsers();
    if (users.containsKey(username)) {
      return User.fromMap(users[username]);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Map<String, dynamic> users = await _getUsers();
    return users.values.map((userData) => User.fromMap(userData)).toList();
  }

  Future<Map<String, dynamic>> _getUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(_kUsersKey);
    if (usersJson != null) {
      return json.decode(usersJson);
    }
    return {};
  }

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

  Future<void> setLoggedIn(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedInKey) ?? false;
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isUsernameTaken(String username) async {
    Map<String, dynamic> users = await _getUsers();
    return users.containsKey(username);
  }
}