part of 'teacher_bloc.dart';

sealed class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {
  const TeacherInitial();
}

class TeacherLoading extends TeacherState {
  const TeacherLoading();
}

class TeacherLoaded extends TeacherState {
  const TeacherLoaded(this.teacher);
  final TeacherUser teacher;

  @override
  List<Object> get props => [teacher];
}

class TeacherUpdating extends TeacherState {
  const TeacherUpdating(this.currentTeacher);
  final TeacherUser currentTeacher;

  @override
  List<Object> get props => [currentTeacher];
}

class TeacherLoadingStudents extends TeacherState {
  const TeacherLoadingStudents(this.teacher);
  final TeacherUser teacher;

  @override
  List<Object> get props => [teacher];
}

class TeacherClassStudentsLoaded extends TeacherState {
  const TeacherClassStudentsLoaded(this.students);
  final List<StudentProfile> students;

  @override
  List<Object> get props => [students];
}

class TeacherError extends TeacherState {
  const TeacherError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class TeacherNetworkError extends TeacherState {
  const TeacherNetworkError(this.currentTeacher);
  final TeacherUser? currentTeacher;

  @override
  List<Object?> get props => [currentTeacher];
}
