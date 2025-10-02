import 'package:json_annotation/json_annotation.dart';

part 'daily_activity_model.g.dart';

@JsonSerializable()
class DailyActivityModel {
  DailyActivityModel({
    required this.id,
    required this.childId,
    required this.parentId,
    this.teacherId,
    required this.date,
    required this.activities,
    required this.status,
    this.notes,
    this.parentNotes,
    this.teacherFeedback,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) =>
      _$DailyActivityModelFromJson(json);

  factory DailyActivityModel.fromMap(Map<String, dynamic> map) {
    return DailyActivityModel(
      id: map['id'] as String,
      childId: map['child_id'] as String,
      parentId: map['parent_id'] as String,
      teacherId: map['teacher_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      activities: (map['activities'] as List)
          .map(
            (activity) =>
                ActivityItem.fromMap(activity as Map<String, dynamic>),
          )
          .toList(),
      status: _parseActivityStatus(map['status'] as String),
      notes: map['notes'] as String?,
      parentNotes: map['parent_notes'] as String?,
      teacherFeedback: map['teacher_feedback'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  final String id;
  final String childId;
  final String parentId;
  final String? teacherId;
  final DateTime date;
  final List<ActivityItem> activities;
  final ActivityStatus status;
  final String? notes;
  final String? parentNotes;
  final String? teacherFeedback;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => _$DailyActivityModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'parent_id': parentId,
      'teacher_id': teacherId,
      'date': date.toIso8601String(),
      'activities': activities.map((activity) => activity.toMap()).toList(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'parent_notes': parentNotes,
      'teacher_feedback': teacherFeedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Helper methods
  double get completionPercentage {
    if (activities.isEmpty) return 0;
    final completedCount = activities.where((a) => a.isCompleted).length;
    return completedCount / activities.length;
  }

  int get totalPoints {
    return activities.fold(
      0,
      (total, activity) => total + (activity.isCompleted ? activity.points : 0),
    );
  }

  Duration get totalTimeSpent {
    return activities.fold(
      Duration.zero,
      (total, activity) => total + (activity.timeSpent ?? Duration.zero),
    );
  }

  bool get isCompleted => status == ActivityStatus.completed;
  bool get isInProgress => status == ActivityStatus.inProgress;
  bool get isPending => status == ActivityStatus.pending;
  bool get isOverdue =>
      DateTime.now().isAfter(date.add(const Duration(days: 1))) && !isCompleted;

  static ActivityStatus _parseActivityStatus(String status) {
    switch (status) {
      case 'pending':
        return ActivityStatus.pending;
      case 'inProgress':
        return ActivityStatus.inProgress;
      case 'completed':
        return ActivityStatus.completed;
      case 'skipped':
        return ActivityStatus.skipped;
      default:
        return ActivityStatus.pending;
    }
  }

  DailyActivityModel copyWith({
    String? id,
    String? childId,
    String? parentId,
    String? teacherId,
    DateTime? date,
    List<ActivityItem>? activities,
    ActivityStatus? status,
    String? notes,
    String? parentNotes,
    String? teacherFeedback,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return DailyActivityModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      parentNotes: parentNotes ?? this.parentNotes,
      teacherFeedback: teacherFeedback ?? this.teacherFeedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

@JsonSerializable()
class ActivityItem {
  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.estimatedDuration,
    required this.points,
    required this.isRequired,
    this.gameType,
    this.wordIds = const [],
    this.sentenceIds = const [],
    this.resourceUrl,
    this.isCompleted = false,
    this.completedAt,
    this.timeSpent,
    this.score,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);

  factory ActivityItem.fromMap(Map<String, dynamic> map) {
    return ActivityItem(
      id: map['id'] as String,
      type: _parseActivityType(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      difficultyLevel: map['difficulty_level'] as int,
      estimatedDuration: Duration(minutes: map['estimated_duration'] as int),
      points: map['points'] as int,
      isRequired: map['is_required'] as bool,
      gameType: map['game_type'] as String?,
      wordIds: List<String>.from(map['word_ids'] as List? ?? []),
      sentenceIds: List<String>.from(map['sentence_ids'] as List? ?? []),
      resourceUrl: map['resource_url'] as String?,
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      timeSpent: map['time_spent'] != null
          ? Duration(seconds: map['time_spent'] as int)
          : null,
      score: map['score'] as int?,
    );
  }

  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final int difficultyLevel;
  final Duration estimatedDuration;
  final int points;
  final bool isRequired;
  final String? gameType;
  final List<String> wordIds;
  final List<String> sentenceIds;
  final String? resourceUrl;
  final bool isCompleted;
  final DateTime? completedAt;
  final Duration? timeSpent;
  final int? score;

  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'estimated_duration': estimatedDuration.inMinutes,
      'points': points,
      'is_required': isRequired,
      'game_type': gameType,
      'word_ids': wordIds,
      'sentence_ids': sentenceIds,
      'resource_url': resourceUrl,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'time_spent': timeSpent?.inSeconds,
      'score': score,
    };
  }

  // Helper methods
  String get statusIcon {
    if (isCompleted) return '✅';
    if (isRequired) return '⭐';
    return '📝';
  }

  String get difficultyLabel {
    switch (difficultyLevel) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'متوسط';
      case 3:
        return 'متقدم';
      default:
        return 'غير محدد';
    }
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.game:
        return 'لعبة تعليمية';
      case ActivityType.lesson:
        return 'درس';
      case ActivityType.exercise:
        return 'تمرين';
      case ActivityType.reading:
        return 'قراءة';
      case ActivityType.listening:
        return 'استماع';
      case ActivityType.speaking:
        return 'تحدث';
      case ActivityType.writing:
        return 'كتابة';
      case ActivityType.assessment:
        return 'تقييم';
    }
  }

  static ActivityType _parseActivityType(String type) {
    switch (type) {
      case 'game':
        return ActivityType.game;
      case 'lesson':
        return ActivityType.lesson;
      case 'exercise':
        return ActivityType.exercise;
      case 'reading':
        return ActivityType.reading;
      case 'listening':
        return ActivityType.listening;
      case 'speaking':
        return ActivityType.speaking;
      case 'writing':
        return ActivityType.writing;
      case 'assessment':
        return ActivityType.assessment;
      default:
        return ActivityType.exercise;
    }
  }

  ActivityItem copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? description,
    int? difficultyLevel,
    Duration? estimatedDuration,
    int? points,
    bool? isRequired,
    String? gameType,
    List<String>? wordIds,
    List<String>? sentenceIds,
    String? resourceUrl,
    bool? isCompleted,
    DateTime? completedAt,
    Duration? timeSpent,
    int? score,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      points: points ?? this.points,
      isRequired: isRequired ?? this.isRequired,
      gameType: gameType ?? this.gameType,
      wordIds: wordIds ?? this.wordIds,
      sentenceIds: sentenceIds ?? this.sentenceIds,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      timeSpent: timeSpent ?? this.timeSpent,
      score: score ?? this.score,
    );
  }
}

enum ActivityType {
  game, // لعبة تعليمية
  lesson, // درس
  exercise, // تمرين
  reading, // قراءة
  listening, // استماع
  speaking, // تحدث
  writing, // كتابة
  assessment, // تقييم
}

enum ActivityStatus {
  pending, // في الانتظار
  inProgress, // قيد التنفيذ
  completed, // مكتمل
  skipped, // تم تجاهله
}
