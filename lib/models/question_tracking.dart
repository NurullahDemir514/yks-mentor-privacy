import 'package:mongo_dart/mongo_dart.dart';

class QuestionTracking {
  final ObjectId? id;
  final String userId;
  final String subject;
  final String topic;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final DateTime date;
  final String? notes;
  bool isExpanded;
  final bool isMockExam;
  final int? duration; // Dakika cinsinden süre

  QuestionTracking({
    this.id,
    required this.userId,
    required this.subject,
    required this.topic,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.date,
    this.notes,
    this.isExpanded = false,
    this.isMockExam = false,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'subject': subject,
      'topic': topic,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'emptyAnswers': emptyAnswers,
      'date': date.toIso8601String(),
      if (notes != null) 'notes': notes,
      'isMockExam': isMockExam,
      if (duration != null) 'duration': duration,
    };
  }

  factory QuestionTracking.fromMap(Map<String, dynamic> map) {
    return QuestionTracking(
      id: map['_id'] is ObjectId ? map['_id'] as ObjectId : null,
      userId: map['userId'] is ObjectId
          ? (map['userId'] as ObjectId).toHexString()
          : map['userId'] as String,
      subject: map['subject'] as String,
      topic: map['topic'] as String,
      totalQuestions: map['totalQuestions'] as int,
      correctAnswers: map['correctAnswers'] as int,
      wrongAnswers: map['wrongAnswers'] as int,
      emptyAnswers: map['emptyAnswers'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      isMockExam: map['isMockExam'] as bool? ?? false,
      duration: map['duration'] as int?,
    );
  }

  QuestionTracking copyWith({
    ObjectId? id,
    String? userId,
    String? subject,
    String? topic,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? emptyAnswers,
    DateTime? date,
    String? notes,
    bool? isMockExam,
    int? duration,
  }) {
    return QuestionTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      emptyAnswers: emptyAnswers ?? this.emptyAnswers,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isMockExam: isMockExam ?? this.isMockExam,
      duration: duration ?? this.duration,
    );
  }
}
