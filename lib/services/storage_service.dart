import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return prefs.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return prefs.getString(key) ?? defaultValue;
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return prefs.setInt(key, value);
  }

  int? getInt(String key, {int? defaultValue}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return prefs.setDouble(key, value);
  }

  double? getDouble(String key, {double? defaultValue}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return prefs.setBool(key, value);
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  // List<String> operations
  Future<bool> setStringList(String key, List<String> value) async {
    return prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return prefs.getStringList(key) ?? defaultValue;
  }

  // JSON operations
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return setString(key, jsonString);
  }

  Map<String, dynamic>? getJson(
    String key, {
    Map<String, dynamic>? defaultValue,
  }) {
    final jsonString = getString(key);
    if (jsonString == null) return defaultValue;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return defaultValue;
    }
  }

  // List<Map<String, dynamic>> operations
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return setString(key, jsonString);
  }

  List<Map<String, dynamic>>? getJsonList(
    String key, {
    List<Map<String, dynamic>>? defaultValue,
  }) {
    final jsonString = getString(key);
    if (jsonString == null) return defaultValue;

    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return defaultValue;
    }
  }

  // Remove operations
  Future<bool> remove(String key) async {
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    return prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return prefs.getKeys();
  }

  // Reload preferences
  Future<void> reload() async {
    await prefs.reload();
  }

  // Common app-specific keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserType = 'user_type';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyFirstTime = 'first_time';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keyAnimationsEnabled = 'animations_enabled';
  static const String keyFontSize = 'font_size';
  static const String keyHighContrast = 'high_contrast';
  static const String keySpeechRate = 'speech_rate';
  static const String keySpeechPitch = 'speech_pitch';
  static const String keySpeechVolume = 'speech_volume';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyOfflineMode = 'offline_mode';
  static const String keyAutoBackup = 'auto_backup';
  static const String keyDataUsageWarning = 'data_usage_warning';
  static const String keyParentalControlsEnabled = 'parental_controls_enabled';
  static const String keyDailyTimeLimit = 'daily_time_limit';
  static const String keyWeeklyGoal = 'weekly_goal';
  static const String keyAchievements = 'achievements';
  static const String keyFavoriteWords = 'favorite_words';
  static const String keyRecentWords = 'recent_words';
  static const String keyGameProgress = 'game_progress';
  static const String keyUserStats = 'user_stats';

  // Helper methods for common operations
  Future<bool> setUserId(String userId) => setString(keyUserId, userId);
  String? getUserId() => getString(keyUserId);

  Future<bool> setUserEmail(String email) => setString(keyUserEmail, email);
  String? getUserEmail() => getString(keyUserEmail);

  Future<bool> setUserName(String name) => setString(keyUserName, name);
  String? getUserName() => getString(keyUserName);

  Future<bool> setIsLoggedIn(bool isLoggedIn) =>
      setBool(keyIsLoggedIn, isLoggedIn);
  bool getIsLoggedIn() => getBool(keyIsLoggedIn) ?? false;

  Future<bool> setLanguage(String language) => setString(keyLanguage, language);
  String getLanguage() => getString(keyLanguage) ?? 'ar';

  Future<bool> setTheme(String theme) => setString(keyTheme, theme);
  String getTheme() => getString(keyTheme) ?? 'system';

  Future<bool> setFirstTime(bool firstTime) => setBool(keyFirstTime, firstTime);
  bool isFirstTime() => getBool(keyFirstTime) ?? true;

  Future<bool> setOnboardingCompleted(bool completed) =>
      setBool(keyOnboardingCompleted, completed);
  bool isOnboardingCompleted() => getBool(keyOnboardingCompleted) ?? false;

  Future<bool> setSoundEnabled(bool enabled) =>
      setBool(keySoundEnabled, enabled);
  bool isSoundEnabled() => getBool(keySoundEnabled) ?? true;

  Future<bool> setMusicEnabled(bool enabled) =>
      setBool(keyMusicEnabled, enabled);
  bool isMusicEnabled() => getBool(keyMusicEnabled) ?? true;

  Future<bool> setAnimationsEnabled(bool enabled) =>
      setBool(keyAnimationsEnabled, enabled);
  bool areAnimationsEnabled() => getBool(keyAnimationsEnabled) ?? true;

  Future<bool> setFavoriteWords(List<String> words) =>
      setStringList(keyFavoriteWords, words);
  List<String> getFavoriteWords() => getStringList(keyFavoriteWords) ?? [];

  Future<bool> setRecentWords(List<String> words) =>
      setStringList(keyRecentWords, words);
  List<String> getRecentWords() => getStringList(keyRecentWords) ?? [];

  // Clear user data on logout
  Future<void> clearUserData() async {
    await Future.wait([
      remove(keyUserId),
      remove(keyUserEmail),
      remove(keyUserName),
      remove(keyUserType),
      remove(keyIsLoggedIn),
      remove(keyFavoriteWords),
      remove(keyRecentWords),
      remove(keyGameProgress),
      remove(keyUserStats),
      remove(keyAchievements),
    ]);
  }
}
