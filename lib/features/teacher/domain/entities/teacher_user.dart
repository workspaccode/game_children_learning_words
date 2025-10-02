import '../../../auth/domain/entities/user.dart';

class TeacherUser extends User {
  const TeacherUser({
    required super.id,
    required super.email,
    required super.name,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
    required this.studentIds,
    required this.schoolName,
    required this.subjects,
    required this.qualification,
  }) : super(role: UserRole.teacher);

  final List<String> studentIds;
  final String schoolName;
  final List<String> subjects;
  final String qualification;

  @override
  List<Object?> get props => [
    ...super.props,
    studentIds,
    schoolName,
    subjects,
    qualification,
  ];
}
