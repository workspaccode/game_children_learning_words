part of 'child_bloc.dart';

sealed class ChildState extends Equatable {
  const ChildState();

  @override
  List<Object?> get props => [];
}

class ChildInitial extends ChildState {
  const ChildInitial();
}

class ChildLoading extends ChildState {
  const ChildLoading();
}

class ChildLoaded extends ChildState {

  const ChildLoaded(this.child);
  final ChildUser child;

  @override
  List<Object> get props => [child];
}

class ChildError extends ChildState {

  const ChildError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class ChildProgressUpdated extends ChildState {

  const ChildProgressUpdated(this.progress);
  final Map<String, int> progress;

  @override
  List<Object> get props => [progress];
}

class ChildLevelUpdated extends ChildState {

  const ChildLevelUpdated(this.level);
  final int level;

  @override
  List<Object> get props => [level];
}
