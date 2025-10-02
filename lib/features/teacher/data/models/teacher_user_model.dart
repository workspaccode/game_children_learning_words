import '../../domain/entities/teacher_user.dart';

class TeacherUserModel extends TeacherUser {
  const TeacherUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required super.studentIds,
    required super.schoolName,
    required super.subjects,
    required super.qualification,
  });

  factory TeacherUserModel.fromJson(Map<String, dynamic> json) {
    return TeacherUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      studentIds: List<String>.from(json['studentIds'] as List),
      schoolName: json['schoolName'] as String,
      subjects: List<String>.from(json['subjects'] as List),
      qualification: json['qualification'] as String,
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
      'studentIds': studentIds,
      'schoolName': schoolName,
      'subjects': subjects,
      'qualification': qualification,
    };
  }
}
