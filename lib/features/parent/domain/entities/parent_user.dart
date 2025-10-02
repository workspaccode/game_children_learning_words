import '../../../auth/domain/entities/user.dart';

class ParentUser extends User {
  const ParentUser({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required this.childrenIds,
    required this.phone,
  }) : super(role: UserRole.parent);

  final List<String> childrenIds;
  final String phone;

  @override
  List<Object?> get props => [...super.props, childrenIds, phone];
}
