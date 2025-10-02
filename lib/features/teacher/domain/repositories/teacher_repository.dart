import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/student_profile.dart';
import '../entities/teacher_user.dart';

abstract class TeacherRepository {
  Future<Either<Failure, TeacherUser>> getTeacherProfile(String teacherId);
  Future<Either<Failure, TeacherUser>> updateTeacherProfile(
    TeacherUser teacher,
  );
  Future<Either<Failure, Unit>> addSubject(String teacherId, String subject);
  Future<Either<Failure, Unit>> removeSubject(String teacherId, String subject);
  Future<Either<Failure, Unit>> addClass(String teacherId, String classId);
  Future<Either<Failure, Unit>> removeClass(String teacherId, String classId);
  Future<Either<Failure, List<StudentProfile>>> getClassStudents(
    String classId,
  );
  Stream<TeacherUser> watchTeacherProfile(String teacherId);
}
