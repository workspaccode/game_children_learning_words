import 'package:json_annotation/json_annotation.dart';

import '../services/auth_service.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.username,
    this.age,
    this.profileImageUrl,
    this.parentId,
    this.parentEmail,
    this.isGoogleUser = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      userType: _parseUserType(map['user_type'] as String?),
      username: map['username'] as String?,
      age: map['age'] as int?,
      profileImageUrl: map['profile_image_url'] as String?,
      parentId: map['parent_id'] as String?,
      parentEmail: map['parent_email'] as String?,
      isGoogleUser: (map['is_google_user'] ?? 0) == 1,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  final String id;
  final String name;
  final String email;
  final UserType userType;

  bool isProfileComplete() {
    if (userType == UserType.child) {
      return username != null && age != null;
    } else if (userType == UserType.parent) {
      return username != null;
    }
    return true;
  }

  final String? username;
  final int? age;
  final String? profileImageUrl;
  final String? parentId;
  final String? parentEmail;
  final bool isGoogleUser;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserType? userType,
    String? username,
    int? age,
    String? profileImageUrl,
    String? parentId,
    String? parentEmail,
    bool? isGoogleUser,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      username: username ?? this.username,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      parentId: parentId ?? this.parentId,
      parentEmail: parentEmail ?? this.parentEmail,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'user_type': userType.toString().split('.').last,
      'username': username,
      'age': age,
      'profile_image_url': profileImageUrl,
      'parent_id': parentId,
      'parent_email': parentEmail,
      'is_active': isActive ? 1 : 0,
      'is_google_user': isGoogleUser ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static UserType _parseUserType(String? userTypeString) {
    switch (userTypeString) {
      case 'parent':
        return UserType.parent;
      case 'teacher':
        return UserType.teacher;
      case 'child':
        return UserType.child;
      default:
        return UserType.child;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, userType: $userType, username: $username, age: $age, profileImageUrl: $profileImageUrl, parentId: $parentId, parentEmail: $parentEmail, isGoogleUser: $isGoogleUser, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.userType == userType &&
        other.username == username &&
        other.age == age &&
        other.profileImageUrl == profileImageUrl &&
        other.parentId == parentId &&
        other.parentEmail == parentEmail &&
        other.isActive == isActive &&
        other.isGoogleUser == isGoogleUser &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        userType.hashCode ^
        username.hashCode ^
        age.hashCode ^
        profileImageUrl.hashCode ^
        parentId.hashCode ^
        parentEmail.hashCode ^
        isGoogleUser.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  // Helper methods
  bool get isParent => userType == UserType.parent;
  bool get isTeacher => userType == UserType.teacher;
  bool get isChild => userType == UserType.child;

  // Validation methods
  bool get canAddMoreChildren =>
      isParent; // Max 4 children will be checked in service
  bool get requiresParentLink => isChild && (parentId?.isEmpty ?? true);
  bool get hasValidParent => isChild && (parentId?.isNotEmpty ?? false);

  String get userTypeDisplayName {
    switch (userType) {
      case UserType.parent:
        return 'ولي أمر';
      case UserType.teacher:
        return 'معلم';
      case UserType.child:
        return 'طفل';
    }
  }

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}
