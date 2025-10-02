import '../../domain/entities/student_profile.dart';

class StudentProfileModel extends StudentProfile {
  const StudentProfileModel({
    required super.id,
    required super.name,
    required super.age,
    required super.grade,
    required super.progress,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      grade: json['grade'] as int,
      progress: Map<String, double>.from(json['progress'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'grade': grade,
      'progress': progress,
    };
  }
}
