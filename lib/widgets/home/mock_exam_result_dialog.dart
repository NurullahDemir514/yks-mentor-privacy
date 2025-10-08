import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yks_mentor/models/mock_exam_result.dart';
import '../../constants/theme.dart';
import '../../models/mock_exam.dart';
import '../../constants/exam_type.dart';
import '../../services/auth_service.dart';
import '../../services/mock_exam_service.dart';
import '../../constants/exam_subjects.dart';
import 'mock_exam_result_dialog/exam_header.dart';
import 'mock_exam_result_dialog/subject_card.dart';
import 'mock_exam_result_dialog/total_stats.dart';
import 'mock_exam_result_dialog/action_buttons.dart';
import 'package:provider/provider.dart';
import '../../providers/weekly_plan_provider.dart';
import 'package:bson/bson.dart';

class MockExamResultDialog extends StatefulWidget {
  final MockExam mockExam;
  final Duration duration;
  final VoidCallback onSaved;

  const MockExamResultDialog({
    super.key,
    required this.mockExam,
    required this.duration,
    required this.onSaved,
  });

  @override
  State<MockExamResultDialog> createState() => _MockExamResultDialogState();
}

class _MockExamResultDialogState extends State<MockExamResultDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, Map<String, TextEditingController>> _controllers;
  final Map<String, Map<String, int>> _results = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {};
    List<String> subjects = _getSubjectsForExam();

    for (final subject in subjects) {
      _controllers[subject] = {
        'correct': TextEditingController(),
        'wrong': TextEditingController(),
        'empty': TextEditingController(),
      };

      _results[subject] = {
        'correct': 0,
        'wrong': 0,
        'empty': 0,
      };
    }
  }

  List<String> _getSubjectsForExam() {
    // Branş denemesi kontrolü
    if (widget.mockExam.isBranchExam && widget.mockExam.branch != null) {
      // AYT Sayısal branş denemesi özel kontrolü
      if (widget.mockExam.branch == 'AYT Sayısal') {
        return ['AYT Matematik', 'AYT Fizik', 'AYT Kimya', 'AYT Biyoloji'];
      }
      return [widget.mockExam.branch!];
    }

    // Normal TYT denemesi
    if (widget.mockExam.examType == ExamType.TYT) {
      return [
        'Matematik',
        'Türkçe',
        'Fen Bilimleri',
        'Sosyal Bilimler',
      ];
    }

    // Normal AYT denemesi
    if (widget.mockExam.examType == ExamType.AYT) {
      switch (widget.mockExam.aytField) {
        case AYTField.MF:
          return ['AYT Matematik', 'AYT Fizik', 'AYT Kimya', 'AYT Biyoloji'];
        case AYTField.EA:
          return [
            'AYT Matematik',
            'AYT Edebiyat',
            'AYT Tarih-1',
            'AYT Coğrafya-1'
          ];
        case AYTField.SOZ:
          return [
            'AYT Edebiyat',
            'AYT Tarih-1',
            'AYT Coğrafya-1',
            'AYT Tarih-2',
            'AYT Coğrafya-2',
            'AYT Felsefe Grubu'
          ];
        default:
          return ['AYT Matematik', 'AYT Fizik', 'AYT Kimya', 'AYT Biyoloji'];
      }
    }

    return [];
  }

  @override
  void dispose() {
    for (final controllers in _controllers.values) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _updateValues(String subject, String type, String value) {
    setState(() {
      _results[subject]![type] = int.tryParse(value) ?? 0;

      // Boş soru sayısını otomatik hesapla
      final expectedTotal = _getExpectedTotalForSubject(subject);
      final correct = _results[subject]!['correct'] ?? 0;
      final wrong = _results[subject]!['wrong'] ?? 0;
      _results[subject]!['empty'] = expectedTotal - (correct + wrong);
    });
  }

  double get _totalNetScore {
    double total = 0;
    for (final result in _results.values) {
      total += result['correct']! - (result['wrong']! * 0.25);
    }
    return total;
  }

  int get _totalQuestions {
    int total = 0;
    for (final result in _results.values) {
      total += result['correct']! + result['wrong']! + result['empty']!;
    }
    return total;
  }

  int get _expectedTotal {
    // AYT Sayısal branş denemesi özel kontrolü
    if (widget.mockExam.isBranchExam &&
        widget.mockExam.branch == 'AYT Sayısal') {
      return 80; // 40 + 14 + 13 + 13 = 80 soru
    }

    // AYT EA branş denemesi özel kontrolü
    if (widget.mockExam.isBranchExam && widget.mockExam.branch == 'AYT EA') {
      return 80; // 40 + 24 + 10 + 6 = 80 soru
    }

    // AYT Sözel branş denemesi özel kontrolü
    if (widget.mockExam.isBranchExam && widget.mockExam.branch == 'AYT Sözel') {
      return 80; // 24 + 10 + 6 + 11 + 11 + 12 = 74 soru
    }

    // Diğer branş denemeleri
    if (widget.mockExam.isBranchExam && widget.mockExam.branch != null) {
      switch (widget.mockExam.branch!) {
        // TYT branş denemeleri
        case 'TYT Matematik':
        case 'TYT Türkçe':
          return 40;
        case 'TYT Fen Bilimleri':
        case 'TYT Sosyal Bilimler':
          return 20;

        // AYT branş denemeleri
        case 'AYT Matematik':
        case 'AYT Fen Bilimleri':
        case 'AYT Türk Dili ve Edebiyatı - Sosyal Bilimler 1':
        case 'AYT Sosyal Bilimler 2':
          return 40;
      }
    }

    if (widget.mockExam.examType == ExamType.TYT) {
      return 120;
    }

    if (widget.mockExam.examType == ExamType.AYT) {
      switch (widget.mockExam.aytField) {
        case AYTField.MF:
          return 80;
        case AYTField.EA:
          return 80;
        case AYTField.SOZ:
          return 74;
        default:
          return 80;
      }
    }

    return 80;
  }

  int _getExpectedTotalForSubject(String subject) {
    // Diğer branş denemeleri kontrolü - en başa taşındı
    if (widget.mockExam.isBranchExam && widget.mockExam.branch != null) {
      switch (widget.mockExam.branch!) {
        // TYT branş denemeleri
        case 'TYT Matematik':
        case 'TYT Türkçe':
          return 40;
        case 'TYT Fen Bilimleri':
        case 'TYT Sosyal Bilimler':
          return 20;

        // AYT branş denemeleri
        case 'AYT Matematik':
        case 'AYT Fen Bilimleri':
        case 'AYT Türk Dili ve Edebiyatı - Sosyal Bilimler 1':
        case 'AYT Sosyal Bilimler 2':
          return 40;
      }
    }

    // AYT Sayısal branş denemesi özel kontrolü
    if (widget.mockExam.isBranchExam &&
        widget.mockExam.branch == 'AYT Sayısal') {
      switch (subject) {
        case 'AYT Matematik':
          return 40;
        case 'AYT Fizik':
          return 14;
        case 'AYT Kimya':
          return 13;
        case 'AYT Biyoloji':
          return 13;
        default:
          return 40;
      }
    }

    // AYT EA branş denemesi özel kontrolü
    if (widget.mockExam.isBranchExam && widget.mockExam.branch == 'AYT EA') {
      switch (subject) {
        case 'AYT Matematik':
          return 40;
        case 'AYT Edebiyat':
          return 24;
        case 'AYT Tarih-1':
          return 10;
        case 'AYT Coğrafya-1':
          return 6;
        default:
          return 40;
      }
    }

    // AYT Sözel branş denemesi özel kontrolü
    if (widget.mockExam.isBranchExam && widget.mockExam.branch == 'AYT Sözel') {
      switch (subject) {
        case 'AYT Edebiyat':
          return 24;
        case 'AYT Tarih-1':
          return 10;
        case 'AYT Coğrafya-1':
          return 6;
        case 'AYT Tarih-2':
          return 11;
        case 'AYT Coğrafya-2':
          return 11;
        case 'AYT Felsefe Grubu':
          return 12;
        case 'AYT Din Kültürü':
          return 6;
        default:
          return 40;
      }
    }

    // TYT için özel soru sayıları
    if (widget.mockExam.examType == ExamType.TYT) {
      switch (subject) {
        case 'Türkçe':
          return 40;
        case 'Matematik':
          return 40;
        case 'Fen Bilimleri':
          return 20;
        case 'Sosyal Bilimler':
          return 20;
        default:
          return 40;
      }
    }

    // Normal denemeler için soru sayıları
    final examPrefix = widget.mockExam.examType == ExamType.TYT ? 'TYT' : 'AYT';
    final subjectName =
        subject.startsWith('AYT ') ? subject.substring(4) : subject;

    return ExamSubjects.mockExamQuestionCounts[examPrefix]?[subjectName] ?? 40;
  }

  Future<void> _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      debugPrint('Timer\'dan gelen deneme bilgileri:');
      debugPrint('MockExam examId: ${widget.mockExam.examId}');
      debugPrint('MockExam branch: ${widget.mockExam.branch}');
      debugPrint('MockExam publisher: ${widget.mockExam.publisher}');
      debugPrint('MockExam isBranchExam: ${widget.mockExam.isBranchExam}');
      debugPrint('MockExam examType: ${widget.mockExam.examType}');

      // examId kontrolü
      String examId = widget.mockExam.examId ?? '';
      if (examId.isEmpty) {
        debugPrint('Deneme ID bulunamadı, yeni ID oluşturuluyor...');
        examId = ObjectId().toHexString();
        debugPrint('Yeni Deneme ID oluşturuldu: $examId');
      }

      final results = _prepareResults();
      final mockExamResult = MockExamResult(
        userId: AuthService.instance.currentUser!.id.toHexString(),
        examType: widget.mockExam.examType.name,
        publisher: widget.mockExam.publisher,
        date: widget.mockExam.date,
        results: results.map(
          (subject, result) => MapEntry(
            subject,
            SubjectResult(
              correctAnswers: result['correct'] ?? 0,
              wrongAnswers: result['wrong'] ?? 0,
              emptyAnswers: result['empty'] ?? 0,
            ),
          ),
        ),
        duration: widget.duration,
        isBranchExam: widget.mockExam.isBranchExam,
        branch: widget.mockExam.branch,
        examId: examId,
      );

      // Önce sonucu kaydet
      await MockExamService.saveResult(mockExamResult, context);
      debugPrint('Deneme sonucu başarıyla kaydedildi');

      final weeklyPlanProvider = Provider.of<WeeklyPlanProvider>(
        context,
        listen: false,
      );

      final today = DateTime.now();
      final dayName = _getDayName(today.weekday);

      debugPrint('Günlük planlar aranıyor...');
      debugPrint('Gün: $dayName');
      debugPrint('ExamId: $examId');

      final dailyPlans =
          weeklyPlanProvider.selectedWeekPlan?.dailyPlans[dayName] ?? [];

      debugPrint('Bulunan plan sayısı: ${dailyPlans.length}');
      for (var plan in dailyPlans) {
        debugPrint(
            'Plan - examId: ${plan.examId}, subject: ${plan.subject}, topic: ${plan.topic}');
      }

      // examId ile eşleşen planı bul
      final mockExamPlan = dailyPlans.firstWhere(
        (plan) => plan.examId == examId,
        orElse: () {
          debugPrint('ExamId ile eşleşen plan bulunamadı: $examId');
          return dailyPlans.firstWhere(
            (plan) =>
                plan.subject == widget.mockExam.branch &&
                plan.topic == widget.mockExam.publisher,
            orElse: () {
              throw Exception('Deneme planı bulunamadı');
            },
          );
        },
      );

      debugPrint('Plan bulundu - examId: ${mockExamPlan.examId}');

      // Planı güncelle
      final updatedPlan = mockExamPlan.copyWith(
        isCompleted: true,
        examId: examId,
      );

      debugPrint('Plan güncelleniyor...');
      debugPrint('Eski plan: ${mockExamPlan.toJson()}');
      debugPrint('Yeni plan: ${updatedPlan.toJson()}');

      // Planı güncelle
      await weeklyPlanProvider.updatePlanItem(
        dayName,
        mockExamPlan,
        updatedPlan,
      );
      debugPrint('Plan başarıyla güncellendi');

      // Provider'ı güncelle
      await weeklyPlanProvider.loadPlanForWeek(DateTime.now());
      weeklyPlanProvider.notifyListeners();

      if (mounted) {
        // Callback'i çağır
        widget.onSaved();
        // Dialog'u kapat
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Deneme sonuçları kaydedilirken hata oluştu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, Map<String, int>> _prepareResults() {
    final results = <String, Map<String, int>>{};

    for (final subject in _controllers.keys) {
      final correctStr = _controllers[subject]!['correct']!.text.trim();
      final wrongStr = _controllers[subject]!['wrong']!.text.trim();

      if (correctStr.isEmpty || wrongStr.isEmpty) {
        throw const FormatException('Lütfen tüm alanları doldurun');
      }

      final correct = int.tryParse(correctStr);
      final wrong = int.tryParse(wrongStr);

      if (correct == null || wrong == null) {
        throw const FormatException('Geçersiz sayı formatı');
      }

      results[subject] = {
        'correct': correct,
        'wrong': wrong,
        'empty': _results[subject]!['empty'] ?? 0,
      };
    }

    return results;
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF252837),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExamHeader(
              mockExam: widget.mockExam,
              duration: widget.duration,
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ..._controllers.entries.map(
                        (entry) => SubjectCard(
                          subject: entry.key,
                          controllers: entry.value,
                          results: _results[entry.key]!,
                          expectedTotal: _getExpectedTotalForSubject(entry.key),
                          onValuesChanged: _updateValues,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TotalStats(
                        results: _results,
                        totalNetScore: _totalNetScore,
                        expectedTotal: _expectedTotal,
                      ),
                      const SizedBox(height: 24),
                      ActionButtons(
                        onSave: () => _handleSave(context),
                        onCancel: () => Navigator.pop(context),
                        isEnabled: _totalQuestions == _expectedTotal,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
