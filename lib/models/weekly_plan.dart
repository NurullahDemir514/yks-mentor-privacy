import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

class WeeklyPlan {
  final ObjectId? id;
  final String userId;
  final DateTime startDate;
  final Map<String, List<DailyPlanItem>> dailyPlans;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyPlan({
    this.id,
    required this.userId,
    required this.startDate,
    required this.dailyPlans,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'dailyPlans': dailyPlans.map(
        (key, value) =>
            MapEntry(key, value.map((item) => item.toJson()).toList()),
      ),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WeeklyPlan.fromMap(Map<String, dynamic> map) {
    return WeeklyPlan(
      id: map['_id'] is ObjectId ? map['_id'] as ObjectId : null,
      userId: map['userId'] as String,
      startDate: DateTime.parse(map['startDate']),
      dailyPlans: (map['dailyPlans'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) =>
                  DailyPlanItem.fromJson(item as Map<String, dynamic>))
              .toList(),
        ),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  WeeklyPlan copyWith({
    ObjectId? id,
    String? userId,
    DateTime? startDate,
    Map<String, List<DailyPlanItem>>? dailyPlans,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int getTodayTarget() {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final todayPlans = dailyPlans[dayName] ?? [];
    return todayPlans.fold<int>(
      0,
      (sum, plan) => sum + plan.targetQuestions,
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return '';
    }
  }
}

class DailyPlanItem {
  final String subject;
  final String topic;
  final int targetQuestions;
  final bool isMockExam;
  final bool isCompleted;
  final int duration;
  final String? publisher;
  final bool isDeleted;
  final DateTime date;
  final String? examId;

  DailyPlanItem({
    required this.subject,
    required this.topic,
    required this.targetQuestions,
    this.isMockExam = false,
    this.isCompleted = false,
    this.duration = 0,
    this.publisher,
    this.isDeleted = false,
    DateTime? date,
    this.examId,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'topic': topic,
        'targetQuestions': targetQuestions,
        'isMockExam': isMockExam,
        'isCompleted': isCompleted,
        'duration': duration,
        'publisher': publisher,
        'isDeleted': isDeleted,
        'date': date.toIso8601String(),
        if (examId != null) 'examId': examId,
      };

  factory DailyPlanItem.fromJson(Map<String, dynamic> json) => DailyPlanItem(
        subject: json['subject'] as String,
        topic: json['topic'] as String,
        targetQuestions: json['targetQuestions'] as int,
        isMockExam: json['isMockExam'] as bool? ?? false,
        isCompleted: json['isCompleted'] as bool? ?? false,
        duration: json['duration'] as int? ?? 0,
        publisher: json['publisher'] as String?,
        isDeleted: json['isDeleted'] as bool? ?? false,
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        examId: json['examId'] as String?,
      );

  DailyPlanItem copyWith({
    String? subject,
    String? topic,
    int? targetQuestions,
    bool? isMockExam,
    bool? isCompleted,
    int? duration,
    String? publisher,
    bool? isDeleted,
    DateTime? date,
    String? examId,
  }) =>
      DailyPlanItem(
        subject: subject ?? this.subject,
        topic: topic ?? this.topic,
        targetQuestions: targetQuestions ?? this.targetQuestions,
        isMockExam: isMockExam ?? this.isMockExam,
        isCompleted: isCompleted ?? this.isCompleted,
        duration: duration ?? this.duration,
        publisher: publisher ?? this.publisher,
        isDeleted: isDeleted ?? this.isDeleted,
        date: date ?? this.date,
        examId: examId ?? this.examId,
      );
}
