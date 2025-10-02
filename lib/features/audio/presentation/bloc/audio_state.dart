import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/audio_state_entity.dart';
import '../../domain/entities/tts_state_entity.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioError extends AudioState {
  const AudioError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class AudioLoaded extends AudioState {
  const AudioLoaded({required this.audioState, required this.ttsState});

  final AudioStateEntity audioState;
  final TTSStateEntity ttsState;

  @override
  List<Object?> get props => [audioState, ttsState];
}
