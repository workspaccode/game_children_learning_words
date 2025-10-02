import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/child_user.dart';
import '../../domain/repositories/child_repository.dart';

part 'child_event.dart';
part 'child_state.dart';

class ChildBloc extends Bloc<ChildEvent, ChildState> {

  ChildBloc({required this.childRepository}) : super(const ChildInitial()) {
    on<ChildLoadProfileEvent>(_onLoadProfile);
    on<ChildUpdateProfileEvent>(_onUpdateProfile);
    on<ChildUpdateProgressEvent>(_onUpdateProgress);
    on<ChildUpdateLevelEvent>(_onUpdateLevel);
    on<ChildWatchProgressEvent>(_onWatchProgress);
  }
  final ChildRepository childRepository;
  StreamSubscription? _progressSubscription;

  Future<void> _onLoadProfile(
    ChildLoadProfileEvent event,
    Emitter<ChildState> emit,
  ) async {
    emit(const ChildLoading());
    try {
      final result = await childRepository.getChildProfile(event.childId);
      result.fold(
        (failure) => emit(ChildError(failure.message)),
        (child) => emit(ChildLoaded(child)),
      );
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    ChildUpdateProfileEvent event,
    Emitter<ChildState> emit,
  ) async {
    emit(const ChildLoading());
    try {
      final result = await childRepository.updateChildProfile(event.child);
      result.fold(
        (failure) => emit(ChildError(failure.message)),
        (child) => emit(ChildLoaded(child)),
      );
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }

  Future<void> _onUpdateProgress(
    ChildUpdateProgressEvent event,
    Emitter<ChildState> emit,
  ) async {
    try {
      final result = await childRepository.updateProgress(
        event.childId,
        event.progress,
      );
      result.fold(
        (failure) => emit(ChildError(failure.message)),
        (_) => emit(ChildProgressUpdated(event.progress)),
      );
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }

  Future<void> _onUpdateLevel(
    ChildUpdateLevelEvent event,
    Emitter<ChildState> emit,
  ) async {
    try {
      final result = await childRepository.updateLevel(
        event.childId,
        event.level,
      );
      result.fold(
        (failure) => emit(ChildError(failure.message)),
        (level) => emit(ChildLevelUpdated(level)),
      );
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }

  void _onWatchProgress(
    ChildWatchProgressEvent event,
    Emitter<ChildState> emit,
  ) {
    _progressSubscription?.cancel();
    _progressSubscription = childRepository
        .watchChildProgress(event.childId)
        .listen(
          (child) => emit(ChildLoaded(child)),
          onError: (error) => emit(ChildError(error.toString())),
        );
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
