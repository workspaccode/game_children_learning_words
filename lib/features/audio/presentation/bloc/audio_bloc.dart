import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/audio_repository.dart';
import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  AudioBloc(this._audioRepository) : super(AudioInitial()) {
    on<PlaySoundEvent>(_onPlaySound);
    on<PlayBackgroundMusicEvent>(_onPlayBackgroundMusic);
    on<StopBackgroundMusicEvent>(_onStopBackgroundMusic);
    on<PauseBackgroundMusicEvent>(_onPauseBackgroundMusic);
    on<ResumeBackgroundMusicEvent>(_onResumeBackgroundMusic);
    on<SetVolumeEvent>(_onSetVolume);
    on<SetMusicVolumeEvent>(_onSetMusicVolume);
    on<ToggleMuteEvent>(_onToggleMute);
    on<SpeakEvent>(_onSpeak);
    on<StopSpeakingEvent>(_onStopSpeaking);
    on<SetSpeechRateEvent>(_onSetSpeechRate);
    on<SetSpeechPitchEvent>(_onSetSpeechPitch);
    on<SetSpeechVolumeEvent>(_onSetSpeechVolume);
    on<SetLanguageEvent>(_onSetLanguage);
  }

  final AudioRepository _audioRepository;

  Future<void> _onPlaySound(
    PlaySoundEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(AudioLoading());

    final result = await _audioRepository.playSound(event.soundPath);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  Future<void> _onPlayBackgroundMusic(
    PlayBackgroundMusicEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(AudioLoading());

    final result = await _audioRepository.playBackgroundMusic();

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  Future<void> _onStopBackgroundMusic(
    StopBackgroundMusicEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(AudioLoading());

    final result = await _audioRepository.stopBackgroundMusic();

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  Future<void> _onPauseBackgroundMusic(
    PauseBackgroundMusicEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(AudioLoading());

    final result = await _audioRepository.pauseBackgroundMusic();

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  Future<void> _onResumeBackgroundMusic(
    ResumeBackgroundMusicEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(AudioLoading());

    final result = await _audioRepository.resumeBackgroundMusic();

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onSetVolume(SetVolumeEvent event, Emitter<AudioState> emit) {
    emit(AudioLoading());

    final result = _audioRepository.setVolume(event.volume);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onSetMusicVolume(SetMusicVolumeEvent event, Emitter<AudioState> emit) {
    emit(AudioLoading());

    final result = _audioRepository.setMusicVolume(event.volume);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onToggleMute(ToggleMuteEvent event, Emitter<AudioState> emit) {
    emit(AudioLoading());

    final result = _audioRepository.toggleMute();

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  Future<void> _onSpeak(SpeakEvent event, Emitter<AudioState> emit) async {
    emit(AudioLoading());

    final result = await _audioRepository.speak(
      event.text,
      language: event.language,
    );

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  Future<void> _onStopSpeaking(
    StopSpeakingEvent event,
    Emitter<AudioState> emit,
  ) async {
    emit(AudioLoading());

    final result = await _audioRepository.stopSpeaking();

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onSetSpeechRate(SetSpeechRateEvent event, Emitter<AudioState> emit) {
    emit(AudioLoading());

    final result = _audioRepository.setSpeechRate(event.rate);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onSetSpeechPitch(SetSpeechPitchEvent event, Emitter<AudioState> emit) {
    emit(AudioLoading());

    final result = _audioRepository.setSpeechPitch(event.pitch);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onSetSpeechVolume(
    SetSpeechVolumeEvent event,
    Emitter<AudioState> emit,
  ) {
    emit(AudioLoading());

    final result = _audioRepository.setSpeechVolume(event.volume);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }

  void _onSetLanguage(SetLanguageEvent event, Emitter<AudioState> emit) {
    emit(AudioLoading());

    final result = _audioRepository.setLanguage(event.language);

    result.fold((failure) => emit(AudioError(failure)), (_) {
      final audioStateResult = _audioRepository.getAudioState();
      final ttsStateResult = _audioRepository.getTTSState();

      audioStateResult.fold((failure) => emit(AudioError(failure)), (
        audioState,
      ) {
        ttsStateResult.fold(
          (failure) => emit(AudioError(failure)),
          (ttsState) =>
              emit(AudioLoaded(audioState: audioState, ttsState: ttsState)),
        );
      });
    });
  }
}
