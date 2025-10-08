import 'package:flutter/material.dart';
import 'package:yks_mentor/models/mock_exam.dart';
import '../../constants/theme.dart';
import '../../models/weekly_plan.dart';
import '../../models/mock_exam_result.dart';
import '../../constants/weekly_plan_constants.dart';
import 'package:provider/provider.dart';
import '../../services/mock_exam_service.dart';
import '../../services/auth_service.dart';
import 'mock_exam_item.dart';
import 'lesson_plan_item.dart';
import 'day_header.dart';

class DayCard extends StatefulWidget {
  final String day;
  final List<DailyPlanItem> plans;
  final Function(DateTime) onDayTap;
  final Function(DailyPlanItem, String) onPlanItemTap;
  final Function(DailyPlanItem, String) onPlanItemDelete;

  const DayCard({
    super.key,
    required this.day,
    required this.plans,
    required this.onDayTap,
    required this.onPlanItemTap,
    required this.onPlanItemDelete,
  });

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  final Map<String, MockExamResult?> _results = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void didUpdateWidget(DayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plans != widget.plans) {
      _loadResults();
    }
  }

  Future<void> _loadResults() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;

      final mockExams = widget.plans.where((plan) => plan.isMockExam).toList();
      if (mockExams.isEmpty) return;

      final results = await MockExamService.getResults(userId.toHexString());

      for (final exam in mockExams) {
        final mockExam = MockExam.fromPlanItem(exam);
        final result =
            results.where((r) => r.examId == exam.examId).firstOrNull;

        if (mounted) {
          setState(() {
            _results[exam.examId!] = result;
          });
        }
      }
    } catch (e) {
      debugPrint('Sonuçlar yüklenirken hata: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mockExams = widget.plans.where((plan) => plan.isMockExam).toList()
      ..sort((a, b) {
        if (a.isCompleted == b.isCompleted) return 0;
        return a.isCompleted ? 1 : -1;
      });

    final lessons = widget.plans.where((plan) => !plan.isMockExam).toList()
      ..sort((a, b) {
        if (a.isCompleted == b.isCompleted) return 0;
        return a.isCompleted ? 1 : -1;
      });

    // Gün adını tarihe dönüştür
    DateTime dayDate = _getDayDate(widget.day);

    return Container(
      margin: widget.plans.isEmpty
          ? const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
          : const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onDayTap(dayDate),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.plans.isNotEmpty) ...[
                DayHeader(
                  day: widget.day,
                  plans: widget.plans,
                ),
                if (mockExams.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mockExams
                          .map((plan) => MockExamItem(
                                plan: plan,
                                result: _results[plan.examId!],
                                onPlanItemDelete: widget.onPlanItemDelete,
                                day: widget.day,
                              ))
                          .toList(),
                    ),
                  ),
                ],
                if (lessons.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: lessons
                          .map((plan) => LessonPlanItem(
                                plan: plan,
                                day: widget.day,
                                onPlanItemTap: widget.onPlanItemTap,
                                onPlanItemDelete: widget.onPlanItemDelete,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ] else ...[
                _EmptyDayCard(day: widget.day),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Gün adını tarihe dönüştüren yardımcı fonksiyon
  DateTime _getDayDate(String dayName) {
    // Şu anki haftanın başlangıcını bul (Pazartesi)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    // Gün adına göre haftanın gününü bul
    int dayOffset = 0;
    switch (dayName) {
      case 'Pazartesi':
        dayOffset = 0;
        break;
      case 'Salı':
        dayOffset = 1;
        break;
      case 'Çarşamba':
        dayOffset = 2;
        break;
      case 'Perşembe':
        dayOffset = 3;
        break;
      case 'Cuma':
        dayOffset = 4;
        break;
      case 'Cumartesi':
        dayOffset = 5;
        break;
      case 'Pazar':
        dayOffset = 6;
        break;
    }

    // Haftanın başlangıcına gün ekleyerek tarihi bul
    return weekStart.add(Duration(days: dayOffset));
  }
}

class _EmptyDayCard extends StatelessWidget {
  final String day;

  const _EmptyDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppTheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            day,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.add,
            color: Colors.white.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}
