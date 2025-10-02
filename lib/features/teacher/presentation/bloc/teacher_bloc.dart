import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/entities/teacher_user.dart';
import '../../domain/repositories/teacher_repository.dart';

part 'teacher_event.dart';
part 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  TeacherBloc({required this.teacherRepository, required this.networkInfo})
    : super(const TeacherInitial()) {
    // Register event handlers
    on<TeacherLoadProfileEvent>(_onLoadProfile);
    on<TeacherUpdateProfileEvent>(_onUpdateProfile);
    on<TeacherAddSubjectEvent>(_onAddSubject);
    on<TeacherRemoveSubjectEvent>(_onRemoveSubject);
    on<TeacherAddClassEvent>(_onAddClass);
    on<TeacherRemoveClassEvent>(_onRemoveClass);
    on<TeacherLoadClassStudentsEvent>(_onLoadClassStudents);
    on<TeacherWatchProfileEvent>(_onWatchProfile);

    // Listen to connectivity changes
    _networkSubscription = networkInfo.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        add(const TeacherLoadProfileEvent('current')); // Reload from cache
      }
    });
  }

  final TeacherRepository teacherRepository;
  final NetworkInfo networkInfo;
  StreamSubscription<TeacherUser>? _profileSubscription;
  StreamSubscription<ConnectivityResult>? _networkSubscription;

  Future<void> _onLoadProfile(
    TeacherLoadProfileEvent event,
    Emitter<TeacherState> emit,
  ) async {
    if (state is! TeacherLoading) {
      emit(const TeacherLoading());
    }

    final result = await teacherRepository.getTeacherProfile(event.teacherId);
    result.fold((failure) {
      if (failure is NetworkFailure) {
        emit(
          TeacherNetworkError(
            state is TeacherLoaded ? (state as TeacherLoaded).teacher : null,
          ),
        );
      } else {
        emit(TeacherError(failure.message));
      }
    }, (teacher) => emit(TeacherLoaded(teacher)));
  }

  Future<void> _onUpdateProfile(
    TeacherUpdateProfileEvent event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeacherLoaded) {
      emit(TeacherUpdating(currentState.teacher));

      final result = await teacherRepository.updateTeacherProfile(
        event.teacher,
      );
      result.fold((failure) {
        emit(TeacherLoaded(currentState.teacher)); // Revert to previous state
        emit(TeacherError(failure.message));
      }, (teacher) => emit(TeacherLoaded(teacher)));
    }
  }

  Future<void> _onAddSubject(
    TeacherAddSubjectEvent event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeacherLoaded) {
      emit(TeacherUpdating(currentState.teacher));

      final result = await teacherRepository.addSubject(
        event.teacherId,
        event.subject,
      );

      await result.fold(
        (failure) async {
          emit(TeacherLoaded(currentState.teacher)); // Revert to previous state
          emit(TeacherError(failure.message));
        },
        (_) async {
          // Reload profile to get updated subjects list
          final profileResult = await teacherRepository.getTeacherProfile(
            event.teacherId,
          );
          profileResult.fold((failure) {
            emit(TeacherLoaded(currentState.teacher));
            emit(TeacherError(failure.message));
          }, (teacher) => emit(TeacherLoaded(teacher)));
        },
      );
    }
  }

  Future<void> _onRemoveSubject(
    TeacherRemoveSubjectEvent event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeacherLoaded) {
      emit(TeacherUpdating(currentState.teacher));

      final result = await teacherRepository.removeSubject(
        event.teacherId,
        event.subject,
      );

      await result.fold(
        (failure) async {
          emit(TeacherLoaded(currentState.teacher)); // Revert to previous state
          emit(TeacherError(failure.message));
        },
        (_) async {
          // Reload profile to get updated subjects list
          final profileResult = await teacherRepository.getTeacherProfile(
            event.teacherId,
          );
          profileResult.fold((failure) {
            emit(TeacherLoaded(currentState.teacher));
            emit(TeacherError(failure.message));
          }, (teacher) => emit(TeacherLoaded(teacher)));
        },
      );
    }
  }

  Future<void> _onAddClass(
    TeacherAddClassEvent event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeacherLoaded) {
      emit(TeacherUpdating(currentState.teacher));

      final result = await teacherRepository.addClass(
        event.teacherId,
        event.classId,
      );

      await result.fold(
        (failure) async {
          emit(TeacherLoaded(currentState.teacher)); // Revert to previous state
          emit(TeacherError(failure.message));
        },
        (_) async {
          // Reload profile to get updated classes list
          final profileResult = await teacherRepository.getTeacherProfile(
            event.teacherId,
          );
          profileResult.fold((failure) {
            emit(TeacherLoaded(currentState.teacher));
            emit(TeacherError(failure.message));
          }, (teacher) => emit(TeacherLoaded(teacher)));
        },
      );
    }
  }

  Future<void> _onRemoveClass(
    TeacherRemoveClassEvent event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeacherLoaded) {
      emit(TeacherUpdating(currentState.teacher));

      final result = await teacherRepository.removeClass(
        event.teacherId,
        event.classId,
      );

      await result.fold(
        (failure) async {
          emit(TeacherLoaded(currentState.teacher)); // Revert to previous state
          emit(TeacherError(failure.message));
        },
        (_) async {
          // Reload profile to get updated classes list
          final profileResult = await teacherRepository.getTeacherProfile(
            event.teacherId,
          );
          profileResult.fold((failure) {
            emit(TeacherLoaded(currentState.teacher));
            emit(TeacherError(failure.message));
          }, (teacher) => emit(TeacherLoaded(teacher)));
        },
      );
    }
  }

  Future<void> _onLoadClassStudents(
    TeacherLoadClassStudentsEvent event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    if (currentState is TeacherLoaded) {
      emit(TeacherLoadingStudents(currentState.teacher));

      final result = await teacherRepository.getClassStudents(event.classId);
      result.fold((failure) {
        emit(TeacherLoaded(currentState.teacher));
        emit(TeacherError(failure.message));
      }, (students) => emit(TeacherClassStudentsLoaded(students)));
    }
  }

  void _onWatchProfile(
    TeacherWatchProfileEvent event,
    Emitter<TeacherState> emit,
  ) {
    _profileSubscription?.cancel();
    _profileSubscription = teacherRepository
        .watchTeacherProfile(event.teacherId)
        .listen(
          (teacher) => emit(TeacherLoaded(teacher)),
          onError: (Object error) {
            if (state is TeacherLoaded) {
              emit(TeacherError(error.toString()));
            } else {
              emit(const TeacherError('Failed to load teacher profile'));
            }
          },
        );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _networkSubscription?.cancel();
    return super.close();
  }
}
