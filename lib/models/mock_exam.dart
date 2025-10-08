import 'package:yks_mentor/models/weekly_plan.dart';
import 'package:yks_mentor/models/mock_exam_result.dart';
import 'package:yks_mentor/constants/exam_type.dart';
import 'package:yks_mentor/constants/exam_subjects.dart';

class MockExam {
  final String publisher;
  final ExamType examType;
  final AYTField? aytField;
  final bool isCompleted;
  final DateTime date;
  final MockExamResult? result;
  final bool isBranchExam;
  final String? branch;
  final String? examId;
  final String topic;

  MockExam({
    required this.publisher,
    required this.examType,
    this.aytField,
    required this.isCompleted,
    required this.date,
    this.result,
    this.isBranchExam = false,
    this.branch,
    this.examId,
    required this.topic,
  }) {
    // AYT sınavı için alan zorunlu (branş denemesi değilse)
    assert(isBranchExam || examType != ExamType.AYT || aytField != null);
    // Branş denemesi için branch zorunlu
    assert(!isBranchExam || branch != null);
  }

  factory MockExam.fromPlanItem(DailyPlanItem plan, {MockExamResult? result}) {
    String? branch;
    ExamType examType;
    AYTField? aytField;

    // Tamamlanma durumunu kontrol et
    bool isCompleted = plan.isCompleted || result != null;

    // Branş denemesi kontrolü
    if (plan.subject.startsWith('TYT ') || plan.subject.startsWith('AYT ')) {
      examType = plan.subject.startsWith('TYT ') ? ExamType.TYT : ExamType.AYT;
      branch = plan.subject;

      // AYT branş denemesi için alan belirleme
      if (examType == ExamType.AYT) {
        if (['AYT Matematik', 'AYT Fizik', 'AYT Kimya', 'AYT Biyoloji']
            .contains(plan.subject)) {
          aytField = AYTField.MF;
        } else if (['AYT Edebiyat', 'AYT Tarih-1', 'AYT Coğrafya-1']
            .contains(plan.subject)) {
          aytField = AYTField.EA;
        } else if (['AYT Tarih-2', 'AYT Coğrafya-2', 'AYT Felsefe']
            .contains(plan.subject)) {
          aytField = AYTField.SOZ;
        }
      }

      return MockExam(
        publisher: plan.subject,
        examType: examType,
        aytField: aytField,
        isCompleted: isCompleted,
        date: plan.date,
        result: result,
        isBranchExam: true,
        branch: branch,
        examId: plan.examId,
        topic: plan.topic,
      );
    }

    // Normal deneme sınavı
    if (plan.subject == 'TYT') {
      examType = ExamType.TYT;
    } else if (plan.subject.startsWith('AYT ')) {
      examType = ExamType.AYT;
      if (plan.subject.contains('Sayısal') || plan.subject.contains('MF')) {
        aytField = AYTField.MF;
      } else if (plan.subject.contains('Eşit Ağırlık') ||
          plan.subject.contains('EA')) {
        aytField = AYTField.EA;
      } else if (plan.subject.contains('Sözel') ||
          plan.subject.contains('SOZ')) {
        aytField = AYTField.SOZ;
      }
    } else {
      examType = _parseExamType(plan.subject);
      aytField = examType == ExamType.AYT ? _parseAYTField(plan.subject) : null;
    }

    return MockExam(
      publisher: plan.subject.split(' ').last,
      examType: examType,
      aytField: aytField,
      isCompleted: isCompleted,
      date: plan.date,
      result: result,
      isBranchExam: false,
      branch: null,
      examId: plan.examId,
      topic: plan.topic,
    );
  }

  static ExamType _parseExamType(String subject) {
    if (subject.toUpperCase().contains('TYT')) return ExamType.TYT;
    if (subject.toUpperCase().contains('AYT')) return ExamType.AYT;
    throw ArgumentError('Geçersiz sınav türü: $subject');
  }

  static AYTField? _parseAYTField(String subject) {
    if (!subject.toUpperCase().contains('AYT')) return null;

    // Sayısal alan dersleri
    if (['Matematik', 'Fizik', 'Kimya', 'Biyoloji']
        .any((s) => subject.contains(s))) {
      return AYTField.MF;
    }

    // EA alan dersleri
    if (['Edebiyat', 'Tarih-1', 'Coğrafya-1'].any((s) => subject.contains(s))) {
      return AYTField.EA;
    }

    // Sözel alan dersleri
    if (['Tarih-2', 'Coğrafya-2', 'Felsefe'].any((s) => subject.contains(s))) {
      return AYTField.SOZ;
    }

    // Alan adı doğrudan belirtilmişse
    if (subject.contains('Sayısal') || subject.contains('MF'))
      return AYTField.MF;
    if (subject.contains('Eşit Ağırlık') || subject.contains('EA'))
      return AYTField.EA;
    if (subject.contains('Sözel') || subject.contains('SOZ'))
      return AYTField.SOZ;

    // Varsayılan olarak MF alanı
    return AYTField.MF;
  }

  DailyPlanItem toDailyPlanItem() {
    String subject;
    int targetQuestions;

    if (isBranchExam && branch != null) {
      subject = branch!;
      targetQuestions = ExamSubjects.getBranchExamQuestionCount(branch!);
    } else {
      subject = examType.name;
      if (examType == ExamType.AYT && aytField != null) {
        subject = 'AYT ${aytField!.displayName}';
      }
      targetQuestions = examType == ExamType.TYT ? 120 : 80;
    }

    return DailyPlanItem(
      subject: subject,
      topic: topic,
      targetQuestions: targetQuestions,
      isMockExam: true,
      isCompleted: isCompleted,
      date: date,
      examId: examId,
    );
  }

  double? get net => result?.totalNet;
  Map<String, SubjectResult>? get results => result?.results;
  Duration? get duration => result?.duration;

  int? get correctAnswers => results?.values
      .fold<int>(0, (sum, result) => sum + result.correctAnswers);

  int? get wrongAnswers =>
      results?.values.fold<int>(0, (sum, result) => sum + result.wrongAnswers);

  int? get emptyAnswers =>
      results?.values.fold<int>(0, (sum, result) => sum + result.emptyAnswers);

  int get _expectedTotal {
    if (isBranchExam && branch != null) {
      final examPrefix = examType == ExamType.TYT ? 'TYT' : 'AYT';
      return ExamSubjects.mockExamQuestionCounts[examPrefix]
              ?[branch!.substring(4)] ??
          40;
    }
    return examType == ExamType.TYT ? 120 : 80;
  }

  int _getExpectedTotalForSubject(String subject) {
    if (isBranchExam && branch != null) {
      final examPrefix = examType == ExamType.TYT ? 'TYT' : 'AYT';
      return ExamSubjects.mockExamQuestionCounts[examPrefix]
              ?[subject.substring(4)] ??
          40;
    }

    final examPrefix = examType == ExamType.TYT ? 'TYT' : 'AYT';
    return ExamSubjects.mockExamQuestionCounts[examPrefix]?[subject] ?? 40;
  }

  MockExam copyWith({
    String? publisher,
    ExamType? examType,
    AYTField? aytField,
    bool? isCompleted,
    DateTime? date,
    MockExamResult? result,
    bool? isBranchExam,
    String? branch,
    String? examId,
    String? topic,
  }) {
    return MockExam(
      publisher: publisher ?? this.publisher,
      examType: examType ?? this.examType,
      aytField: aytField ?? this.aytField,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      result: result ?? this.result,
      isBranchExam: isBranchExam ?? this.isBranchExam,
      branch: branch ?? this.branch,
      examId: examId ?? this.examId,
      topic: topic ?? this.topic,
    );
  }
}
