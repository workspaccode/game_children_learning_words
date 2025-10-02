import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../utils/validation_utils.dart';

// SOLID Principles: Single Responsibility, Open/Closed
// Factory Pattern for creating different user types
abstract class UserRegistrationHandler {
  Future<bool> validateRegistration(Map<String, dynamic> data);
  Future<UserModel> createUser(Map<String, dynamic> data);
  String get userTypeDisplayName;
  List<String> get requiredFields;
}

class ParentRegistrationHandler extends UserRegistrationHandler {
  
  ParentRegistrationHandler(this._authService);
  final AuthService _authService;

  @override
  Future<bool> validateRegistration(Map<String, dynamic> data) async {
    // Parent-specific validation
    final email = data['email'] as String?;
    final name = data['name'] as String?;
    
    if (email == null || name == null) return false;
    if (!ValidationUtils.isValidEmail(email)) return false;
    if (name.length < 2) return false;
    
    return true;
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      userType: UserType.parent,
      createdAt: DateTime.now(),
    );
  }

  @override
  String get userTypeDisplayName => 'ولي أمر';

  @override
  List<String> get requiredFields => ['name', 'email', 'password'];
}

class TeacherRegistrationHandler extends UserRegistrationHandler {
  
  TeacherRegistrationHandler(this._authService);
  final AuthService _authService;

  @override
  Future<bool> validateRegistration(Map<String, dynamic> data) async {
    // Teacher-specific validation
    final email = data['email'] as String?;
    final name = data['name'] as String?;
    
    if (email == null || name == null) return false;
    if (!ValidationUtils.isValidEmail(email)) return false;
    if (name.length < 2) return false;
    
    return true;
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      userType: UserType.teacher,
      createdAt: DateTime.now(),
    );
  }

  @override
  String get userTypeDisplayName => 'معلم';

  @override
  List<String> get requiredFields => ['name', 'email', 'password'];
}

class ChildRegistrationHandler extends UserRegistrationHandler {
  
  ChildRegistrationHandler(this._authService);
  final AuthService _authService;

  @override
  Future<bool> validateRegistration(Map<String, dynamic> data) async {
    // Child-specific validation
    final email = data['email'] as String?;
    final name = data['name'] as String?;
    final age = data['age'] as int?;
    final username = data['username'] as String?;
    final parentEmail = data['parentEmail'] as String?;
    
    if (email == null || name == null || age == null || 
        username == null || parentEmail == null) {
      return false;
    }
    
    if (!ValidationUtils.isValidEmail(email)) return false;
    if (!ValidationUtils.isValidEmail(parentEmail)) return false;
    if (name.length < 2) return false;
    if (username.length < 3) return false;
    if (age < 3 || age > 18) return false;
    
    // Check if parent exists
    final parent = await _authService.checkParentExists(parentEmail);
    return parent != null;
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      userType: UserType.child,
      username: data['username'] as String?,
      age: data['age'] as int?,
      parentEmail: data['parentEmail'] as String?,
      createdAt: DateTime.now(),
    );
  }

  @override
  String get userTypeDisplayName => 'طفل';

  @override
  List<String> get requiredFields => [
    'name', 'email', 'password', 'username', 'age', 'parentEmail'
  ];
}

// Factory class following Factory Pattern
class UserRegistrationFactory {
  static UserRegistrationHandler create(UserType userType, AuthService authService) {
    switch (userType) {
      case UserType.parent:
        return ParentRegistrationHandler(authService);
      case UserType.teacher:
        return TeacherRegistrationHandler(authService);
      case UserType.child:
        return ChildRegistrationHandler(authService);
    }
  }
}