import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class LocalStorage {

  LocalStorage(this._prefs);
  final SharedPreferences _prefs;
  static const String userKey = 'user_data';

  Future<void> saveUser(User user) async {
    final userJson = jsonEncode((user as UserModel).toJson());
    await _prefs.setString(userKey, userJson);
  }

  Future<User?> getUser() async {
    final userJson = _prefs.getString(userKey);
    if (userJson == null) {
      return null;
    }

    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _prefs.remove(userKey);
  }
}