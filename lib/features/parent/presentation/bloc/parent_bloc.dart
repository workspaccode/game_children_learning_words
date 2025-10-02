import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../child/domain/entities/child_user.dart';
import '../../domain/entities/parent_user.dart';
import '../../domain/repositories/parent_repository.dart';

part 'parent_event.dart';
part 'parent_state.dart';

class ParentBloc extends Bloc<ParentEvent, ParentState> {

  ParentBloc({required this.parentRepository}) : super(const ParentInitial()) {
    on<ParentLoadProfileEvent>(_onLoadProfile);
    on<ParentUpdateProfileEvent>(_onUpdateProfile);
    on<ParentAddChildEvent>(_onAddChild);
    on<ParentRemoveChildEvent>(_onRemoveChild);
    on<ParentLoadChildrenEvent>(_onLoadChildren);
    on<ParentUpdatePaymentInfoEvent>(_onUpdatePaymentInfo);
    on<ParentWatchChildrenEvent>(_onWatchChildren);
  }
  final ParentRepository parentRepository;
  StreamSubscription? _childrenSubscription;

  Future<void> _onLoadProfile(
    ParentLoadProfileEvent event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentLoading());
    try {
      final result = await parentRepository.getParentProfile(event.parentId);
      result.fold(
        (failure) => emit(ParentError(failure.message)),
        (parent) => emit(ParentLoaded(parent)),
      );
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    ParentUpdateProfileEvent event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentLoading());
    try {
      final result = await parentRepository.updateParentProfile(event.parent);
      result.fold(
        (failure) => emit(ParentError(failure.message)),
        (parent) => emit(ParentLoaded(parent)),
      );
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onAddChild(
    ParentAddChildEvent event,
    Emitter<ParentState> emit,
  ) async {
    try {
      final result = await parentRepository.addChild(
        event.parentId,
        event.childId,
      );
      result.fold((failure) => emit(ParentError(failure.message)), (_) async {
        final childrenResult = await parentRepository.getChildren(
          event.parentId,
        );
        childrenResult.fold(
          (failure) => emit(ParentError(failure.message)),
          (children) => emit(ParentChildrenLoaded(children)),
        );
      });
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onRemoveChild(
    ParentRemoveChildEvent event,
    Emitter<ParentState> emit,
  ) async {
    try {
      final result = await parentRepository.removeChild(
        event.parentId,
        event.childId,
      );
      result.fold((failure) => emit(ParentError(failure.message)), (_) async {
        final childrenResult = await parentRepository.getChildren(
          event.parentId,
        );
        childrenResult.fold(
          (failure) => emit(ParentError(failure.message)),
          (children) => emit(ParentChildrenLoaded(children)),
        );
      });
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onLoadChildren(
    ParentLoadChildrenEvent event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentLoading());
    try {
      final result = await parentRepository.getChildren(event.parentId);
      result.fold(
        (failure) => emit(ParentError(failure.message)),
        (children) => emit(ParentChildrenLoaded(children)),
      );
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  Future<void> _onUpdatePaymentInfo(
    ParentUpdatePaymentInfoEvent event,
    Emitter<ParentState> emit,
  ) async {
    try {
      final result = await parentRepository.updatePaymentInfo(
        event.parentId,
        event.paymentInfo,
      );
      result.fold(
        (failure) => emit(ParentError(failure.message)),
        (_) => emit(ParentPaymentInfoUpdated(event.paymentInfo)),
      );
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }

  void _onWatchChildren(
    ParentWatchChildrenEvent event,
    Emitter<ParentState> emit,
  ) {
    _childrenSubscription?.cancel();
    _childrenSubscription = parentRepository
        .watchChildren(event.parentId)
        .listen(
          (children) => emit(ParentChildrenLoaded(children)),
          onError: (error) => emit(ParentError(error.toString())),
        );
  }

  @override
  Future<void> close() {
    _childrenSubscription?.cancel();
    return super.close();
  }
}
