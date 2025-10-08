import 'package:mongo_dart/mongo_dart.dart';

class TimerSession {
  final ObjectId? id;
  final String subject;
  final String topic;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<PauseDuration> pauses;
  final int? solvedQuestionCount;
  final String? notes;
  final bool isPlanned;
  final String? userId;
  final bool isMockExam;
  final String? examId;

  TimerSession({
    this.id,
    required this.subject,
    required this.topic,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.pauses,
    this.solvedQuestionCount,
    this.notes,
    this.isPlanned = false,
    this.userId,
    this.isMockExam = false,
    this.examId,
  });

  double? get questionsPerMinute {
    if (solvedQuestionCount == null || solvedQuestionCount == 0) return 0.0;
    final minutes = netDuration.inMilliseconds / 60000.0;
    if (minutes <= 0) return 0.0;
    try {
      return (solvedQuestionCount! / minutes).isFinite
          ? solvedQuestionCount! / minutes
          : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Duration get netDuration {
    final total = endTime.difference(startTime);
    Duration pauseTotal = Duration.zero;
    for (var pause in pauses) {
      if (pause.resumeTime != null) {
        pauseTotal += pause.resumeTime!.difference(pause.pauseTime);
      }
    }
    return total - pauseTotal;
  }

  factory TimerSession.fromMap(Map<String, dynamic> map) {
    return TimerSession(
      id: map['_id'] as ObjectId?,
      subject: map['subject'] as String,
      topic: map['topic'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      duration: Duration(milliseconds: map['duration'] as int),
      pauses: (map['pauses'] as List)
          .map((p) => PauseDuration.fromJson(p as Map<String, dynamic>))
          .toList(),
      solvedQuestionCount: map['solvedQuestionCount'] as int?,
      notes: map['notes'] as String?,
      isPlanned: map['isPlanned'] as bool? ?? false,
      userId: map['userId'] as String?,
      isMockExam: map['isMockExam'] as bool? ?? false,
      examId: map['examId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'subject': subject,
      'topic': topic,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration.inMilliseconds,
      'pauses': pauses.map((p) => p.toJson()).toList(),
      if (solvedQuestionCount != null)
        'solvedQuestionCount': solvedQuestionCount,
      'notes': notes,
      'isPlanned': isPlanned,
      'userId': userId,
      'isMockExam': isMockExam,
      'examId': examId,
    };
  }
}

class PauseDuration {
  final DateTime pauseTime;
  DateTime? resumeTime;

  PauseDuration({
    required this.pauseTime,
    this.resumeTime,
  });

  Duration? get duration => resumeTime?.difference(pauseTime);

  Map<String, dynamic> toJson() => {
        'pauseTime': pauseTime.toIso8601String(),
        'resumeTime': resumeTime?.toIso8601String(),
      };

  factory PauseDuration.fromJson(Map<String, dynamic> json) => PauseDuration(
        pauseTime: DateTime.parse(json['pauseTime'] as String),
        resumeTime: json['resumeTime'] != null
            ? DateTime.parse(json['resumeTime'] as String)
            : null,
      );
}
