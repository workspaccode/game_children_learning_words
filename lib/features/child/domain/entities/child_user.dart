import '../../../auth/domain/entities/user.dart';

class ChildUser extends User {
  const ChildUser({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required this.age,
    required this.parentId,
    required this.progress,
    required this.level,
  }) : super(role: UserRole.child);

  final int age;
  final String parentId;
  final Map<String, int> progress;
  final int level;

  @override
  List<Object?> get props => [...super.props, age, parentId, progress, level];
}
