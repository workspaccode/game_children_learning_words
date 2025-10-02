import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../models/game_progress_model.dart';
import '../../../../models/word_model.dart';
import '../../../../services/firebase_database_service.dart';
import '../../domain/entities/current_game_entity.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/current_game_model.dart';
import '../models/game_state_model.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._databaseService);

  final FirebaseDatabaseService _databaseService;

  GameStateModel? _gameState;
  CurrentGameModel? _currentGameState;

  @override
  Either<Failure, GameStateEntity> getGameState() {
    try {
      final gameState =
          _gameState ??
          GameStateModel.fromEntity(GameStateEntity.initial(), const []);
      return Right(gameState);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> getCurrentGameState() {
    try {
      final currentGameState =
          _currentGameState ??
          CurrentGameModel.fromEntity(CurrentGameEntity.initial(), words: const []);
      return Right(currentGameState);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveGameProgress(
    GameProgressModel progress,
  ) async {
    try {
      await _databaseService.saveGameProgress(progress);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameProgressModel>>> getUserGameProgress(
    String userId,
  ) async {
    try {
      final progress = await _databaseService.getUserGameProgress(userId);
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> startGame({
    required GameType gameType,
    required int level,
    required List<WordModel> words,
  }) {
    try {
      _gameState = GameStateModel(
        status: GameStatus.playing,
        gameType: gameType,
        level: level,
        words: words,
        currentWordIndex: 0,
        score: 0,
        lives: 3,
        timeRemaining: _getGameDuration(gameType),
        correctAnswers: 0,
        wrongAnswers: 0,
        skippedAnswers: 0,
        accuracy: 0,
        startedAt: DateTime.now(),
      );
      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> handleCorrectAnswer() {
    try {
      if (_gameState == null || _gameState!.status != GameStatus.playing) {
        throw  CacheException('Game is not in playing state');
      }

      final newScore =
          _gameState!.score + _getScoreForCorrectAnswer(_gameState!.gameType);

      _gameState = _gameState!.copyWith(
        score: newScore,
        correctAnswers: _gameState!.correctAnswers + 1,
      );

      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> handleWrongAnswer() {
    try {
      if (_gameState == null || _gameState!.status != GameStatus.playing) {
        throw  CacheException('Game is not in playing state');
      }

      final newLives = _gameState!.lives - 1;

      _gameState = _gameState!.copyWith(
        lives: newLives,
        wrongAnswers: _gameState!.wrongAnswers + 1,
      );

      if (newLives <= 0) {
        _endGame();
      }

      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message  .toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> skipWord() {
    try {
      if (_gameState == null || _gameState!.status != GameStatus.playing) {
        throw  CacheException('Game is not in playing state');
      }

      _gameState = _gameState!.copyWith(
        skippedAnswers: _gameState!.skippedAnswers + 1,
      );

      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> pauseGame() {
    try {
      if (_gameState == null || _gameState!.status != GameStatus.playing) {
        throw  CacheException('Game is not in playing state');
      }

      _gameState = _gameState!.copyWith(status: GameStatus.paused);
      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> resumeGame() {
    try {
      if (_gameState == null || _gameState!.status != GameStatus.paused) {
        throw  CacheException('Game is not in paused state');
      }

      _gameState = _gameState!.copyWith(status: GameStatus.playing);
      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString() ));
    }
  }

  @override
  Either<Failure, GameStateEntity> updateTimer(int timeRemaining) {
    try {
      if (_gameState == null || _gameState!.status != GameStatus.playing) {
        throw  CacheException('Game is not in playing state');
      }

      if (timeRemaining <= 0) {
        _endGame();
      } else {
        _gameState = _gameState!.copyWith(timeRemaining: timeRemaining);
      }

      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, GameStateEntity> resetGame() {
    try {
      _gameState = GameStateModel.fromEntity(GameStateEntity.initial(), const []);
      return Right(_gameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> setGameWords(List<WordModel> words) {
    try {
      _currentGameState =
          (_currentGameState ??
                  CurrentGameModel.fromEntity(
                    CurrentGameEntity.initial(),
                    words: const [],
                  ))
              .copyWith(words: words);
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> setCurrentWord(WordModel word) {
    try {
      _currentGameState =
          (_currentGameState ??
                  CurrentGameModel.fromEntity(
                    CurrentGameEntity.initial(),
                    words: const [],
                  ))
              .copyWith(currentWord: word);
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> setOptions(List<String> options) {
    try {
      _currentGameState =
          (_currentGameState ??
                  CurrentGameModel.fromEntity(
                    CurrentGameEntity.initial(),
                    words: const [],
                  ))
              .copyWith(options: options);
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> setSelectedAnswer(String answer) {
    try {
      _currentGameState =
          (_currentGameState ??
                  CurrentGameModel.fromEntity(
                    CurrentGameEntity.initial(),
                    words: const [],
                  ))
              .copyWith(selectedAnswer: answer);
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> setShowResult({required bool show}) {
    try {
      _currentGameState =
          (_currentGameState ??
                  CurrentGameModel.fromEntity(
                    CurrentGameEntity.initial(),
                    words: const [],
                  ))
              .copyWith(showResult: show);
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> setIsCorrect({required bool correct}) {
    try {
      _currentGameState =
          (_currentGameState ??
                  CurrentGameModel.fromEntity(
                    CurrentGameEntity.initial(),
                    words: const [],
                  ))
              .copyWith(isCorrect: correct);
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  @override
  Either<Failure, CurrentGameEntity> resetCurrentGame() {
    try {
      _currentGameState = CurrentGameModel.fromEntity(
        CurrentGameEntity.initial(),
        words: const [],
      );
      return Right(_currentGameState!);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    }
  }

  void _endGame() {
    if (_gameState == null) return;

    final totalQuestions = _gameState!.words.length;
    final accuracy = totalQuestions > 0
        ? (_gameState!.correctAnswers / totalQuestions * 100).round()
        : 0;

    _gameState = _gameState!.copyWith(
      status: GameStatus.completed,
      accuracy: accuracy,
      completedAt: DateTime.now(),
    );
  }

  int _getGameDuration(GameType gameType) {
    switch (gameType) {
      case GameType.wordMatching:
        return 300; // 5 minutes
      case GameType.sentenceBuilding:
        return 600; // 10 minutes
      case GameType.pronunciation:
        return 240; // 4 minutes
      case GameType.spelling:
        return 360; // 6 minutes
      case GameType.listening:
        return 300; // 5 minutes
    }
  }

  int _getScoreForCorrectAnswer(GameType gameType) {
    switch (gameType) {
      case GameType.wordMatching:
        return 10;
      case GameType.sentenceBuilding:
        return 20;
      case GameType.pronunciation:
        return 15;
      case GameType.spelling:
        return 15;
      case GameType.listening:
        return 12;
    }
  }
}
