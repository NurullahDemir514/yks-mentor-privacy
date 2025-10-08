import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/weekly_plan.dart';
import '../../../../../constants/theme.dart';
import '../../../../../models/timer_session.dart';
import 'calendar_stats.dart';

class CalendarDetailModal extends StatelessWidget {
  final DateTime date;
  final WeeklyPlan plan;
  final List<TimerSession> sessions;

  const CalendarDetailModal({
    super.key,
    required this.date,
    required this.plan,
    required this.sessions,
  });

  Duration _calculateDayStudyTime(DateTime date, List<TimerSession> sessions,
      {bool onlyMockExams = false}) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // O güne ait planları kontrol et
    final dayName = DateFormat('EEEE', 'tr_TR').format(date);
    final dayPlans =
        plan.dailyPlans[dayName]?.where((plan) => !plan.isDeleted).toList() ??
            [];

    // Aktif planların konu ve ders bilgilerini topla
    final activePlans = dayPlans
        .where((plan) => plan.isMockExam == onlyMockExams)
        .map((plan) => '${plan.subject}_${plan.topic}')
        .toSet();

    // Günlük çalışma seanslarını filtrele
    final daySessions = sessions.where((session) {
      final sessionStart = session.startTime;
      final sessionKey = '${session.subject}_${session.topic}';

      // Seansın gün içinde olup olmadığını kontrol et
      final isInDay = (sessionStart.isAfter(dayStart) ||
              sessionStart.isAtSameMomentAs(dayStart)) &&
          sessionStart.isBefore(dayEnd);

      // Deneme veya ders kontrolü ve aktif plan kontrolü
      final isCorrectType = session.isMockExam == onlyMockExams;
      final isActivePlan = activePlans.contains(sessionKey);

      return isInDay && isCorrectType && isActivePlan;
    });

    // Toplam süreyi hesapla
    return daySessions.fold(
        Duration.zero, (total, session) => total + session.netDuration);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}s ${minutes}d';
      }
      return '${hours}s';
    }
    return '${minutes}d';
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE', 'tr_TR').format(date);
    final dayPlans = plan.dailyPlans[dayName] ?? [];
    final studyTime = _calculateDayStudyTime(date, sessions); // Ders süreleri
    final mockExamTime = _calculateDayStudyTime(date, sessions,
        onlyMockExams: true); // Deneme süreleri

    // İstatistikleri hesapla
    int totalQuestions = 0;
    int completedQuestions = 0;
    int mockExamCount = 0;
    int lessonCount = 0;
    Map<String, List<DailyPlanItem>> subjectGroups = {};

    // O güne ait tracking'leri al
    final dayTrackings = sessions.where((session) =>
        session.startTime.year == date.year &&
        session.startTime.month == date.month &&
        session.startTime.day == date.day);

    for (var plan in dayPlans) {
      if (!plan.isMockExam) {
        totalQuestions += plan.targetQuestions;
        // Bu plana ait tracking'leri bul
        final planTrackings = dayTrackings
            .where((t) => t.subject == plan.subject && t.topic == plan.topic);
        // Toplam çözülen soruları hesapla
        completedQuestions += planTrackings.fold<int>(
            0, (sum, t) => sum + (t.solvedQuestionCount ?? 0));
      }
      if (plan.isMockExam) {
        mockExamCount++;
      } else {
        lessonCount++;
      }

      // Konu bazlı gruplandırma
      if (!subjectGroups.containsKey(plan.subject)) {
        subjectGroups[plan.subject] = [];
      }
      subjectGroups[plan.subject]!.add(plan);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F1D2B).withOpacity(0.95),
            const Color(0xFF1F1D2B).withOpacity(0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('d MMMM EEEE', 'tr_TR').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (dayPlans.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dayPlans.where((p) => p.isCompleted).length}/${dayPlans.length}',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (dayPlans.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CalendarStats(
                          title: 'Toplam Soru',
                          value: '$completedQuestions/$totalQuestions',
                          icon: Icons.question_answer,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CalendarStats(
                          title: 'Ders Süresi',
                          value: _formatDuration(studyTime),
                          icon: Icons.timer,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CalendarStats(
                          title: 'Deneme',
                          value:
                              '${mockExamCount} (${_formatDuration(mockExamTime)})',
                          icon: Icons.assignment,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CalendarStats(
                          title: 'Ders',
                          value: lessonCount.toString(),
                          icon: Icons.book,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          if (dayPlans.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Bu güne ait plan bulunmuyor',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjectGroups.length,
                itemBuilder: (context, index) {
                  final subject = subjectGroups.keys.elementAt(index);
                  final plans = subjectGroups[subject]!;
                  final completedCount =
                      plans.where((p) => p.isCompleted).length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                subject,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$completedCount/${plans.length}',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...plans.map((plan) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: plan.isCompleted
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: plan.isMockExam
                                          ? AppTheme.primary.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      plan.isMockExam
                                          ? Icons.assignment
                                          : Icons.book,
                                      color: plan.isMockExam
                                          ? AppTheme.primary
                                          : Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.topic,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (plan.targetQuestions > 0) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${plan.targetQuestions} Soru',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: plan.isCompleted
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      plan.isCompleted
                                          ? 'Tamamlandı'
                                          : 'Devam Ediyor',
                                      style: TextStyle(
                                        color: plan.isCompleted
                                            ? Colors.green
                                            : Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
