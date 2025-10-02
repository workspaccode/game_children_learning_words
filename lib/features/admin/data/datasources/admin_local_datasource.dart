import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/admin_user_model.dart';

abstract class AdminLocalDataSource {
  Future<void> cacheDashboardData(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getLastDashboardData();

  Future<void> cacheSystemStats(Map<String, dynamic> stats);
  Future<Map<String, dynamic>> getLastSystemStats();

  Future<void> cacheAdminProfile(AdminUserModel admin);
  Future<AdminUserModel> getLastAdminProfile();

  Future<void> clearCache();
}

class AdminLocalDataSourceImpl implements AdminLocalDataSource {

  AdminLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  static const cacheDashboardKey = 'CACHED_ADMIN_DASHBOARD';
  static const cacheSystemStatsKey = 'CACHED_SYSTEM_STATS';
  static const cacheAdminProfileKey = 'CACHED_ADMIN_PROFILE';

  @override
  Future<void> cacheDashboardData(Map<String, dynamic> data) async {
    try {
      await sharedPreferences.setString(cacheDashboardKey, json.encode(data));
    } catch (e) {
      throw CacheException('Failed to cache dashboard data');
    }
  }

  @override
  Future<Map<String, dynamic>> getLastDashboardData() async {
    try {
      final jsonString = sharedPreferences.getString(cacheDashboardKey);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      } else {
        throw CacheException('No cached dashboard data found');
      }
    } catch (e) {
      throw CacheException('Failed to get cached dashboard data');
    }
  }

  @override
  Future<void> cacheSystemStats(Map<String, dynamic> stats) async {
    try {
      await sharedPreferences.setString(
        cacheSystemStatsKey,
        json.encode(stats),
      );
    } catch (e) {
      throw CacheException('Failed to cache system stats');
    }
  }

  @override
  Future<Map<String, dynamic>> getLastSystemStats() async {
    try {
      final jsonString = sharedPreferences.getString(cacheSystemStatsKey);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      } else {
        throw CacheException('No cached system stats found');
      }
    } catch (e) {
      throw CacheException('Failed to get cached system stats');
    }
  }

  @override
  Future<void> cacheAdminProfile(AdminUserModel admin) async {
    try {
      await sharedPreferences.setString(
        cacheAdminProfileKey,
        json.encode(admin.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache admin profile');
    }
  }

  @override
  Future<AdminUserModel> getLastAdminProfile() async {
    try {
      final jsonString = sharedPreferences.getString(cacheAdminProfileKey);
      if (jsonString != null) {
        return AdminUserModel.fromJson(
          json.decode(jsonString) as Map<String, dynamic>,
        );
      } else {
        throw CacheException('No cached admin profile found');
      }
    } catch (e) {
      throw CacheException('Failed to get cached admin profile');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        sharedPreferences.remove(cacheDashboardKey),
        sharedPreferences.remove(cacheSystemStatsKey),
        sharedPreferences.remove(cacheAdminProfileKey),
      ]);
    } catch (e) {
      throw CacheException('Failed to clear admin cache');
    }
  }
}
