import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/parent_user.dart';

class ParentUserModel extends ParentUser {
  const ParentUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required super.children,
    this.paymentInfo,
  });

  factory ParentUserModel.fromJson(Map<String, dynamic> json) {
    return ParentUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      children: List<String>.from(json['children'] as List),
      paymentInfo: json['paymentInfo'] as Map<String, dynamic>?,
    );
  }

  final Map<String, dynamic>? paymentInfo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'children': children,
      'paymentInfo': paymentInfo,
    };
  }
}
