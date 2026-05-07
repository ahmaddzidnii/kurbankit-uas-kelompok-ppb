import 'package:shared_preferences/shared_preferences.dart';

class UserRoleService {
  static const String _userRoleKey = 'user_role';
  static const String _isMosqueRegisteredKey = 'is_mosque_registered';

  /// Get the current user's role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Save user role
  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  /// Check if mosque is registered
  static Future<bool> isMosqueRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isMosqueRegisteredKey) ?? false;
  }

  /// Mark mosque as registered
  static Future<void> setMosqueRegistered(bool isRegistered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isMosqueRegisteredKey, isRegistered);
  }

  /// Clear all user role data (useful for logout)
  static Future<void> clearUserRoleData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
    await prefs.remove(_isMosqueRegisteredKey);
  }
}
