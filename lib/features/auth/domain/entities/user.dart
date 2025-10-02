import 'package:equatable/equatable.dart';

enum UserRole { child, parent, teacher, admin }

abstract class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    isActive,
    createdAt,
    lastLoginAt,
  ];  

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.name,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };
  
}
