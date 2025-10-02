import '../../models/user_model.dart';
import '../../services/auth_service.dart';

// Repository Pattern following SOLID principles
// Interface Segregation & Dependency Inversion
abstract class IAuthRepository {
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? username,
    int? age,
    String? parentEmail,
  });

  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<bool>> checkParentExists(String parentEmail);

  Future<Result<bool>> updateChildWithParentInfo({
    required String childId,
    required String parentEmail,
    required String username,
    required int age,
  });

  Future<Result<UserModel>> checkAuthStatus();

  Future<Result<UserModel>> signInWithGoogle();
}

// Result class for better error handling
class Result<T> {
  const Result.success(this.data)
    : error = null,
      errorCode = null,
      isSuccess = true;

  const Result.failure(this.error, {this.errorCode})
    : data = null,
      isSuccess = false;
  final T? data;
  final String? error;
  final String? errorCode;
  final bool isSuccess;

  bool get isFailure => !isSuccess;
}

// Concrete implementation
class AuthRepository implements IAuthRepository {
  AuthRepository(this._authService);
  final AuthService _authService;

  @override
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? username,
    int? age,
    String? parentEmail,
  }) async {
    try {
      final success = await _authService.signUpWithExtendedData(
        email: email,
        password: password,
        name: name,
        userType: userType,
        username: username,
        age: age,
        parentEmail: parentEmail,
      );

      if (success && _authService.userModel != null) {
        return Result.success(_authService.userModel);
      } else {
        return Result.failure(
          _authService.errorMessage ?? 'Registration failed',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (result['success'] == true && _authService.userModel != null) {
        return Result.success(_authService.userModel);
      } else {
        return Result.failure(
          result['error'] as String? ?? 'Login failed',
          errorCode: result['errorCode'] as String?,
        );
      }
    } catch (e) {
      return Result.failure(e.toString(), errorCode: 'unknown');
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<bool>> checkParentExists(String parentEmail) async {
    try {
      final parent = await _authService.checkParentExists(parentEmail);
      if (parent != null) {
        return const Result.success(true);
      } else {
        return const Result.success(false);
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<UserModel>> checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        return Result.success(user);
      }
      return const Result.failure('Not authenticated');
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result.isNotEmpty) {
        final userData = {
          'email': result['email'],
          'name': result['displayName'],
          'photoUrl': result['photoUrl'],
        };

        // Default user type when signing in with Google
        const userType = UserType.child;

        final success = await _authService.createGoogleUser(userData, userType);
        if (success) {
          final user = await _authService.getCurrentUser();
          if (user != null) {
            return Result.success(user);
          }
        }
      }
      return const Result.failure('Failed to sign in with Google');
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<bool>> updateChildWithParentInfo({
    required String childId,
    required String parentEmail,
    required String username,
    required int age,
  }) async {
    try {
      final success = await _authService.updateChildWithParentInfo(
        childId: childId,
        parentEmail: parentEmail,
        username: username,
        age: age,
      );
      return Result.success(success);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
