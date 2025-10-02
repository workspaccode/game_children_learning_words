import 'package:equatable/equatable.dart';

class TTSStateEntity extends Equatable {
  const TTSStateEntity({
    required this.isSpeaking,
    this.currentText,
    required this.speechRate,
    required this.speechPitch,
    required this.speechVolume,
    required this.language,
    this.error,
  });

  factory TTSStateEntity.initial() {
    return const TTSStateEntity(
      isSpeaking: false,
      speechRate: 0.5,
      speechPitch: 1,
      speechVolume: 1,
      language: 'ar-SA',
    );
  }

  final bool isSpeaking;
  final String? currentText;
  final double speechRate;
  final double speechPitch;
  final double speechVolume;
  final String language;
  final String? error;

  TTSStateEntity copyWith({
    bool? isSpeaking,
    String? currentText,
    double? speechRate,
    double? speechPitch,
    double? speechVolume,
    String? language,
    String? error,
  }) {
    return TTSStateEntity(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentText: currentText,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      speechVolume: speechVolume ?? this.speechVolume,
      language: language ?? this.language,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isSpeaking,
    currentText,
    speechRate,
    speechPitch,
    speechVolume,
    language,
    error,
  ];
}
