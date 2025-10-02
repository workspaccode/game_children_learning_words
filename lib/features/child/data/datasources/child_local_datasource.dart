import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ChildLocalDataSource {
  Future<void> cacheChildUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getLastChild();
  Future<void> clearChild();
}

class ChildLocalDataSourceImpl implements ChildLocalDataSource {

  ChildLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const String CHILD_USER_KEY = 'CACHED_CHILD_USER';

  @override
  Future<void> cacheChildUser(Map<String, dynamic> user) async {
    await sharedPreferences.setString(CHILD_USER_KEY, json.encode(user));
  }

  @override
  Future<Map<String, dynamic>?> getLastChild() async {
    final jsonString = sharedPreferences.getString(CHILD_USER_KEY);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearChild() async {
    await sharedPreferences.remove(CHILD_USER_KEY);
  }
}
