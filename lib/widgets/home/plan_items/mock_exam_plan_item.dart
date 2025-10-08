import 'package:flutter/material.dart';
import 'package:yks_mentor/models/mock_exam.dart';
import '../../../models/weekly_plan.dart';
import '../../../providers/question_tracking_provider.dart';
import '../../../providers/timer_provider.dart';
import '../../../providers/weekly_plan_provider.dart';
import '../../../constants/theme.dart';
import '../../../models/mock_exam_result.dart';
import '../../../services/mock_exam_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/app_scaffold.dart';
import 'package:provider/provider.dart';
import '../mock_exam_result_dialog.dart';

class MockExamPlanItem extends StatefulWidget {
  final DailyPlanItem plan;
  final QuestionTrackingProvider questionTrackingProvider;

  const MockExamPlanItem({
    super.key,
    required this.plan,
    required this.questionTrackingProvider,
  });

  @override
  State<MockExamPlanItem> createState() => _MockExamPlanItemState();
}

class _MockExamPlanItemState extends State<MockExamPlanItem> {
  MockExamResult? _result;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;

      final mockExam = MockExam.fromPlanItem(widget.plan);
      final results = await MockExamService.getResults(userId.toHexString());
      final result =
          results.where((r) => r.examId == widget.plan.examId).firstOrNull;

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Deneme sonucu yüklenirken hata: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startExam(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    // Deneme bilgilerini ayarla ama başlatma
    timerProvider.setMockExam(
      widget.plan.subject,
      widget.plan.topic,
      widget.plan.subject.contains('TYT')
          ? const Duration(minutes: 165)
          : const Duration(minutes: 180),
      widget.plan.examId!,
    );

    // Timer sayfasına yönlendir
    AppScaffold.of(context)?.changePage(4);
  }

  Future<void> _showAddResultDialog(BuildContext context) async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    // Deneme bilgilerini ayarla
    timerProvider.setSubjectAndTopic(widget.plan.subject,
        topic: widget.plan.topic);
    timerProvider.setMockExamPublisher(widget.plan.topic);
    timerProvider.setStartTime(DateTime.now());

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MockExamResultDialog(
        mockExam: MockExam.fromPlanItem(
          widget.plan,
        ),
        duration: timerProvider.duration,
        onSaved: () {
          // Sonuçları yeniden yükle
          _loadResult();
          // Weekly plan provider'ı güncelle
          Provider.of<WeeklyPlanProvider>(context, listen: false)
              .loadPlanForWeek(DateTime.now());
        },
      ),
    );

    if (result != null && mounted) {
      try {
        final results = result['results'] as Map<String, Map<String, int>>;
        final examType = result['examType'] as String;
        final totalCorrect = results.values.fold<int>(
          0,
          (sum, r) => sum + (r['correct'] ?? 0),
        );
        final totalWrong = results.values.fold<int>(
          0,
          (sum, r) => sum + (r['wrong'] ?? 0),
        );
        final totalEmpty = results.values.fold<int>(
          0,
          (sum, r) => sum + (r['empty'] ?? 0),
        );

        await timerProvider.completeMockExam(
          totalCorrect,
          totalWrong,
          totalEmpty,
          context,
        );

        // Sonuçları yeniden yükle
        await _loadResult();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deneme sonuçları kaydedildi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _result != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.plan.isCompleted
            ? hasResults
                ? Colors.green.withOpacity(0.03)
                : Colors.blue.withOpacity(0.03)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.plan.isCompleted
              ? hasResults
                  ? Colors.green.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2)
              : AppTheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.plan.isCompleted
                          ? hasResults
                              ? Colors.green.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1)
                          : AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.plan.isCompleted
                            ? hasResults
                                ? Colors.green.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2)
                            : AppTheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.plan.subject,
                      style: TextStyle(
                        color: widget.plan.isCompleted
                            ? hasResults
                                ? Colors.green
                                : Colors.blue
                            : AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.plan.topic,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(widget.plan.isCompleted ? 0.6 : 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        decoration: widget.plan.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white.withOpacity(0.6),
                        decorationThickness: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!_isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasResults
                            ? Colors.green.withOpacity(0.15)
                            : widget.plan.isCompleted
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: hasResults
                              ? Colors.green.withOpacity(0.3)
                              : widget.plan.isCompleted
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        hasResults
                            ? '${_result!.totalNet.toStringAsFixed(2)} Net'
                            : widget.plan.isCompleted
                                ? 'Sonuç Ekle'
                                : 'Başla',
                        style: TextStyle(
                          color: hasResults
                              ? Colors.green
                              : widget.plan.isCompleted
                                  ? Colors.blue
                                  : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 400),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 12),
                      if (hasResults)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getProgressColor(_result!.totalNet / 120)
                                  .withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_result!.results.values.fold<int>(0, (sum, r) => sum + r.correctAnswers)} Doğru',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_result!.results.values.fold<int>(0, (sum, r) => sum + r.wrongAnswers)} Yanlış',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_result!.totalNet.toStringAsFixed(2)} Net',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _result!.totalNet / 120,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  color: _getProgressColor(
                                      _result!.totalNet / 120),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        FilledButton.icon(
                          onPressed: () => widget.plan.isCompleted
                              ? _showAddResultDialog(context)
                              : _startExam(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.plan.isCompleted
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            foregroundColor: widget.plan.isCompleted
                                ? Colors.blue
                                : Colors.orange,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: widget.plan.isCompleted
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          icon: Icon(
                            widget.plan.isCompleted
                                ? Icons.edit_note_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 18,
                          ),
                          label: Text(
                            widget.plan.isCompleted
                                ? 'Sonuçları Gir'
                                : 'Denemeye Başla',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  sizeCurve: Curves.easeOutQuart,
                  firstCurve: Curves.easeOutQuart,
                  secondCurve: Curves.easeOutQuart,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red.withOpacity(0.7);
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
        throw Exception('Invalid weekday');
    }
  }
}
