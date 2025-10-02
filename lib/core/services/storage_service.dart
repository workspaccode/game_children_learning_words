import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> list) async {
    final String jsonString = json.encode(list);
    await _prefs.setString(key, jsonString);
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    final List<dynamic> decodedList = json.decode(jsonString) as List<dynamic>;
    return List<Map<String, dynamic>>.from(decodedList);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
