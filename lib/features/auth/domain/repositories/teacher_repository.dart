import 'package:readingquest_bilingual_learning/features/teacher/data/models/teacher_user_model.dart';

abstract class TeacherRepository {
  // Repository methods here
  Future<void> createTeacher(TeacherUserModel teacher);
  Future<TeacherUserModel?> getTeacherById(String id);
  Future<List<TeacherUserModel>> getAllTeachers();
  Future<void> updateTeacher(TeacherUserModel teacher);
  Future<void> deleteTeacher(String id);
  Future<void> loginTeacher(String email, String password);
  Future<void> logoutTeacher();
  
}