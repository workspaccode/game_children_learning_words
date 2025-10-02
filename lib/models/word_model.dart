import 'package:json_annotation/json_annotation.dart';

part 'word_model.g.dart';

@JsonSerializable()
class WordModel {
  WordModel({
    this.id,
    required this.wordAr,
    required this.wordEn,
    this.meaningAr,
    this.meaningEn,
    this.pronunciationAr,
    this.pronunciationEn,
    this.imageUrl,
    this.audioUrlAr,
    this.audioUrlEn,
    this.difficultyLevel = 1,
    this.category,
    this.createdBy,
    this.isActive = true,
    required this.createdAt,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int?,
      wordAr: (map['word_ar'] ?? '') as String,
      wordEn: (map['word_en'] ?? '') as String,
      meaningAr: map['meaning_ar'] as String?,
      meaningEn: map['meaning_en'] as String?,
      pronunciationAr: map['pronunciation_ar'] as String?,
      pronunciationEn: map['pronunciation_en'] as String?,
      imageUrl: map['image_url'] as String?,
      audioUrlAr: map['audio_url_ar'] as String?,
      audioUrlEn: map['audio_url_en'] as String?,
      difficultyLevel: (map['difficulty_level'] ?? 1) as int,
      category: map['category'] as String?,
      createdBy: map['created_by'] as String?,
      isActive: map['is_active'] is bool 
          ? map['is_active'] as bool 
          : (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory WordModel.fromJson(Map<String, dynamic> json) =>
      _$WordModelFromJson(json);
  final int? id;
  final String wordAr;
  final String wordEn;
  final String? meaningAr;
  final String? meaningEn;
  final String? pronunciationAr;
  final String? pronunciationEn;
  final String? imageUrl;
  final String? audioUrlAr;
  final String? audioUrlEn;
  final int difficultyLevel;
  final String? category;
  final String? createdBy;
  final bool isActive;
  final DateTime createdAt;

  WordModel copyWith({
    int? id,
    String? wordAr,
    String? wordEn,
    String? meaningAr,
    String? meaningEn,
    String? pronunciationAr,
    String? pronunciationEn,
    String? imageUrl,
    String? audioUrlAr,
    String? audioUrlEn,
    int? difficultyLevel,
    String? category,
    String? createdBy,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      wordAr: wordAr ?? this.wordAr,
      wordEn: wordEn ?? this.wordEn,
      meaningAr: meaningAr ?? this.meaningAr,
      meaningEn: meaningEn ?? this.meaningEn,
      pronunciationAr: pronunciationAr ?? this.pronunciationAr,
      pronunciationEn: pronunciationEn ?? this.pronunciationEn,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrlAr: audioUrlAr ?? this.audioUrlAr,
      audioUrlEn: audioUrlEn ?? this.audioUrlEn,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_ar': wordAr,
      'word_en': wordEn,
      'meaning_ar': meaningAr,
      'meaning_en': meaningEn,
      'pronunciation_ar': pronunciationAr,
      'pronunciation_en': pronunciationEn,
      'image_url': imageUrl,
      'audio_url_ar': audioUrlAr,
      'audio_url_en': audioUrlEn,
      'difficulty_level': difficultyLevel,
      'category': category,
      'created_by': createdBy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => _$WordModelToJson(this);

  @override
  String toString() {
    return 'WordModel(id: $id, wordAr: $wordAr, wordEn: $wordEn, meaningAr: $meaningAr, meaningEn: $meaningEn, pronunciationAr: $pronunciationAr, pronunciationEn: $pronunciationEn, imageUrl: $imageUrl, audioUrlAr: $audioUrlAr, audioUrlEn: $audioUrlEn, difficultyLevel: $difficultyLevel, category: $category, createdBy: $createdBy, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WordModel &&
        other.id == id &&
        other.wordAr == wordAr &&
        other.wordEn == wordEn &&
        other.meaningAr == meaningAr &&
        other.meaningEn == meaningEn &&
        other.pronunciationAr == pronunciationAr &&
        other.pronunciationEn == pronunciationEn &&
        other.imageUrl == imageUrl &&
        other.audioUrlAr == audioUrlAr &&
        other.audioUrlEn == audioUrlEn &&
        other.difficultyLevel == difficultyLevel &&
        other.category == category &&
        other.createdBy == createdBy &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        wordAr.hashCode ^
        wordEn.hashCode ^
        meaningAr.hashCode ^
        meaningEn.hashCode ^
        pronunciationAr.hashCode ^
        pronunciationEn.hashCode ^
        imageUrl.hashCode ^
        audioUrlAr.hashCode ^
        audioUrlEn.hashCode ^
        difficultyLevel.hashCode ^
        category.hashCode ^
        createdBy.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode;
  }

  // Helper methods
  String getWord(String language) {
    return language == 'ar' ? wordAr : wordEn;
  }

  String? getPronunciation(String language) {
    return language == 'ar' ? pronunciationAr : pronunciationEn;
  }

  String? getAudioUrl(String language) {
    return language == 'ar' ? audioUrlAr : audioUrlEn;
  }

  String? getMeaning(String language) {
    return language == 'ar' ? meaningAr : meaningEn;
  }

  // Getter for meaning (for backward compatibility)
  String? get meaning => meaningAr ?? meaningEn;

  String get difficultyLevelName {
    switch (difficultyLevel) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'متوسط';
      case 3:
        return 'متقدم';
      default:
        return 'مبتدئ';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case 'objects':
        return 'أشياء';
      case 'animals':
        return 'حيوانات';
      case 'colors':
        return 'ألوان';
      case 'numbers':
        return 'أرقام';
      case 'family':
        return 'عائلة';
      case 'food':
        return 'طعام';
      case 'nature':
        return 'طبيعة';
      case 'places':
        return 'أماكن';
      case 'actions':
        return 'أفعال';
      case 'emotions':
        return 'مشاعر';
      default:
        return category ?? 'عام';
    }
  }

  // Generate missing letters for word completion game
  List<String> generateMissingLetters({int maxMissing = 2}) {
    final word = wordAr;
    if (word.length <= 2) return [];

    final missingIndices = <int>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    // Randomly select indices to hide
    for (int i = 0; i < maxMissing && i < word.length - 1; i++) {
      int index;
      do {
        index = (random + i) % word.length;
      } while (missingIndices.contains(index));
      missingIndices.add(index);
    }

    return missingIndices.map((i) => word[i]).toList();
  }

  // Get word with missing letters replaced by underscores
  String getWordWithMissingLetters({int maxMissing = 2}) {
    final word = wordAr;
    if (word.length <= 2) return word;

    final missingIndices = <int>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    // Randomly select indices to hide
    for (int i = 0; i < maxMissing && i < word.length - 1; i++) {
      int index;
      do {
        index = (random + i) % word.length;
      } while (missingIndices.contains(index));
      missingIndices.add(index);
    }

    String result = '';
    for (int i = 0; i < word.length; i++) {
      if (missingIndices.contains(i)) {
        result += '_';
      } else {
        result += word[i];
      }
    }

    return result;
  }

  // Check if the word contains specific letters
  bool containsLetters(List<String> letters) {
    final word = wordAr.toLowerCase();
    return letters.every((letter) => word.contains(letter.toLowerCase()));
  }

  // Get word difficulty score based on length and complexity
  double get complexityScore {
    double score = wordAr.length * 0.5;

    // Add complexity for special Arabic characters
    final specialChars = ['ء', 'آ', 'أ', 'إ', 'ئ', 'ؤ', 'ة', 'ى'];
    for (final char in specialChars) {
      if (wordAr.contains(char)) {
        score += 0.5;
      }
    }

    return score;
  }
}
