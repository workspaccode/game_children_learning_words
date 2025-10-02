import 'package:equatable/equatable.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class PlaySoundEvent extends AudioEvent {
  const PlaySoundEvent(this.soundPath);

  final String soundPath;

  @override
  List<Object?> get props => [soundPath];
}

class PlayBackgroundMusicEvent extends AudioEvent {}

class StopBackgroundMusicEvent extends AudioEvent {}

class PauseBackgroundMusicEvent extends AudioEvent {}

class ResumeBackgroundMusicEvent extends AudioEvent {}

class SetVolumeEvent extends AudioEvent {
  const SetVolumeEvent(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

class SetMusicVolumeEvent extends AudioEvent {
  const SetMusicVolumeEvent(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

class ToggleMuteEvent extends AudioEvent {}

class SpeakEvent extends AudioEvent {
  const SpeakEvent(this.text, {this.language});

  final String text;
  final String? language;

  @override
  List<Object?> get props => [text, language];
}

class StopSpeakingEvent extends AudioEvent {}

class SetSpeechRateEvent extends AudioEvent {
  const SetSpeechRateEvent(this.rate);

  final double rate;

  @override
  List<Object?> get props => [rate];
}

class SetSpeechPitchEvent extends AudioEvent {
  const SetSpeechPitchEvent(this.pitch);

  final double pitch;

  @override
  List<Object?> get props => [pitch];
}

class SetSpeechVolumeEvent extends AudioEvent {
  const SetSpeechVolumeEvent(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

class SetLanguageEvent extends AudioEvent {
  const SetLanguageEvent(this.language);

  final String language;

  @override
  List<Object?> get props => [language];
}
