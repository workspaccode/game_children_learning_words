part of 'child_bloc.dart';

sealed class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object?> get props => [];
}

class ChildLoadProfileEvent extends ChildEvent {

  const ChildLoadProfileEvent(this.childId);
  final String childId;

  @override
  List<Object> get props => [childId];
}

class ChildUpdateProfileEvent extends ChildEvent {

  const ChildUpdateProfileEvent(this.child);
  final ChildUser child;

  @override
  List<Object> get props => [child];
}

class ChildUpdateProgressEvent extends ChildEvent {

  const ChildUpdateProgressEvent({
    required this.childId,
    required this.progress,
  });
  final String childId;
  final Map<String, int> progress;

  @override
  List<Object> get props => [childId, progress];
}

class ChildUpdateLevelEvent extends ChildEvent {

  const ChildUpdateLevelEvent({required this.childId, required this.level});
  final String childId;
  final int level;

  @override
  List<Object> get props => [childId, level];
}

class ChildWatchProgressEvent extends ChildEvent {

  const ChildWatchProgressEvent(this.childId);
  final String childId;

  @override
  List<Object> get props => [childId];
}
