class SentenceModel {
  SentenceModel({
    this.id,
    required this.sentenceAr,
    required this.sentenceEn,
    this.audioUrlAr,
    this.audioUrlEn,
    this.difficultyLevel = 1,
    this.category,
    this.createdBy,
    this.isActive = true,
    required this.createdAt,
  });

  factory SentenceModel.fromMap(Map<String, dynamic> map) {
    return SentenceModel(
      id: map['id'] as int?,
      sentenceAr: (map['sentence_ar'] ?? '') as String,
      sentenceEn: (map['sentence_en'] ?? '') as String,
      audioUrlAr: map['audio_url_ar'] as String?,
      audioUrlEn: map['audio_url_en'] as String?,
      difficultyLevel: (map['difficulty_level'] ?? 1) as int,
      category: map['category'] as String?,
      createdBy: map['created_by'] as String?,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  final int? id;
  final String sentenceAr;
  final String sentenceEn;
  final String? audioUrlAr;
  final String? audioUrlEn;
  final int difficultyLevel;
  final String? category;
  final String? createdBy;
  final bool isActive;
  final DateTime createdAt;

  SentenceModel copyWith({
    int? id,
    String? sentenceAr,
    String? sentenceEn,
    String? audioUrlAr,
    String? audioUrlEn,
    int? difficultyLevel,
    String? category,
    String? createdBy,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SentenceModel(
      id: id ?? this.id,
      sentenceAr: sentenceAr ?? this.sentenceAr,
      sentenceEn: sentenceEn ?? this.sentenceEn,
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
      'sentence_ar': sentenceAr,
      'sentence_en': sentenceEn,
      'audio_url_ar': audioUrlAr,
      'audio_url_en': audioUrlEn,
      'difficulty_level': difficultyLevel,
      'category': category,
      'created_by': createdBy,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SentenceModel(id: $id, sentenceAr: $sentenceAr, sentenceEn: $sentenceEn, audioUrlAr: $audioUrlAr, audioUrlEn: $audioUrlEn, difficultyLevel: $difficultyLevel, category: $category, createdBy: $createdBy, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SentenceModel &&
        other.id == id &&
        other.sentenceAr == sentenceAr &&
        other.sentenceEn == sentenceEn &&
        other.audioUrlAr == audioUrlAr &&
        other.audioUrlEn == audioUrlEn &&
        other.difficultyLevel == difficultyLevel &&
        other.category == category &&
        other.createdBy == createdBy &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    sentenceAr,
    sentenceEn,
    audioUrlAr,
    audioUrlEn,
    difficultyLevel,
    category,
    createdBy,
    isActive,
    createdAt,
  );

  // Helper methods
  String getSentence(String language) {
    return language == 'ar' ? sentenceAr : sentenceEn;
  }

  String? getAudioUrl(String language) {
    return language == 'ar' ? audioUrlAr : audioUrlEn;
  }

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
      case 'basic':
        return 'أساسي';
      case 'descriptions':
        return 'وصف';
      case 'questions':
        return 'أسئلة';
      case 'greetings':
        return 'تحيات';
      case 'family':
        return 'عائلة';
      case 'school':
        return 'مدرسة';
      case 'daily_life':
        return 'حياة يومية';
      case 'stories':
        return 'قصص';
      default:
        return category ?? 'عام';
    }
  }

  // Get words in the sentence
  List<String> getWords(String language) {
    final sentence = language == 'ar' ? sentenceAr : sentenceEn;
    return sentence.split(' ').where((word) => word.isNotEmpty).toList();
  }

  // Get word count
  int getWordCount(String language) {
    return getWords(language).length;
  }

  // Get sentence with highlighted word
  String getHighlightedSentence(String language, int wordIndex) {
    final words = getWords(language);
    if (wordIndex < 0 || wordIndex >= words.length) {
      return getSentence(language);
    }

    final highlightedWords = <String>[];
    for (int i = 0; i < words.length; i++) {
      if (i == wordIndex) {
        highlightedWords.add('**${words[i]}**'); // Markdown-style highlighting
      } else {
        highlightedWords.add(words[i]);
      }
    }

    return highlightedWords.join(' ');
  }

  // Get random word from sentence for highlighting game
  String getRandomWord(String language) {
    final words = getWords(language);
    if (words.isEmpty) return '';

    final random = DateTime.now().millisecondsSinceEpoch;
    final index = random % words.length;
    return words[index];
  }

  // Get random word index for highlighting game
  int getRandomWordIndex(String language) {
    final words = getWords(language);
    if (words.isEmpty) return -1;

    final random = DateTime.now().millisecondsSinceEpoch;
    return random % words.length;
  }

  // Check if sentence contains specific word
  bool containsWord(String word, String language) {
    final sentence = getSentence(language).toLowerCase();
    return sentence.contains(word.toLowerCase());
  }

  // Get sentence complexity score
  double get complexityScore {
    double score = getWordCount('ar') * 1.0;

    // Add complexity for punctuation
    final punctuation = ['.', '!', '?', '،', '؛', ':'];
    for (final punct in punctuation) {
      if (sentenceAr.contains(punct)) {
        score += 0.5;
      }
    }

    // Add complexity for special Arabic characters
    final specialChars = ['ء', 'آ', 'أ', 'إ', 'ئ', 'ؤ', 'ة', 'ى'];
    for (final char in specialChars) {
      if (sentenceAr.contains(char)) {
        score += 0.3;
      }
    }

    return score;
  }

  // Generate word positions for highlighting game
  List<Map<String, dynamic>> generateWordPositions(String language) {
    final words = getWords(language);
    final positions = <Map<String, dynamic>>[];

    int startIndex = 0;
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      positions.add({
        'word': word,
        'index': i,
        'startPosition': startIndex,
        'endPosition': startIndex + word.length,
      });
      startIndex += word.length + 1; // +1 for space
    }

    return positions;
  }

  // Get sentence with word at specific index removed
  String getSentenceWithMissingWord(String language, int wordIndex) {
    final words = getWords(language);
    if (wordIndex < 0 || wordIndex >= words.length) {
      return getSentence(language);
    }

    final modifiedWords = <String>[];
    for (int i = 0; i < words.length; i++) {
      if (i == wordIndex) {
        modifiedWords.add('_____'); // Placeholder for missing word
      } else {
        modifiedWords.add(words[i]);
      }
    }

    return modifiedWords.join(' ');
  }

  // Get reading time estimate in seconds
  int getEstimatedReadingTime() {
    // Average reading speed for children: 100-200 words per minute
    final wordCount = getWordCount('ar');
    return ((wordCount / 150) * 60).round(); // 150 WPM average
  }
}
