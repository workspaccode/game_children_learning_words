import '../../../../models/word_model.dart';
import '../../domain/entities/current_game_entity.dart';

class CurrentGameModel extends CurrentGameEntity {
  const CurrentGameModel({
    required super.options,
    super.selectedAnswer,
    required super.showResult,
    required super.isCorrect,
    required this.words,
    this.currentWord,
  });

  factory CurrentGameModel.fromEntity(
    CurrentGameEntity entity, {
    required List<WordModel> words,
    WordModel? currentWord,
  }) {
    return CurrentGameModel(
      options: entity.options,
      selectedAnswer: entity.selectedAnswer,
      showResult: entity.showResult,
      isCorrect: entity.isCorrect,
      words: words,
      currentWord: currentWord,
    );
  }

  final List<WordModel> words;
  final WordModel? currentWord;

  @override
  CurrentGameModel copyWith({
    List<WordModel>? words,
    WordModel? currentWord,
    List<String>? options,
    String? selectedAnswer,
    bool? showResult,
    bool? isCorrect,
  }) {
    return CurrentGameModel(
      words: words ?? this.words,
      currentWord: currentWord ?? this.currentWord,
      options: options ?? this.options,
      selectedAnswer: selectedAnswer,
      showResult: showResult ?? this.showResult,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
