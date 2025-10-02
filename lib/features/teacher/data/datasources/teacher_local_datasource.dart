import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

abstract class TeacherLocalDataSource {
  Future<void> cacheTeacherUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>> getLastTeacher();
  Future<void> clearTeacher();
  Future<void> cacheStudents(List<Map<String, dynamic>> students);
  Future<List<Map<String, dynamic>>> getLastStudents();
  Future<void> clearStudents();
}

class TeacherLocalDataSourceImpl implements TeacherLocalDataSource {

  TeacherLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const String TEACHER_USER_KEY = 'CACHED_TEACHER_USER';
  static const String STUDENTS_KEY = 'CACHED_STUDENTS';

  @override
  Future<void> cacheTeacherUser(Map<String, dynamic> user) async {
    try {
      await sharedPreferences.setString(TEACHER_USER_KEY, json.encode(user));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, dynamic>> getLastTeacher() async {
    try {
      final jsonString = sharedPreferences.getString(TEACHER_USER_KEY);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      throw CacheException();
    } on FormatException {
      throw CacheException();
    }
  }

  @override
  Future<void> clearTeacher() async {
    try {
      final success = await sharedPreferences.remove(TEACHER_USER_KEY);
      if (!success) throw CacheException();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheStudents(List<Map<String, dynamic>> students) async {
    try {
      await sharedPreferences.setString(STUDENTS_KEY, json.encode(students));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLastStudents() async {
    try {
      final jsonString = sharedPreferences.getString(STUDENTS_KEY);
      if (jsonString != null) {
        final decoded = json.decode(jsonString) as List;
        return decoded.cast<Map<String, dynamic>>();
      }
      throw CacheException();
    } on FormatException {
      throw CacheException();
    }
  }

  @override
  Future<void> clearStudents() async {
    try {
      final success = await sharedPreferences.remove(STUDENTS_KEY);
      if (!success) throw CacheException();
    } catch (e) {
      throw CacheException();
    }
  }
}
