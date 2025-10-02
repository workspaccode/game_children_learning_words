import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../factories/user_factory.dart';
import '../repositories/auth_repository.dart';

// Use Cases following Single Responsibility Principle
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

// Sign Up Use Case
class SignUpUseCase implements UseCase<UserModel, SignUpParams> {
  SignUpUseCase(this._repository, this._authService);
  
  final IAuthRepository _repository;
  final AuthService _authService;

  @override
  Future<Result<UserModel>> call(SignUpParams params) async {
    try {
      // Use Factory Pattern for validation
      final handler = UserRegistrationFactory.create(params.userType, _authService);
      
      // Prepare data for validation
      final data = {
        'email': params.email,
        'name': params.name,
        'age': params.age,
        'username': params.username,
        'parentEmail': params.parentEmail,
      };

      // Validate using appropriate handler
      final isValid = await handler.validateRegistration(data);
      if (!isValid) {
        return Result.failure('Validation failed');
      }

      // Proceed with registration
      return _repository.signUp(
        email: params.email,
        password: params.password,
        name: params.name,
        userType: params.userType,
        username: params.username,
        age: params.age,
        parentEmail: params.parentEmail,
      );
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

// Sign In Use Case
class SignInUseCase implements UseCase<UserModel, SignInParams> {
  SignInUseCase(this._repository);
  
  final IAuthRepository _repository;

  @override
  Future<Result<UserModel>> call(SignInParams params) async {
    try {
      return _repository.signIn(
        email: params.email,
        password: params.password,
      );
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

// Check Parent Use Case
class CheckParentUseCase implements UseCase<bool, CheckParentParams> {
  CheckParentUseCase(this._repository);
  
  final IAuthRepository _repository;

  @override
  Future<Result<bool>> call(CheckParentParams params) async {
    try {
      return _repository.checkParentExists(params.parentEmail);
    } catch (e) {
      return Result.failure('Parent check failed');
    }
  }
}

// Complete Child Registration Use Case
class CompleteChildRegistrationUseCase implements UseCase<bool, CompleteChildParams> {
  CompleteChildRegistrationUseCase(this._repository);
  
  final IAuthRepository _repository;

  @override
  Future<Result<bool>> call(CompleteChildParams params) async {
    try {
      return _repository.updateChildWithParentInfo(
        childId: params.childId,
        parentEmail: params.parentEmail,
        username: params.username,
        age: params.age,
      );
    } catch (e) {
      return Result.failure('Child registration update failed');
    }
  }
}

// Parameters Classes
class SignUpParams {
  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
    this.username,
    this.age,
    this.parentEmail,
  });
  
  final String email;
  final String password;
  final String name;
  final UserType userType;
  final String? username;
  final int? age;
  final String? parentEmail;
}

class SignInParams {
  SignInParams({
    required this.email,
    required this.password,
  });
  
  final String email;
  final String password;
}

class CheckParentParams {
  CheckParentParams({required this.parentEmail});
  
  final String parentEmail;
}

class CompleteChildParams {
  CompleteChildParams({
    required this.childId,
    required this.parentEmail,
    required this.username,
    required this.age,
  });
  
  final String childId;
  final String parentEmail;
  final String username;
  final int age;
}