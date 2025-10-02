import 'package:json_annotation/json_annotation.dart';

part 'classroom_model.g.dart';

@JsonSerializable()
class ClassroomModel {
  ClassroomModel({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.description,
    required this.subject,
    required this.gradeLevel,
    this.studentIds = const [],
    this.parentIds = const [],
    required this.isActive,
    this.meetingSchedule,
    this.resourceLinks = const [],
    required this.createdAt,
    this.updatedAt,
    this.settings,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) =>
      _$ClassroomModelFromJson(json);

  factory ClassroomModel.fromMap(Map<String, dynamic> map) {
    return ClassroomModel(
      id: map['id'] as String,
      teacherId: map['teacher_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      gradeLevel: map['grade_level'] as int,
      studentIds: List<String>.from(map['student_ids'] as List? ?? []),
      parentIds: List<String>.from(map['parent_ids'] as List? ?? []),
      isActive: map['is_active'] as bool? ?? true,
      meetingSchedule: map['meeting_schedule'] != null
          ? MeetingSchedule.fromMap(
              map['meeting_schedule'] as Map<String, dynamic>,
            )
          : null,
      resourceLinks: List<String>.from(map['resource_links'] as List? ?? []),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      settings: map['settings'] != null
          ? ClassroomSettings.fromMap(map['settings'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String teacherId;
  final String name;
  final String description;
  final String subject;
  final int gradeLevel;
  final List<String> studentIds; // Max 4 students per subscription
  final List<String> parentIds;
  final bool isActive;
  final MeetingSchedule? meetingSchedule;
  final List<String> resourceLinks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ClassroomSettings? settings;

  Map<String, dynamic> toJson() => _$ClassroomModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'name': name,
      'description': description,
      'subject': subject,
      'grade_level': gradeLevel,
      'student_ids': studentIds,
      'parent_ids': parentIds,
      'is_active': isActive,
      'meeting_schedule': meetingSchedule?.toMap(),
      'resource_links': resourceLinks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'settings': settings?.toMap(),
    };
  }

  // Helper methods
  int get studentCount => studentIds.length;
  bool get isFull => studentCount >= 4;
  bool get hasSchedule => meetingSchedule != null;

  String get gradeLevelName {
    switch (gradeLevel) {
      case 1:
        return 'الصف الأول';
      case 2:
        return 'الصف الثاني';
      case 3:
        return 'الصف الثالث';
      case 4:
        return 'الصف الرابع';
      case 5:
        return 'الصف الخامس';
      case 6:
        return 'الصف السادس';
      default:
        return 'غير محدد';
    }
  }

  ClassroomModel copyWith({
    String? id,
    String? teacherId,
    String? name,
    String? description,
    String? subject,
    int? gradeLevel,
    List<String>? studentIds,
    List<String>? parentIds,
    bool? isActive,
    MeetingSchedule? meetingSchedule,
    List<String>? resourceLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClassroomSettings? settings,
  }) {
    return ClassroomModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      studentIds: studentIds ?? this.studentIds,
      parentIds: parentIds ?? this.parentIds,
      isActive: isActive ?? this.isActive,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      resourceLinks: resourceLinks ?? this.resourceLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }
}

@JsonSerializable()
class MeetingSchedule {
  MeetingSchedule({
    required this.daysOfWeek,
    required this.startTime,
    required this.duration,
    this.timezone = 'Asia/Riyadh',
    this.isRecurring = true,
  });

  factory MeetingSchedule.fromJson(Map<String, dynamic> json) =>
      _$MeetingScheduleFromJson(json);

  factory MeetingSchedule.fromMap(Map<String, dynamic> map) {
    return MeetingSchedule(
      daysOfWeek: List<int>.from(map['days_of_week'] as List),
      startTime: map['start_time'] as String,
      duration: Duration(minutes: map['duration'] as int),
      timezone: map['timezone'] as String? ?? 'Asia/Riyadh',
      isRecurring: map['is_recurring'] as bool? ?? true,
    );
  }

  final List<int> daysOfWeek; // 1-7 (Monday-Sunday)
  final String startTime; // HH:MM format
  final Duration duration;
  final String timezone;
  final bool isRecurring;

  Map<String, dynamic> toJson() => _$MeetingScheduleToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'days_of_week': daysOfWeek,
      'start_time': startTime,
      'duration': duration.inMinutes,
      'timezone': timezone,
      'is_recurring': isRecurring,
    };
  }

  String get daysText {
    final dayNames = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return daysOfWeek.map((day) => dayNames[day - 1]).join(', ');
  }

  String get timeText => '$startTime (${duration.inMinutes} دقيقة)';
}

@JsonSerializable()
class ClassroomSettings {
  ClassroomSettings({
    this.allowParentMessages = true,
    this.sendProgressReports = true,
    this.autoAssignActivities = false,
    this.difficultyLevel = 1,
    this.focusAreas = const [],
    this.rewardPoints = true,
    this.notificationSettings,
  });

  factory ClassroomSettings.fromJson(Map<String, dynamic> json) =>
      _$ClassroomSettingsFromJson(json);

  factory ClassroomSettings.fromMap(Map<String, dynamic> map) {
    return ClassroomSettings(
      allowParentMessages: map['allow_parent_messages'] as bool? ?? true,
      sendProgressReports: map['send_progress_reports'] as bool? ?? true,
      autoAssignActivities: map['auto_assign_activities'] as bool? ?? false,
      difficultyLevel: map['difficulty_level'] as int? ?? 1,
      focusAreas: List<String>.from(map['focus_areas'] as List? ?? []),
      rewardPoints: map['reward_points'] as bool? ?? true,
      notificationSettings: map['notification_settings'] != null
          ? NotificationSettings.fromMap(
              map['notification_settings'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final bool allowParentMessages;
  final bool sendProgressReports;
  final bool autoAssignActivities;
  final int difficultyLevel;
  final List<String> focusAreas;
  final bool rewardPoints;
  final NotificationSettings? notificationSettings;

  Map<String, dynamic> toJson() => _$ClassroomSettingsToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'allow_parent_messages': allowParentMessages,
      'send_progress_reports': sendProgressReports,
      'auto_assign_activities': autoAssignActivities,
      'difficulty_level': difficultyLevel,
      'focus_areas': focusAreas,
      'reward_points': rewardPoints,
      'notification_settings': notificationSettings?.toMap(),
    };
  }
}

@JsonSerializable()
class NotificationSettings {
  NotificationSettings({
    this.dailyReminders = true,
    this.weeklyReports = true,
    this.achievementAlerts = true,
    this.parentUpdates = true,
    this.reminderTime = '18:00',
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      dailyReminders: map['daily_reminders'] as bool? ?? true,
      weeklyReports: map['weekly_reports'] as bool? ?? true,
      achievementAlerts: map['achievement_alerts'] as bool? ?? true,
      parentUpdates: map['parent_updates'] as bool? ?? true,
      reminderTime: map['reminder_time'] as String? ?? '18:00',
    );
  }

  final bool dailyReminders;
  final bool weeklyReports;
  final bool achievementAlerts;
  final bool parentUpdates;
  final String reminderTime;

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'daily_reminders': dailyReminders,
      'weekly_reports': weeklyReports,
      'achievement_alerts': achievementAlerts,
      'parent_updates': parentUpdates,
      'reminder_time': reminderTime,
    };
  }
}
