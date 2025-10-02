import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../services/audio_service.dart';
import '../../domain/entities/audio_state_entity.dart';
import '../../domain/entities/tts_state_entity.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl(this._audioService);

  final AudioService _audioService;

  AudioStateEntity _audioState = AudioStateEntity.initial();
  TTSStateEntity _ttsState = TTSStateEntity.initial();

  @override
  Future<Either<Failure, void>> playSound(String soundPath) async {
    try {
      _audioState = _audioState.copyWith(
        isPlaying: true,
        currentSound: soundPath,
      );
      await _audioService.playSound(soundPath);
      _audioState = _audioState.copyWith(isPlaying: false);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(isPlaying: false, error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Future<Either<Failure, void>> playBackgroundMusic() async {
    try {
      await _audioService.playBackgroundMusic();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: true);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Future<Either<Failure, void>> stopBackgroundMusic() async {
    try {
      await _audioService.stopBackgroundMusic();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: false);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Future<Either<Failure, void>> pauseBackgroundMusic() async {
    try {
      await _audioService.pauseBackgroundMusic();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: false);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Future<Either<Failure, void>> resumeBackgroundMusic() async {
    try {
      await _audioService.resumeBackgroundMusic();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: true);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> setVolume(double volume) {
    try {
      _audioService.setVolume(volume);
      _audioState = _audioState.copyWith(volume: volume);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> setMusicVolume(double volume) {
    try {
      _audioService.setMusicVolume(volume);
      _audioState = _audioState.copyWith(musicVolume: volume);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> toggleMute() {
    try {
      final newMuteState = !_audioState.isMuted;
      _audioService.setMute(newMuteState);
      _audioState = _audioState.copyWith(isMuted: newMuteState);
      return const Right(null);
    } on AudioException catch (e) {
      _audioState = _audioState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Future<Either<Failure, void>> speak(String text, {String? language}) async {
    try {
      _ttsState = _ttsState.copyWith(isSpeaking: true, currentText: text);
      await _audioService.speak(text, language: language);
      _ttsState = _ttsState.copyWith(isSpeaking: false);
      return const Right(null);
    } on AudioException catch (e) {
      _ttsState = _ttsState.copyWith(isSpeaking: false, error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Future<Either<Failure, void>> stopSpeaking() async {
    try {
      await _audioService.stopSpeaking();
      _ttsState = _ttsState.copyWith(isSpeaking: false);
      return const Right(null);
    } on AudioException catch (e) {
      _ttsState = _ttsState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> setSpeechRate(double rate) {
    try {
      _audioService.setSpeechRate(rate);
      _ttsState = _ttsState.copyWith(speechRate: rate);
      return const Right(null);
    } on AudioException catch (e) {
      _ttsState = _ttsState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> setSpeechPitch(double pitch) {
    try {
      _audioService.setSpeechPitch(pitch);
      _ttsState = _ttsState.copyWith(speechPitch: pitch);
      return const Right(null);
    } on AudioException catch (e) {
      _ttsState = _ttsState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> setSpeechVolume(double volume) {
    try {
      _audioService.setSpeechVolume(volume);
      _ttsState = _ttsState.copyWith(speechVolume: volume);
      return const Right(null);
    } on AudioException catch (e) {
      _ttsState = _ttsState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, void> setLanguage(String language) {
    try {
      _audioService.setLanguage(language);
      _ttsState = _ttsState.copyWith(language: language);
      return const Right(null);
    } on AudioException catch (e) {
      _ttsState = _ttsState.copyWith(error: e.message);
      return Left(AudioFailure(e.message ?? 'Unknown audio error'));
    }
  }

  @override
  Either<Failure, AudioStateEntity> getAudioState() {
    return Right(_audioState);
  }

  @override
  Either<Failure, TTSStateEntity> getTTSState() {
    return Right(_ttsState);
  }
}
