import 'package:mongo_dart/mongo_dart.dart';

class MockExamResult {
  final ObjectId? id;
  final String userId;
  final String examType;
  final String publisher;
  final Map<String, SubjectResult> results;
  final Duration duration;
  final DateTime date;
  final bool isBranchExam;
  final String? branch;
  final String? examId;

  MockExamResult({
    this.id,
    required this.userId,
    required this.examType,
    required this.publisher,
    required this.results,
    required this.duration,
    required this.date,
    this.isBranchExam = false,
    this.branch,
    this.examId,
  });

  factory MockExamResult.fromMap(Map<String, dynamic> map) {
    return MockExamResult(
      id: map['_id'] as ObjectId?,
      userId: map['userId'] as String,
      examType: map['examType'] as String,
      publisher: map['publisher'] as String,
      results: (map['results'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          SubjectResult.fromMap(value as Map<String, dynamic>),
        ),
      ),
      duration: Duration(milliseconds: map['duration'] as int),
      date: DateTime.parse(map['date'] as String),
      isBranchExam: map['isBranchExam'] as bool? ?? false,
      branch: map['branch'] as String?,
      examId: map['examId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'examType': examType,
      'publisher': publisher,
      'results': results.map((key, value) => MapEntry(key, value.toMap())),
      'duration': duration.inMilliseconds,
      'date': date.toIso8601String(),
      'isBranchExam': isBranchExam,
      if (branch != null) 'branch': branch,
      if (examId != null) 'examId': examId,
    };
  }

  double get totalNet {
    return results.values.fold(0.0, (sum, result) => sum + result.net);
  }
}

class SubjectResult {
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;

  SubjectResult({
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
  });

  factory SubjectResult.fromMap(Map<String, dynamic> map) {
    return SubjectResult(
      correctAnswers: map['correctAnswers'] as int,
      wrongAnswers: map['wrongAnswers'] as int,
      emptyAnswers: map['emptyAnswers'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'emptyAnswers': emptyAnswers,
    };
  }

  double get net => correctAnswers - (wrongAnswers * 0.25);
}
