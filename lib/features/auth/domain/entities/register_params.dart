import 'package:equatable/equatable.dart';

import 'user_type.dart';

/// Parameters for registering a new user
class RegisterUserParams extends Equatable {
  /// Creates new register user parameters
  const RegisterUserParams({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.username,
    this.age,
    this.parentEmail,
  });

  /// The full name of the user
  final String name;

  /// The email address for the account
  final String email;

  /// The password for the account 
  final String password;

  /// The type of user (child, parent, or teacher)
  final UserType userType;

  /// The username (required for child accounts)
  final String? username;

  /// The user's age (required for child accounts)
  final int? age;

  /// The parent's email (required for child accounts)
  final String? parentEmail;

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        userType,
        username,
        age,
        parentEmail,
      ];
}