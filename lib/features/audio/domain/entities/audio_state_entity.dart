import 'package:equatable/equatable.dart';

class AudioStateEntity extends Equatable {
  const AudioStateEntity({
    required this.isPlaying,
    required this.isBackgroundMusicPlaying,
    this.currentSound,
    required this.volume,
    required this.musicVolume,
    required this.isMuted,
    this.error,
  });

  factory AudioStateEntity.initial() {
    return const AudioStateEntity(
      isPlaying: false,
      isBackgroundMusicPlaying: false,
      volume: 1,
      musicVolume: 0.5,
      isMuted: false,
    );
  }

  final bool isPlaying;
  final bool isBackgroundMusicPlaying;
  final String? currentSound;
  final double volume;
  final double musicVolume;
  final bool isMuted;
  final String? error;

  AudioStateEntity copyWith({
    bool? isPlaying,
    bool? isBackgroundMusicPlaying,
    String? currentSound,
    double? volume,
    double? musicVolume,
    bool? isMuted,
    String? error,
  }) {
    return AudioStateEntity(
      isPlaying: isPlaying ?? this.isPlaying,
      isBackgroundMusicPlaying:
          isBackgroundMusicPlaying ?? this.isBackgroundMusicPlaying,
      currentSound: currentSound,
      volume: volume ?? this.volume,
      musicVolume: musicVolume ?? this.musicVolume,
      isMuted: isMuted ?? this.isMuted,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isPlaying,
    isBackgroundMusicPlaying,
    currentSound,
    volume,
    musicVolume,
    isMuted,
    error,
  ];
}
