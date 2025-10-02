part of 'teacher_bloc.dart';

sealed class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherLoadProfileEvent extends TeacherEvent {

  const TeacherLoadProfileEvent(this.teacherId);
  final String teacherId;

  @override
  List<Object> get props => [teacherId];
}

class TeacherUpdateProfileEvent extends TeacherEvent {

  const TeacherUpdateProfileEvent(this.teacher);
  final TeacherUser teacher;

  @override
  List<Object> get props => [teacher];
}

class TeacherAddSubjectEvent extends TeacherEvent {

  const TeacherAddSubjectEvent({
    required this.teacherId,
    required this.subject,
  });
  final String teacherId;
  final String subject;

  @override
  List<Object> get props => [teacherId, subject];
}

class TeacherRemoveSubjectEvent extends TeacherEvent {

  const TeacherRemoveSubjectEvent({
    required this.teacherId,
    required this.subject,
  });
  final String teacherId;
  final String subject;

  @override
  List<Object> get props => [teacherId, subject];
}

class TeacherAddClassEvent extends TeacherEvent {

  const TeacherAddClassEvent({
    required this.teacherId,
    required this.classId,
  });
  final String teacherId;
  final String classId;

  @override
  List<Object> get props => [teacherId, classId];
}

class TeacherRemoveClassEvent extends TeacherEvent {

  const TeacherRemoveClassEvent({
    required this.teacherId,
    required this.classId,
  });
  final String teacherId;
  final String classId;

  @override
  List<Object> get props => [teacherId, classId];
}

class TeacherLoadClassStudentsEvent extends TeacherEvent {

  const TeacherLoadClassStudentsEvent(this.classId);
  final String classId;

  @override
  List<Object> get props => [classId];
}

class TeacherWatchProfileEvent extends TeacherEvent {

  const TeacherWatchProfileEvent(this.teacherId);
  final String teacherId;

  @override
  List<Object> get props => [teacherId];
}