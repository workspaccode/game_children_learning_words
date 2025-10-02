import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ParentLocalDataSource {
  Future<void> cacheParentUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getLastParent();
  Future<void> clearParent();
  Future<void> cacheChildren(List<Map<String, dynamic>> children);
  Future<List<Map<String, dynamic>>?> getLastChildren();
  Future<void> clearChildren();
}

class ParentLocalDataSourceImpl implements ParentLocalDataSource {

  ParentLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const String PARENT_USER_KEY = 'CACHED_PARENT_USER';
  static const String CHILDREN_KEY = 'CACHED_CHILDREN';

  @override
  Future<void> cacheParentUser(Map<String, dynamic> user) async {
    await sharedPreferences.setString(PARENT_USER_KEY, json.encode(user));
  }

  @override
  Future<Map<String, dynamic>?> getLastParent() async {
    final jsonString = sharedPreferences.getString(PARENT_USER_KEY);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearParent() async {
    await sharedPreferences.remove(PARENT_USER_KEY);
  }

  @override
  Future<void> cacheChildren(List<Map<String, dynamic>> children) async {
    await sharedPreferences.setString(CHILDREN_KEY, json.encode(children));
  }

  @override
  Future<List<Map<String, dynamic>>?> getLastChildren() async {
    final jsonString = sharedPreferences.getString(CHILDREN_KEY);
    if (jsonString != null) {
      final decoded = json.decode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  @override
  Future<void> clearChildren() async {
    await sharedPreferences.remove(CHILDREN_KEY);
  }
}
