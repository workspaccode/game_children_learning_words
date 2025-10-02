import 'package:equatable/equatable.dart';

class CurrentGameEntity extends Equatable {
  const CurrentGameEntity({
    required this.options,
    this.selectedAnswer,
    required this.showResult,
    required this.isCorrect,
  });

  factory CurrentGameEntity.initial() {
    return const CurrentGameEntity(
      options: [],
      showResult: false,
      isCorrect: false,
    );
  }

  final List<String> options;
  final String? selectedAnswer;
  final bool showResult;
  final bool isCorrect;

  CurrentGameEntity copyWith({
    List<String>? options,
    String? selectedAnswer,
    bool? showResult,
    bool? isCorrect,
  }) {
    return CurrentGameEntity(
      options: options ?? this.options,
      selectedAnswer: selectedAnswer,
      showResult: showResult ?? this.showResult,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  List<Object?> get props => [options, selectedAnswer, showResult, isCorrect];
}
