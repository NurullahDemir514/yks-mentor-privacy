import 'package:mongo_dart/mongo_dart.dart';

class DailyGoal {
  final ObjectId? id;
  final int questionCount;
  final DateTime date;
  final String? userId;

  DailyGoal({
    this.id,
    required this.questionCount,
    DateTime? date,
    this.userId,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'questionCount': questionCount,
      'date': date.toIso8601String(),
      if (userId != null) 'userId': userId,
    };
  }

  factory DailyGoal.fromMap(Map<String, dynamic> map) {
    return DailyGoal(
      id: map['_id'] as ObjectId?,
      questionCount: map['questionCount'] as int,
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      userId: map['userId'] as String?,
    );
  }

  DailyGoal copyWith({
    ObjectId? id,
    int? questionCount,
    DateTime? date,
    String? userId,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      questionCount: questionCount ?? this.questionCount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}
