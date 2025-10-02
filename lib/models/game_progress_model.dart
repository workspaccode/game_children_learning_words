class GameProgressModel {
  GameProgressModel({
    this.id,
    required this.userId,
    required this.gameType,
    required this.level,
    required this.score,
    required this.maxScore,
    required this.timeSpent,
    required this.completedAt,
    required this.language,
  });

  factory GameProgressModel.fromMap(Map<String, dynamic> map) {
    return GameProgressModel(
      id: map['id'] as int?,
      userId: (map['user_id'] ?? '') as String,
      gameType: (map['game_type'] ?? '') as String,
      level: (map['level'] ?? 1) as int,
      score: (map['score'] ?? 0) as int,
      maxScore: (map['max_score'] ?? 0) as int,
      timeSpent: (map['time_spent'] ?? 0) as int,
      completedAt: DateTime.parse(map['completed_at'] as String),
      language: (map['language'] ?? 'ar') as String,
    );
  }
  final int? id;
  final String userId;
  final String gameType;
  final int level;
  final int score;
  final int maxScore;
  final int timeSpent; // in seconds
  final DateTime completedAt;
  final String language;

  GameProgressModel copyWith({
    int? id,
    String? userId,
    String? gameType,
    int? level,
    int? score,
    int? maxScore,
    int? timeSpent,
    DateTime? completedAt,
    String? language,
  }) {
    return GameProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      level: level ?? this.level,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      timeSpent: timeSpent ?? this.timeSpent,
      completedAt: completedAt ?? this.completedAt,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'game_type': gameType,
      'level': level,
      'score': score,
      'max_score': maxScore,
      'time_spent': timeSpent,
      'completed_at': completedAt.toIso8601String(),
      'language': language,
    };
  }

  @override
  String toString() {
    return 'GameProgressModel(id: $id, userId: $userId, gameType: $gameType, level: $level, score: $score, maxScore: $maxScore, timeSpent: $timeSpent, completedAt: $completedAt, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameProgressModel &&
        other.id == id &&
        other.userId == userId &&
        other.gameType == gameType &&
        other.level == level &&
        other.score == score &&
        other.maxScore == maxScore &&
        other.timeSpent == timeSpent &&
        other.completedAt == completedAt &&
        other.language == language;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        gameType.hashCode ^
        level.hashCode ^
        score.hashCode ^
        maxScore.hashCode ^
        timeSpent.hashCode ^
        completedAt.hashCode ^
        language.hashCode;
  }

  // Helper methods
  double get scorePercentage {
    if (maxScore == 0) return 0;
    return (score / maxScore) * 100;
  }

  String get gameTypeDisplayName {
    switch (gameType) {
      case 'word_completion':
        return 'إكمال الكلمات';
      case 'sentence_highlight':
        return 'تظليل الجمل';
      case 'pronunciation':
        return 'النطق';
      case 'letter_recognition':
        return 'التعرف على الحروف';
      case 'word_matching':
        return 'مطابقة الكلمات';
      case 'reading_comprehension':
        return 'فهم المقروء';
      default:
        return gameType;
    }
  }

  String get levelDisplayName {
    switch (level) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'متوسط';
      case 3:
        return 'متقدم';
      default:
        return 'المستوى $level';
    }
  }

  String get languageDisplayName {
    return language == 'ar' ? 'العربية' : 'الإنجليزية';
  }

  String get timeSpentFormatted {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;

    if (minutes > 0) {
      return '$minutesد $secondsث';
    } else {
      return '$secondsث';
    }
  }

  String get completedAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // Performance rating
  String get performanceRating {
    final percentage = scorePercentage;

    if (percentage >= 90) {
      return 'ممتاز';
    } else if (percentage >= 80) {
      return 'جيد جداً';
    } else if (percentage >= 70) {
      return 'جيد';
    } else if (percentage >= 60) {
      return 'مقبول';
    } else {
      return 'يحتاج تحسين';
    }
  }

  // Star rating (1-5 stars)
  int get starRating {
    final percentage = scorePercentage;

    if (percentage >= 90) {
      return 5;
    } else if (percentage >= 80) {
      return 4;
    } else if (percentage >= 70) {
      return 3;
    } else if (percentage >= 60) {
      return 2;
    } else {
      return 1;
    }
  }

  // Check if this is a new high score
  bool isHighScore(List<GameProgressModel> previousScores) {
    final sameGameScores = previousScores
        .where(
          (progress) =>
              progress.gameType == gameType &&
              progress.level == level &&
              progress.language == language,
        )
        .toList();

    if (sameGameScores.isEmpty) return true;

    final maxPreviousScore = sameGameScores
        .map((progress) => progress.score)
        .reduce((a, b) => a > b ? a : b);

    return score > maxPreviousScore;
  }

  // Calculate improvement from previous attempt
  double getImprovementPercentage(GameProgressModel? previousAttempt) {
    if (previousAttempt == null || previousAttempt.maxScore == 0) return 0;

    final currentPercentage = scorePercentage;
    final previousPercentage = previousAttempt.scorePercentage;

    return currentPercentage - previousPercentage;
  }

  // Get achievement badges based on performance
  List<String> getAchievementBadges() {
    final badges = <String>[];

    // Score-based badges
    if (scorePercentage == 100) {
      badges.add('perfect_score');
    } else if (scorePercentage >= 90) {
      badges.add('excellent');
    } else if (scorePercentage >= 80) {
      badges.add('great_job');
    }

    // Time-based badges
    if (timeSpent <= 60) {
      badges.add('speed_demon');
    } else if (timeSpent <= 120) {
      badges.add('quick_learner');
    }

    // Level-based badges
    if (level >= 3) {
      badges.add('advanced_player');
    }

    return badges;
  }

  // Calculate experience points earned
  int getExperiencePoints() {
    int basePoints = score;

    // Bonus for higher levels
    basePoints += (level - 1) * 10;

    // Bonus for perfect score
    if (scorePercentage == 100) {
      basePoints += 50;
    }

    // Time bonus (faster completion = more points)
    if (timeSpent <= 60) {
      basePoints += 20;
    } else if (timeSpent <= 120) {
      basePoints += 10;
    }

    return basePoints;
  }
}
