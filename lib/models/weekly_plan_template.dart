import 'package:mongo_dart/mongo_dart.dart';
import 'weekly_plan.dart';

class WeeklyPlanTemplate {
  final ObjectId? id;
  final String? userId;
  final String templateName;
  final Map<String, List<DailyPlanItem>> defaultPlans;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyPlanTemplate({
    this.id,
    this.userId,
    required this.templateName,
    required this.defaultPlans,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      if (userId != null) 'userId': userId,
      'templateName': templateName,
      'defaultPlans': defaultPlans.map(
        (key, value) =>
            MapEntry(key, value.map((item) => item.toJson()).toList()),
      ),
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WeeklyPlanTemplate.fromMap(Map<String, dynamic> map) {
    return WeeklyPlanTemplate(
      id: map['_id'] is ObjectId ? map['_id'] as ObjectId : null,
      userId: map['userId'] is ObjectId
          ? (map['userId'] as ObjectId).toHexString()
          : map['userId'] as String?,
      templateName: map['templateName'] as String,
      defaultPlans: (map['defaultPlans'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) =>
                  DailyPlanItem.fromJson(item as Map<String, dynamic>))
              .toList(),
        ),
      ),
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  WeeklyPlan toWeeklyPlan(String userId) {
    return WeeklyPlan(
      startDate: DateTime.now(),
      dailyPlans: Map<String, List<DailyPlanItem>>.from(defaultPlans),
      userId: userId,
    );
  }
}
