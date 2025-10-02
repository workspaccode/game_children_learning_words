import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.grade,
    required this.progress,
  });

  final String id;
  final String name;
  final int age;
  final int grade;
  final Map<String, double> progress;

  @override
  List<Object> get props => [id, name, age, grade, progress];
}
