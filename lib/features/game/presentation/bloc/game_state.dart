import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/current_game_entity.dart';
import '../../domain/entities/game_state_entity.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameError extends GameState {
  const GameError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class GameStateLoaded extends GameState {
  const GameStateLoaded({
    required this.gameState,
    required this.currentGameState,
  });

  final GameStateEntity gameState;
  final CurrentGameEntity currentGameState;

  @override
  List<Object?> get props => [gameState, currentGameState];
}

class GameStatePaused extends GameState {
  const GameStatePaused(this.gameState);

  final GameStateEntity gameState;

  @override
  List<Object?> get props => [gameState];
}

class GameStateCompleted extends GameState {
  const GameStateCompleted(this.gameState);

  final GameStateEntity gameState;

  @override
  List<Object?> get props => [gameState];
}
