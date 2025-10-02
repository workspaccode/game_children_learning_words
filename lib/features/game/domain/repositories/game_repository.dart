import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../models/game_progress_model.dart';
import '../../../../models/word_model.dart';
import '../entities/current_game_entity.dart';
import '../entities/game_state_entity.dart';

abstract class GameRepository {
  /// Get game state
  Either<Failure, GameStateEntity> getGameState();

  /// Get current game state
  Either<Failure, CurrentGameEntity> getCurrentGameState();

  /// Save game progress
  Future<Either<Failure, void>> saveGameProgress(GameProgressModel progress);

  /// Get user's game progress
  Future<Either<Failure, List<GameProgressModel>>> getUserGameProgress(
    String userId,
  );

  /// Start a new game
  Either<Failure, GameStateEntity> startGame({
    required GameType gameType,
    required int level,
    required List<WordModel> words,
  });

  /// Handle correct answer
  Either<Failure, GameStateEntity> handleCorrectAnswer();

  /// Handle wrong answer
  Either<Failure, GameStateEntity> handleWrongAnswer();

  /// Skip current word
  Either<Failure, GameStateEntity> skipWord();

  /// Pause game
  Either<Failure, GameStateEntity> pauseGame();

  /// Resume game
  Either<Failure, GameStateEntity> resumeGame();

  /// Update game timer
  Either<Failure, GameStateEntity> updateTimer(int timeRemaining);

  /// Reset game
  Either<Failure, GameStateEntity> resetGame();

  /// Set current game words
  Either<Failure, CurrentGameEntity> setGameWords(List<WordModel> words);

  /// Set current word
  Either<Failure, CurrentGameEntity> setCurrentWord(WordModel word);

  /// Set game options
  Either<Failure, CurrentGameEntity> setOptions(List<String> options);

  /// Set selected answer
  Either<Failure, CurrentGameEntity> setSelectedAnswer(String answer);

  /// Set show result
  Either<Failure, CurrentGameEntity> setShowResult({required bool show});

  /// Set is correct
  Either<Failure, CurrentGameEntity> setIsCorrect({required bool correct});

  /// Reset current game
  Either<Failure, CurrentGameEntity> resetCurrentGame();
}
