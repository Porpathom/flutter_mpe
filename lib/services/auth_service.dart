import '../utils/shared_preferences_helper.dart';
import '../models/user.dart';

class AuthService {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<bool> register(String username, String password) async {
    if (await _prefsHelper.isUsernameTaken(username)) {
      return false;
    }
    User newUser = User(username: username, password: password);
    return await _prefsHelper.saveUser(newUser);
  }

  Future<bool> login(String username, String password) async {
    User? user = await _prefsHelper.getUser(username);
    if (user != null && user.password == password) {
      await _prefsHelper.setLoggedIn(true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _prefsHelper.setLoggedIn(false);
  }

  Future<bool> isLoggedIn() async {
    return await _prefsHelper.isLoggedIn();
  }

  Future<bool> deleteAccount(String username) async {
    return await _prefsHelper.deleteUser(username);
  }

  Future<List<User>> getAllUsers() async {
    return await _prefsHelper.getAllUsers();
  }
}