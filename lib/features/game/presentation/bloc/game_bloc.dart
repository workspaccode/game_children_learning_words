import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/word_model.dart';
import '../../data/models/game_state_model.dart';
import '../../domain/entities/current_game_entity.dart';
import '../../domain/repositories/game_repository.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this._gameRepository) : super(GameInitial()) {
    on<StartGameEvent>(_onStartGame);
    on<NextWordEvent>(_onNextWord);
    on<CorrectAnswerEvent>(_onCorrectAnswer);
    on<WrongAnswerEvent>(_onWrongAnswer);
    on<SkipWordEvent>(_onSkipWord);
    on<PauseGameEvent>(_onPauseGame);
    on<ResumeGameEvent>(_onResumeGame);
    on<UpdateTimerEvent>(_onUpdateTimer);
    on<ResetGameEvent>(_onResetGame);
    on<SetSelectedAnswerEvent>(_onSetSelectedAnswer);
    on<SetShowResultEvent>(_onSetShowResult);
    on<SetIsCorrectEvent>(_onSetIsCorrect);
    on<ResetCurrentGameEvent>(_onResetCurrentGame);
  }

  final GameRepository _gameRepository;
  Timer? _timer;

  FutureOr<void> _onStartGame(StartGameEvent event, Emitter<GameState> emit) {
    final words = _getWordsForLevel(event.level); // Replace with your logic

    final result = _gameRepository.startGame(
      gameType: event.gameType,
      level: event.level,
      words: words,
    );

    result.fold((failure) => emit(GameError(failure)), (gameState) {
      // Start the game timer
      _startTimer(gameState.timeRemaining);

      // Generate options for the first word
      if (words.isNotEmpty) {
        _setCurrentWord(words[0]);
        _generateOptions(words[0], words);
      }

      // Get current game state
      final currentGameResult = _gameRepository.getCurrentGameState();

      currentGameResult.fold(
        (failure) => emit(GameError(failure)),
        (currentGameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  FutureOr<void> _onNextWord(NextWordEvent event, Emitter<GameState> emit) {
    final gameStateResult = _gameRepository.getGameState();

    gameStateResult.fold((failure) => emit(GameError(failure)), (gameState) {
      if (gameState is! GameStateModel) return;

      if (gameState.currentWordIndex + 1 >= gameState.words.length) {
        _timer?.cancel();
        emit(GameStateCompleted(gameState));
      } else {
        final nextWord = gameState.words[gameState.currentWordIndex + 1];
        _setCurrentWord(nextWord);
        _generateOptions(nextWord, gameState.words);

        // Get current game state
        final currentGameResult = _gameRepository.getCurrentGameState();

        currentGameResult.fold(
          (failure) => emit(GameError(failure)),
          (currentGameState) => emit(
            GameStateLoaded(
              gameState: gameState,
              currentGameState: currentGameState,
            ),
          ),
        );
      }
    });
  }

  FutureOr<void> _onCorrectAnswer(
    CorrectAnswerEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.handleCorrectAnswer();

    result.fold((failure) => emit(GameError(failure)), (gameState) {
      // Get current game state
      final currentGameResult = _gameRepository.getCurrentGameState();

      currentGameResult.fold(
        (failure) => emit(GameError(failure)),
        (currentGameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  FutureOr<void> _onWrongAnswer(
    WrongAnswerEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.handleWrongAnswer();

    result.fold((failure) => emit(GameError(failure)), (gameState) {
      if (gameState.lives <= 0) {
        _timer?.cancel();
        emit(GameStateCompleted(gameState));
      } else {
        // Get current game state
        final currentGameResult = _gameRepository.getCurrentGameState();

        currentGameResult.fold(
          (failure) => emit(GameError(failure)),
          (currentGameState) => emit(
            GameStateLoaded(
              gameState: gameState,
              currentGameState: currentGameState,
            ),
          ),
        );
      }
    });
  }

  FutureOr<void> _onSkipWord(SkipWordEvent event, Emitter<GameState> emit) {
    final result = _gameRepository.skipWord();

    result.fold((failure) => emit(GameError(failure)), (gameState) {
      add(NextWordEvent());
    });
  }

  FutureOr<void> _onPauseGame(PauseGameEvent event, Emitter<GameState> emit) {
    _timer?.cancel();
    final result = _gameRepository.pauseGame();

    result.fold(
      (failure) => emit(GameError(failure)),
      (gameState) => emit(GameStatePaused(gameState)),
    );
  }

  FutureOr<void> _onResumeGame(ResumeGameEvent event, Emitter<GameState> emit) {
    final result = _gameRepository.resumeGame();

    result.fold((failure) => emit(GameError(failure)), (gameState) {
      _startTimer(gameState.timeRemaining);

      // Get current game state
      final currentGameResult = _gameRepository.getCurrentGameState();

      currentGameResult.fold(
        (failure) => emit(GameError(failure)),
        (currentGameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  FutureOr<void> _onUpdateTimer(
    UpdateTimerEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.updateTimer(event.timeRemaining);

    result.fold((failure) => emit(GameError(failure)), (gameState) {
      if (event.timeRemaining <= 0) {
        _timer?.cancel();
        emit(GameStateCompleted(gameState));
      } else {
        // Get current game state
        final currentGameResult = _gameRepository.getCurrentGameState();

        currentGameResult.fold(
          (failure) => emit(GameError(failure)),
          (currentGameState) => emit(
            GameStateLoaded(
              gameState: gameState,
              currentGameState: currentGameState,
            ),
          ),
        );
      }
    });
  }

  FutureOr<void> _onResetGame(ResetGameEvent event, Emitter<GameState> emit) {
    _timer?.cancel();
    final result = _gameRepository.resetGame();

    result.fold(
      (failure) => emit(GameError(failure)),
      (gameState) => emit(
        GameStateLoaded(
          gameState: gameState,
          currentGameState: CurrentGameEntity.initial(),
        ),
      ),
    );
  }

  FutureOr<void> _onSetSelectedAnswer(
    SetSelectedAnswerEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.setSelectedAnswer(event.answer);

    result.fold((failure) => emit(GameError(failure)), (currentGameState) {
      final gameStateResult = _gameRepository.getGameState();
      gameStateResult.fold(
        (failure) => emit(GameError(failure)),
        (gameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  FutureOr<void> _onSetShowResult(
    SetShowResultEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.setShowResult(show: event.show);

    result.fold((failure) => emit(GameError(failure)), (currentGameState) {
      final gameStateResult = _gameRepository.getGameState();
      gameStateResult.fold(
        (failure) => emit(GameError(failure)),
        (gameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  FutureOr<void> _onSetIsCorrect(
    SetIsCorrectEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.setIsCorrect(correct: event.correct);

    result.fold((failure) => emit(GameError(failure)), (currentGameState) {
      final gameStateResult = _gameRepository.getGameState();
      gameStateResult.fold(
        (failure) => emit(GameError(failure)),
        (gameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  FutureOr<void> _onResetCurrentGame(
    ResetCurrentGameEvent event,
    Emitter<GameState> emit,
  ) {
    final result = _gameRepository.resetCurrentGame();

    result.fold((failure) => emit(GameError(failure)), (currentGameState) {
      final gameStateResult = _gameRepository.getGameState();
      gameStateResult.fold(
        (failure) => emit(GameError(failure)),
        (gameState) => emit(
          GameStateLoaded(
            gameState: gameState,
            currentGameState: currentGameState,
          ),
        ),
      );
    });
  }

  void _startTimer(int duration) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration - timer.tick <= 0) {
        timer.cancel();
      }
      add(UpdateTimerEvent(duration - timer.tick));
    });
  }

  void _setCurrentWord(WordModel word) {
    _gameRepository.setCurrentWord(word);
  }

  void _generateOptions(WordModel correctWord, List<WordModel> allWords) {
    final random = Random();
    final options = <String>[];

    // Add the correct answer
    options.add(correctWord.wordAr);

    // Add random incorrect answers
    final incorrectWords = List<WordModel>.from(allWords)
      ..remove(correctWord)
      ..shuffle(random);

    for (var i = 0; i < min(3, incorrectWords.length); i++) {
      options.add(incorrectWords[i].wordAr);
    }

    // Shuffle options
    options.shuffle(random);

    // Set options in current game state
    _gameRepository.setOptions(options);
  }

  List<WordModel> _getWordsForLevel(int level) {
    // Replace this with your logic to get words for the level
    return [];
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
