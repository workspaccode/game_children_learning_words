import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'firebase_database_service.dart';

enum UserType { parent, teacher, child }

class AuthService extends ChangeNotifier {
  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserModel();
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  // getCurrentUser
  Future<UserModel?> getCurrentUser() async {
    if (_user != null) {
      await _loadUserModel();
      return _userModel;
    }
    return null;
  }

  Future<void> _loadUserModel() async {
    if (_user != null) {
      try {
        // أولاً، نحاول تحميل البيانات من التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        final savedUserData = prefs.getString('user_data');

        if (savedUserData != null) {
          final dynamic decodedData = jsonDecode(savedUserData);
          if (decodedData is Map<String, dynamic>) {
            _userModel = UserModel.fromJson(decodedData);
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        print('Error loading local user data: $e');
      }

      // إذا لم نجد بيانات محلية أو كانت غير صالحة، نحمل من Firebase
      _userModel = await FirebaseDatabaseService.instance.getUserById(
        _user!.uid,
      );

      // حفظ البيانات محلياً
      if (_userModel != null) {
        await _saveUserDataLocally(_userModel!);
      }

      notifyListeners();
    }
  }

  Future<void> _saveUserDataLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user data locally: $e');
    }
  }

  Future<void> _clearLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      print('Error clearing local user data: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // التحقق من وجود حساب الوالد
  Future<UserModel?> checkParentExists(String parentEmail) async {
    try {
      final parent = await FirebaseDatabaseService.instance
          .getUserByEmailAndType(parentEmail, UserType.parent);
      return parent;
    } catch (e) {
      print('Error checking parent existence: $e');
      return null;
    }
  }

  // Sign Up with Extended Data (للأطفال مع معلومات الوالد)
  Future<bool> signUpWithExtendedData({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    int? age,
    String? username,
    String? parentEmail,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // التحقق من وجود الوالد للأطفال
      String? parentId;
      if (userType == UserType.child && parentEmail != null) {
        final parent = await checkParentExists(parentEmail);
        if (parent == null) {
          _setError('لم يتم العثور على حساب ولي الأمر بهذا البريد الإلكتروني');
          return false;
        }
        parentId = parent.id;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // تحديث الاسم المعروض
        await credential.user!.updateDisplayName(name);

        // إنشاء نموذج المستخدم
        final userModel = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          userType: userType,
          username: username,
          age: age,
          parentId: parentId,
          parentEmail: parentEmail,
          createdAt: DateTime.now(),
        );

        // حفظ في قاعدة البيانات
        await FirebaseDatabaseService.instance.createUser(userModel);

        // تحديث المستخدم والنموذج محلياً
        _user = credential.user;
        _userModel = userModel;

        await _saveUserSession();

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email & Password Authentication
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
        await _loadUserModel();
        if (_userModel != null) {
          await _saveUserSession();
          return {'success': true};
        } else {
          const errorMessage = 'لم يتم العثور على بيانات المستخدم.';
          _setError(errorMessage);
          return {
            'success': false,
            'error': errorMessage,
            'errorCode': 'user-data-not-found',
          };
        }
      }
      return {
        'success': false,
        'error': 'Login failed',
        'errorCode': 'sign_in_failed',
      };
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.code);
      _setError(errorMessage);
      return {'success': false, 'error': errorMessage, 'errorCode': e.code};
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع',
        'errorCode': 'unknown',
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserType userType,
    int? age,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      // التحقق من أن الطفل لا يمكنه إنشاء حساب قبل وجود ولي أمر
      if (userType == UserType.child) {
        final existingParent = await FirebaseDatabaseService.instance
            .getUserByEmailAndType(email, UserType.parent);

        if (existingParent == null) {
          _setError('يجب على ولي الأمر إنشاء حساب أولاً قبل إنشاء حساب الطفل');
          return false;
        }
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // تحديث الاسم المعروض
        await credential.user!.updateDisplayName(name);

        // إنشاء نموذج المستخدم
        final userModel = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          userType: userType,
          age: age,
          createdAt: DateTime.now(),
        );

        // حفظ في قاعدة البيانات
        await FirebaseDatabaseService.instance.createUser(userModel);
        await _saveUserSession();

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      // Check if Google Services are available
      print('🔄 Starting Google Sign In process...');

      // Sign out from any previous Google session to avoid conflicts
      await _googleSignIn.signOut();
      print('✅ Cleared previous Google session');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ User cancelled Google Sign In');
        _setError('تم إلغاء تسجيل الدخول');
        return {
          'success': false,
          'error': 'تم إلغاء تسجيل الدخول',
        }; // User cancelled
      }

      print('✅ Google user selected: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Failed to get Google auth tokens');
        _setError('فشل في الحصول على بيانات المصادقة');
        return {'success': false, 'error': 'فشل في الحصول على بيانات المصادقة'};
      }

      print('✅ Got Google auth tokens');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔄 Signing in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('✅ Firebase sign in successful: ${userCredential.user!.uid}');

        // Check if user exists in database
        final existingUser = await FirebaseDatabaseService.instance.getUserById(
          userCredential.user!.uid,
        );

        final isNewUser = existingUser == null;
        print(isNewUser ? '🆕 New user detected' : '👤 Existing user found');

        if (isNewUser) {
          // For new users, don't create the user yet - let them choose type first
          final userData = {
            'uid': userCredential.user!.uid,
            'displayName': userCredential.user!.displayName,
            'email': userCredential.user!.email,
            'photoURL': userCredential.user!.photoURL,
          };

          return {'success': true, 'isNewUser': true, 'userData': userData};
        } else {
          // Existing user - sign them in normally
          await _saveUserSession();
          return {'success': true, 'isNewUser': false, 'userData': null};
        }
      }
      print('❌ Firebase user is null');
      return {'success': false, 'error': 'فشل في تسجيل الدخول'};
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Error: ${e.code} - ${e.message}');
      final errorMessage = _getGoogleSignInErrorMessage(e.code);
      _setError(errorMessage);
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return {'success': false, 'error': errorMessage};
        case 'invalid-credential':
          return {'success': false, 'error': errorMessage};
        case 'operation-not-allowed':
          return {'success': false, 'error': errorMessage};
        case 'user-disabled':
          return {'success': false, 'error': errorMessage};
        case 'user-not-found':
          return {'success': false, 'error': errorMessage};
        case 'wrong-password':
          return {'success': false, 'error': errorMessage};
        case 'user-mismatch':
          return {'success': false, 'error': errorMessage};
        case 'credential-already-in-use':
          return {'success': false, 'error': errorMessage};
        //
        default:
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('💥 Google Sign In Error: $e'); // For debugging
      String errorMessage = 'حدث خطأ في تسجيل الدخول بجوجل';
      print(e.toString());

      if (e.toString().contains('ApiException: 10:')) {
        errorMessage =
            'خطأ في تكوين Google Sign In. تأكد من إعداد SHA-1 fingerprint في Firebase Console';
      }

      _setError(errorMessage);
      return {'success': false, 'error': errorMessage};
    } finally {
      _setLoading(false);
    }
  }

  // Create Google User after type selection
  Future<bool> createGoogleUser(
    Map<String, dynamic> userData,
    UserType userType,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      // التحقق من أن الطفل لا يمكنه إنشاء حساب قبل وجود ولي أمر
      if (userType == UserType.child) {
        final String email = (userData['email'] as String?) ?? '';
        if (email.isEmpty) {
          _setError('البريد الإلكتروني مطلوب لإنشاء حساب الطفل');
          return false;
        }

        // البحث عن ولي أمر بنفس البريد الإلكتروني
        final existingParent = await FirebaseDatabaseService.instance
            .getUserByEmailAndType(email, UserType.parent);

        if (existingParent == null) {
          _setError('يجب على ولي الأمر إنشاء حساب أولاً قبل إنشاء حساب الطفل');
          return false;
        }
      }

      final userModel = UserModel(
        id: userData['uid'] as String,
        name: (userData['displayName'] as String?) ?? 'مستخدم جديد',
        email: userData['email'] as String,
        userType: userType,
        createdAt: DateTime.now(),
        profileImageUrl: userData['photoURL'] as String?,
        isGoogleUser: true,
      );

      await FirebaseDatabaseService.instance.createUser(userModel);

      // تحميل نموذج المستخدم في الخدمة
      await _loadUserModel();

      await _saveUserSession();
      return true;
    } catch (e) {
      _setError('فشل في إنشاء الحساب');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearLocalUserData();
      _user = null;
      _userModel = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    int? age,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_user != null && _userModel != null) {
        // Update Firebase user
        if (name != null && name != _user!.displayName) {
          await _user!.updateDisplayName(name);
        }
        // Update user model
        final updatedUser = _userModel!.copyWith(
          name: name,
          email: email,
          age: age,
          profileImageUrl: profileImageUrl,
          updatedAt: DateTime.now(),
        );

        await FirebaseDatabaseService.instance.updateUser(updatedUser);
        _userModel = updatedUser;
        notifyListeners();

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('فشل في تحديث الملف الشخصي');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Session Management
  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null && _userModel != null) {
      // Save the entire user model as JSON
      final userJson = _userModel!.toJson();
      await prefs.setString('user_data', jsonEncode(userJson));

      // Save authentication state
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_id', _user!.uid);
      await prefs.setString('user_email', _user!.email ?? '');

      // Save Firebase tokens for session restoration
      final idToken = await _user!.getIdToken();
      if (idToken != null) {
        await prefs.setString('firebase_id_token', idToken);
      }

      // Save profile completion status
      await prefs.setBool(
        'is_profile_complete',
        _userModel!.isProfileComplete(),
      );

      print('User session saved successfully: ${_userModel!.name}');
    } else {
      print('Cannot save user session: user or userModel is null');
    }
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    // حذف بيانات المستخدم كاملة
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('firebase_id_token');
    await prefs.remove('is_profile_complete');

    // حذف جميع المفاتيح المتعلقة بالتقدم في اللعبة
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('game_') ||
          key.startsWith('progress_') ||
          key.startsWith('achievement_') ||
          key.startsWith('stats_') ||
          key.startsWith('cached_')) {
        await prefs.remove(key);
      }
    }

    // احتفظ بإعدادات التطبيق العامة (اختياري)
    // final soundEnabled = prefs.getBool('sound_effects') ?? true;
    // final musicEnabled = prefs.getBool('background_music') ?? true;
    // final animationsEnabled = prefs.getBool('animations') ?? true;

    // حذف جميع البيانات
    await prefs.clear();

    // إعادة تعيين إعدادات التطبيق العامة (اختياري)
    // await prefs.setBool('sound_effects', soundEnabled);
    // await prefs.setBool('background_music', musicEnabled);
    // await prefs.setBool('animations', animationsEnabled);

    // تعيين حالة عدم تسجيل الدخول
    await prefs.setBool('is_logged_in', false);

    print('User session cleared successfully');
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Restore user session from saved preferences
  Future<bool> restoreUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (!isLoggedIn) {
        print('No saved session found');
        return false;
      }

      // التحقق من وجود المستخدم الحالي في Firebase
      if (_auth.currentUser == null) {
        print('No Firebase currentUser found');
        return false;
      }

      // محاولة استعادة بيانات المستخدم من التخزين المحلي
      final userDataJson = prefs.getString('user_data');
      if (userDataJson != null) {
        try {
          final userData = jsonDecode(userDataJson);
          _userModel = UserModel.fromJson(userData as Map<String, dynamic>);
          print(
            'User session restored from local storage: ${_userModel!.name}',
          );

          // التحقق من تطابق المعرف مع Firebase
          if (_userModel!.id != _auth.currentUser!.uid) {
            print('User ID mismatch between local storage and Firebase');
            await _clearUserSession();
            return false;
          }

          // تحديث البيانات من Firebase للتأكد من أحدث المعلومات
          await _loadUserModel();
          return true;
        } catch (e) {
          print('Error parsing saved user data: $e');
          await _clearUserSession();
          return false;
        }
      } else {
        print('No saved user data found');
        return false;
      }
    } catch (e) {
      print('Error restoring user session: $e');
      return false;
    }
  }

  // Error Messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة';
      case 'network-request-failed':
        return 'فشل في الاتصال بالشبكة';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بهذا البريد مع طريقة تسجيل دخول مختلفة';
      case 'invalid-credential':
        return 'بيانات المصادقة غير صحيحة';
      case 'credential-already-in-use':
        return 'بيانات المصادقة مستخدمة بالفعل';
      case 'sign_in_failed':
        return 'فشل تسجيل الدخول';
      default:
        return 'حدث خطأ غير متوقع: $errorCode';
    }
  }

  // Google Sign In specific error messages
  String _getGoogleSignInErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بهذا البريد مع طريقة تسجيل دخول مختلفة';
      case 'invalid-credential':
        return 'بيانات Google غير صحيحة';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بجوجل غير مفعل. تأكد من إعدادات Firebase';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'network-request-failed':
        return 'فشل في الاتصال بالشبكة';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح';
      case 'api-not-available':
        return 'خدمة Google Sign In غير متاحة. تأكد من إعداد SHA-1 fingerprint';
      case 'sign_in_failed':
        return 'فشل في تسجيل الدخول بجوجل. تأكد من التكوين الصحيح';
      default:
        return 'حدث خطأ في تسجيل الدخول بجوجل: $errorCode';
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Update Child with Parent Info (for Google Sign-in children)
  Future<bool> updateChildWithParentInfo({
    required String childId,
    required String parentEmail,
    required String username,
    required int age,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // التحقق من وجود الوالد
      final parent = await checkParentExists(parentEmail);
      if (parent == null) {
        _setError('لم يتم العثور على حساب ولي الأمر بهذا البريد الإلكتروني');
        return false;
      }

      // تحديث بيانات الطفل في قاعدة البيانات
      await FirebaseDatabaseService.instance.updateChildWithParentInfo(
        childId: childId,
        parentId: parent.id,
        parentEmail: parentEmail,
        username: username,
        age: age,
      );

      // تحديث نموذج المستخدم محلياً
      if (_userModel != null) {
        _userModel = _userModel!.copyWith(
          parentId: parent.id,
          parentEmail: parentEmail,
          username: username,
          age: age,
        );
      }

      await _saveUserSession();
      return true;
    } catch (e) {
      _setError('حدث خطأ في تحديث البيانات');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if current user is parent
  bool get isParent => _userModel?.userType == UserType.parent;

  // Check if current user is teacher
  bool get isTeacher => _userModel?.userType == UserType.teacher;

  // Check if current user is child
  bool get isChild => _userModel?.userType == UserType.child;
}
