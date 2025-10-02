import '../../../auth/domain/entities/user.dart';

class AdminUser extends User {
  const AdminUser({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required this.permissions,
  }) : super(role: UserRole.admin);

  final List<String> permissions;

  @override
  List<Object?> get props => [...super.props, permissions];
}
