// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final GetIt locator = GetIt.instance;

// Future<void> initializeDependencies() async {
//   // External dependencies
//   final prefs = await SharedPreferences.getInstance();
//   locator.registerLazySingleton(() => prefs);

//   // Mock services for simplified app
//   locator.registerLazySingleton<MockAuthService>(() => MockAuthService());
//   locator.registerLazySingleton<MockDatabaseService>(() => MockDatabaseService());
//   locator.registerLazySingleton<MockStorageService>(() => MockStorageService());
// }

// // Mock services for simplified dependency injection
// class MockAuthService {
//   bool get isLoggedIn => true;
//   String get currentUserId => 'mock_user_123';
//   String get currentUserEmail => 'user@example.com';
  
//   Future<bool> signIn(String email, String password) async {
//     await Future<void>.delayed(const Duration(seconds: 1));
//     return true;
//   }
  
//   Future<bool> signUp(String email, String password, String name) async {
//     await Future<void>.delayed(const Duration(seconds: 1));
//     return true;
//   }
  
//   Future<void> signOut() async {
//     await Future<void>.delayed(const Duration(milliseconds: 500));
//   }
// }

// class MockDatabaseService {
//   Future<Map<String, dynamic>?> getUserData(String userId) async {
//     await Future<void>.delayed(const Duration(milliseconds: 500));
//     return {
//       'id': userId,
//       'name': 'مستخدم تجريبي',
//       'email': 'user@example.com',
//       'userType': 'child',
//       'createdAt': DateTime.now().toIso8601String(),
//     };
//   }
  
//   Future<bool> saveUserData(String userId, Map<String, dynamic> data) async {
//     await Future<void>.delayed(const Duration(milliseconds: 500));
//     return true;
//   }
  
//   Future<List<Map<String, dynamic>>> getWords() async {
//     await Future<void>.delayed(const Duration(milliseconds: 500));
//     return [
//       {'id': '1', 'english': 'Apple', 'arabic': 'تفاحة', 'category': 'fruits'},
//       {'id': '2', 'english': 'Book', 'arabic': 'كتاب', 'category': 'objects'},
//       {'id': '3', 'english': 'Cat', 'arabic': 'قطة', 'category': 'animals'},
//     ];
//   }
// }

// class MockStorageService {
//   final Map<String, dynamic> _storage = {};
  
//   Future<void> save(String key, dynamic value) async {
//     await Future<void>.delayed(const Duration(milliseconds: 100));
//     _storage[key] = value;
//   }
  
//   Future<T?> get<T>(String key) async {
//     await Future<void>.delayed(const Duration(milliseconds: 100));
//     return _storage[key] as T?;
//   }
  
//   Future<void> remove(String key) async {
//     await Future<void>.delayed(const Duration(milliseconds: 100));
//     _storage.remove(key);
//   }
  
//   Future<void> clear() async {
//     await Future<void>.delayed(const Duration(milliseconds: 100));
//     _storage.clear();
//   }
// }
