import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meetzone/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _userBoxName = 'userBox';
  static const _userKey = 'currentUser';
  static const _tokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _currentRouteKey = 'currentRoute';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(_userBoxName);
  }

  // Secure Storage for Tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Hive for User Data
  static Future<void> saveUser(User user) async {
    final box = Hive.box<User>(_userBoxName);
    await box.put(_userKey, user);
  }

  static User? getUser() {
    final box = Hive.box<User>(_userBoxName);
    return box.get(_userKey);
  }

  static Future<void> clearUser() async {
    final box = Hive.box<User>(_userBoxName);
    await box.delete(_userKey);
  }

  static Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
    await clearCurrentRoute();
  }

  // SharedPreferences for Current Route
  static Future<void> saveCurrentRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentRouteKey, route);
  }

  static Future<String?> getCurrentRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentRouteKey);
  }

  static Future<void> clearCurrentRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentRouteKey);
  }

  // Get initial route based on saved state
  static Future<String> getInitialRoute() async {
    final savedRoute = await getCurrentRoute();

    // If user reached dashboard, always go to dashboard
    if (savedRoute == '/dashboard') {
      return '/dashboard';
    }

    // Otherwise, return saved route or default to onboarding
    return savedRoute ?? '/';
  }
}


