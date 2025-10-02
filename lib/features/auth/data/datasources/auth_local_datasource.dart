import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


abstract class AuthLocalDataSource {
  Future<void> cacheUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getLastUser();
  Future<void> clearUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  AuthLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const String USER_KEY = 'CACHED_USER';
  static const String TOKEN_KEY = 'CACHED_TOKEN';

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    await sharedPreferences.setString(USER_KEY, json.encode(user));
  }

  @override
  Future<Map<String, dynamic>?> getLastUser() async {
    final jsonString = sharedPreferences.getString(USER_KEY);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(USER_KEY);
  }

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(TOKEN_KEY, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(TOKEN_KEY);
  }

  @override
  Future<void> clearToken() async {
    await sharedPreferences.remove(TOKEN_KEY);
  }
}