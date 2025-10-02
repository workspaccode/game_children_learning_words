import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/audio_state_entity.dart';
import '../../domain/entities/tts_state_entity.dart';

abstract class AudioLocalDataSource {
  // Audio Functions
  Future<void> playSound(String soundPath);
  Future<void> playBackgroundMusic();
  Future<void> stopBackgroundMusic();
  Future<void> pauseBackgroundMusic();
  Future<void> resumeBackgroundMusic();
  void setVolume(double volume);
  void setMusicVolume(double volume);
  void toggleMute();

  // TTS Functions
  Future<void> speak(String text, {String? language});
  Future<void> stopSpeaking();
  void setSpeechRate(double rate);
  void setSpeechPitch(double pitch);
  void setSpeechVolume(double volume);
  void setLanguage(String language);

  // State Getters
  AudioStateEntity getAudioState();
  TTSStateEntity getTTSState();
}

class AudioLocalDataSourceImpl implements AudioLocalDataSource {
  AudioLocalDataSourceImpl(
    this._audioPlayer,
    this._backgroundPlayer,
    this._tts,
  );

  final AudioPlayer _audioPlayer;
  final AudioPlayer _backgroundPlayer;
  final FlutterTts _tts;

  AudioStateEntity _audioState = AudioStateEntity.initial();
  TTSStateEntity _ttsState = TTSStateEntity.initial();

  @override
  AudioStateEntity getAudioState() => _audioState;

  @override
  TTSStateEntity getTTSState() => _ttsState;

  @override
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: false);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to pause background music: ${e.toString()}');
    }
  }

  @override
  Future<void> playBackgroundMusic() async {
    try {
      await _backgroundPlayer.play();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: true);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to play background music: ${e.toString()}');
    }
  }

  @override
  Future<void> playSound(String soundPath) async {
    try {
      _audioState = _audioState.copyWith(
        isPlaying: true,
        currentSound: soundPath,
      );
      await _audioPlayer.setAsset(soundPath);
      await _audioPlayer.play();
      _audioState = _audioState.copyWith(isPlaying: false);
    } catch (e) {
      _audioState = _audioState.copyWith(isPlaying: false, error: e.toString());
      throw Exception('Failed to play sound: ${e.toString()}');
    }
  }

  @override
  Future<void> resumeBackgroundMusic() async {
    try {
      await _backgroundPlayer.play();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: true);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to resume background music: ${e.toString()}');
    }
  }

  @override
  void setLanguage(String language) {
    try {
      _tts.setLanguage(language);
      _ttsState = _ttsState.copyWith(language: language);
    } catch (e) {
      _ttsState = _ttsState.copyWith(error: e.toString());
      throw Exception('Failed to set language: ${e.toString()}');
    }
  }

  @override
  void setMusicVolume(double volume) {
    try {
      _backgroundPlayer.setVolume(volume);
      _audioState = _audioState.copyWith(musicVolume: volume);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to set music volume: ${e.toString()}');
    }
  }

  @override
  void setSpeechPitch(double pitch) {
    try {
      _tts.setPitch(pitch);
      _ttsState = _ttsState.copyWith(speechPitch: pitch);
    } catch (e) {
      _ttsState = _ttsState.copyWith(error: e.toString());
      throw Exception('Failed to set speech pitch: ${e.toString()}');
    }
  }

  @override
  void setSpeechRate(double rate) {
    try {
      _tts.setSpeechRate(rate);
      _ttsState = _ttsState.copyWith(speechRate: rate);
    } catch (e) {
      _ttsState = _ttsState.copyWith(error: e.toString());
      throw Exception('Failed to set speech rate: ${e.toString()}');
    }
  }

  @override
  void setSpeechVolume(double volume) {
    try {
      _tts.setVolume(volume);
      _ttsState = _ttsState.copyWith(speechVolume: volume);
    } catch (e) {
      _ttsState = _ttsState.copyWith(error: e.toString());
      throw Exception('Failed to set speech volume: ${e.toString()}');
    }
  }

  @override
  void setVolume(double volume) {
    try {
      _audioPlayer.setVolume(volume);
      _audioState = _audioState.copyWith(volume: volume);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to set volume: ${e.toString()}');
    }
  }

  @override
  Future<void> speak(String text, {String? language}) async {
    try {
      _ttsState = _ttsState.copyWith(isSpeaking: true, currentText: text);
      if (language != null) {
        await _tts.setLanguage(language);
        _ttsState = _ttsState.copyWith(language: language);
      }
      await _tts.speak(text);
      _ttsState = _ttsState.copyWith(isSpeaking: false);
    } catch (e) {
      _ttsState = _ttsState.copyWith(isSpeaking: false, error: e.toString());
      throw Exception('Failed to speak: ${e.toString()}');
    }
  }

  @override
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _audioState = _audioState.copyWith(isBackgroundMusicPlaying: false);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to stop background music: ${e.toString()}');
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
      _ttsState = _ttsState.copyWith(isSpeaking: false);
    } catch (e) {
      _ttsState = _ttsState.copyWith(error: e.toString());
      throw Exception('Failed to stop speaking: ${e.toString()}');
    }
  }

  @override
  void toggleMute() {
    try {
      final newMuteState = !_audioState.isMuted;
      final volume = newMuteState ? 0.0 : _audioState.volume;
      final musicVolume = newMuteState ? 0.0 : _audioState.musicVolume;

      _audioPlayer.setVolume(volume);
      _backgroundPlayer.setVolume(musicVolume);
      _audioState = _audioState.copyWith(isMuted: newMuteState);
    } catch (e) {
      _audioState = _audioState.copyWith(error: e.toString());
      throw Exception('Failed to toggle mute: ${e.toString()}');
    }
  }
}
