import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/audio_state_entity.dart';
import '../entities/tts_state_entity.dart';

abstract class AudioRepository {
  // Audio Functions
  Future<Either<Failure, void>> playSound(String soundPath);
  Future<Either<Failure, void>> playBackgroundMusic();
  Future<Either<Failure, void>> stopBackgroundMusic();
  Future<Either<Failure, void>> pauseBackgroundMusic();
  Future<Either<Failure, void>> resumeBackgroundMusic();
  Either<Failure, void> setVolume(double volume);
  Either<Failure, void> setMusicVolume(double volume);
  Either<Failure, void> toggleMute();

  // TTS Functions
  Future<Either<Failure, void>> speak(String text, {String? language});
  Future<Either<Failure, void>> stopSpeaking();
  Either<Failure, void> setSpeechRate(double rate);
  Either<Failure, void> setSpeechPitch(double pitch);
  Either<Failure, void> setSpeechVolume(double volume);
  Either<Failure, void> setLanguage(String language);

  // State Getters
  Either<Failure, AudioStateEntity> getAudioState();
  Either<Failure, TTSStateEntity> getTTSState();
}
