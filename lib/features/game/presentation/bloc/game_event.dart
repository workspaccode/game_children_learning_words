import 'package:equatable/equatable.dart';

import '../../domain/entities/game_state_entity.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartGameEvent extends GameEvent {
  const StartGameEvent({required this.gameType, required this.level});

  final GameType gameType;
  final int level;

  @override
  List<Object?> get props => [gameType, level];
}

class NextWordEvent extends GameEvent {}

class CorrectAnswerEvent extends GameEvent {}

class WrongAnswerEvent extends GameEvent {}

class SkipWordEvent extends GameEvent {}

class PauseGameEvent extends GameEvent {}

class ResumeGameEvent extends GameEvent {}

class UpdateTimerEvent extends GameEvent {
  const UpdateTimerEvent(this.timeRemaining);

  final int timeRemaining;

  @override
  List<Object?> get props => [timeRemaining];
}

class ResetGameEvent extends GameEvent {}

class SetSelectedAnswerEvent extends GameEvent {
  const SetSelectedAnswerEvent(this.answer);

  final String answer;

  @override
  List<Object?> get props => [answer];
}

class SetShowResultEvent extends GameEvent {
  const SetShowResultEvent({required this.show});

  final bool show;

  @override
  List<Object?> get props => [show];
}

class SetIsCorrectEvent extends GameEvent {
  const SetIsCorrectEvent({required this.correct});

  final bool correct;

  @override
  List<Object?> get props => [correct];
}

class ResetCurrentGameEvent extends GameEvent {}
