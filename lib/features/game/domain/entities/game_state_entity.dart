import 'package:equatable/equatable.dart';

enum GameStatus { idle, playing, paused, completed }

enum GameType {
  wordMatching,
  sentenceBuilding,
  pronunciation,
  spelling,
  listening,
}

class GameStateEntity extends Equatable {
  const GameStateEntity({
    required this.status,
    required this.gameType,
    required this.level,
    required this.currentWordIndex,
    required this.score,
    required this.lives,
    required this.timeRemaining,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.accuracy,
    this.startedAt,
    this.completedAt,
  });

  factory GameStateEntity.initial() {
    return const GameStateEntity(
      status: GameStatus.idle,
      gameType: GameType.wordMatching,
      level: 1,
      currentWordIndex: 0,
      score: 0,
      lives: 3,
      timeRemaining: 0,
      correctAnswers: 0,
      wrongAnswers: 0,
      skippedAnswers: 0,
      accuracy: 0,
    );
  }

  final GameStatus status;
  final GameType gameType;
  final int level;
  final int currentWordIndex;
  final int score;
  final int lives;
  final int timeRemaining;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final int accuracy;
  final DateTime? startedAt;
  final DateTime? completedAt;

  GameStateEntity copyWith({
    GameStatus? status,
    GameType? gameType,
    int? level,
    int? currentWordIndex,
    int? score,
    int? lives,
    int? timeRemaining,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedAnswers,
    int? accuracy,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return GameStateEntity(
      status: status ?? this.status,
      gameType: gameType ?? this.gameType,
      level: level ?? this.level,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedAnswers: skippedAnswers ?? this.skippedAnswers,
      accuracy: accuracy ?? this.accuracy,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    status,
    gameType,
    level,
    currentWordIndex,
    score,
    lives,
    timeRemaining,
    correctAnswers,
    wrongAnswers,
    skippedAnswers,
    accuracy,
    startedAt,
    completedAt,
  ];
}
