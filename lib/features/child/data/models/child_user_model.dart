import '../../domain/entities/child_user.dart';

class ChildUserModel extends ChildUser {
  const ChildUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required super.age,
    required super.parentId,
    required super.progress,
    required super.level,
  });

  factory ChildUserModel.fromJson(Map<String, dynamic> json) {
    return ChildUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      age: json['age'] as int,
      parentId: json['parentId'] as String,
      progress: Map<String, int>.from(json['progress'] as Map),
      level: json['level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'age': age,
      'parentId': parentId,
      'progress': progress,
      'level': level,
    };
  }
}
