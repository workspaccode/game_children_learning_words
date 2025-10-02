import '../../../../models/word_model.dart';
import '../../domain/entities/game_state_entity.dart';

class GameStateModel extends GameStateEntity {
  const GameStateModel({
    required super.status,
    required super.gameType,
    required super.level,
    required super.currentWordIndex,
    required super.score,
    required super.lives,
    required super.timeRemaining,
    required super.correctAnswers,
    required super.wrongAnswers,
    required super.skippedAnswers,
    required super.accuracy,
    required this.words,
    super.startedAt,
    super.completedAt,
  });

  factory GameStateModel.fromEntity(
    GameStateEntity entity,
    List<WordModel> words,
  ) {
    return GameStateModel(
      status: entity.status,
      gameType: entity.gameType,
      level: entity.level,
      currentWordIndex: entity.currentWordIndex,
      score: entity.score,
      lives: entity.lives,
      timeRemaining: entity.timeRemaining,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      skippedAnswers: entity.skippedAnswers,
      accuracy: entity.accuracy,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      words: words,
    );
  }

  final List<WordModel> words;

  WordModel? get currentWord {
    if (currentWordIndex < words.length) {
      return words[currentWordIndex];
    }
    return null;
  }

  double get progress {
    if (words.isEmpty) return 0;
    return currentWordIndex / words.length;
  }

  @override
  GameStateModel copyWith({
    GameStatus? status,
    GameType? gameType,
    int? level,
    List<WordModel>? words,
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
    return GameStateModel(
      status: status ?? this.status,
      gameType: gameType ?? this.gameType,
      level: level ?? this.level,
      words: words ?? this.words,
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
}
