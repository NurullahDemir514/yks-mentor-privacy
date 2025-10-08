import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/weekly_plan.dart';
import '../../../../../constants/theme.dart';
import '../../../../../models/timer_session.dart';
import 'calendar_stats.dart';
import 'calendar_header.dart';
import 'calendar_legend.dart';

class CalendarSummary extends StatelessWidget {
  final DateTime selectedMonth;
  final CalendarViewType viewType;
  final List<WeeklyPlan> plans;
  final List<TimerSession> sessions;

  const CalendarSummary({
    super.key,
    required this.selectedMonth,
    required this.viewType,
    required this.plans,
    required this.sessions,
  });

  Duration _calculateStudyTime(List<TimerSession> sessions, {String? subject}) {
    int totalCompletedQuestions = 0;
    int totalPlannedQuestions = 0;
    Map<String, int> subjectQuestions = {};
    Map<String, int> subjectCompletedQuestions = {};
    Map<String, Duration> subjectDurations = {};

    DateTime periodStart;
    DateTime periodEnd;

    if (viewType == CalendarViewType.weekly) {
      final weekday = selectedMonth.weekday;
      periodStart = selectedMonth.subtract(Duration(days: weekday - 1));
      periodEnd = periodStart.add(const Duration(days: 6));
    } else {
      periodStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
      periodEnd = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    }

    // Periyot planlarını al
    final periodPlans = plans.where((plan) =>
        plan.startDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
        plan.startDate.isBefore(periodEnd.add(const Duration(days: 1))));

    // Periyot içindeki tracking'leri al
    final periodTrackings = sessions.where((session) {
      // Önce tarih kontrolü
      final isInPeriod = session.startTime
              .isAfter(periodStart.subtract(const Duration(days: 1))) &&
          session.startTime.isBefore(periodEnd.add(const Duration(days: 1)));

      if (!isInPeriod) return false;

      // Seansın gününü bul
      final sessionDay = DateFormat('EEEE', 'tr_TR').format(session.startTime);

      // O güne ait aktif planları kontrol et
      bool hasActivePlan = false;
      for (var plan in periodPlans) {
        final planItems = plan.dailyPlans[sessionDay] ?? [];
        hasActivePlan = planItems.any((item) =>
            !item.isDeleted &&
            !item.isMockExam &&
            item.subject == session.subject &&
            item.topic == session.topic);
        if (hasActivePlan) break;
      }

      return hasActivePlan && !session.isMockExam;
    }).toList();

    // İstatistikleri hesapla
    for (var plan in periodPlans) {
      plan.dailyPlans.forEach((day, plans) {
        // Silinen planları filtrele
        final activePlans = plans.where((plan) => !plan.isDeleted);
        for (var item in activePlans) {
          if (!item.isMockExam) {
            totalPlannedQuestions += item.targetQuestions;

            // Bu plana ait tracking'leri bul
            final planDate = plan.startDate.add(Duration(
                days: [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar'
            ].indexOf(day)));

            final planTrackings = periodTrackings.where((t) =>
                t.subject == item.subject &&
                t.topic == item.topic &&
                DateFormat('EEEE', 'tr_TR').format(t.startTime) == day &&
                t.startTime.year == planDate.year &&
                t.startTime.month == planDate.month &&
                t.startTime.day == planDate.day);

            // Toplam çözülen soruları hesapla
            totalCompletedQuestions += planTrackings.fold<int>(
                0, (sum, t) => sum + (t.solvedQuestionCount ?? 0));

            // Konu bazlı soru istatistikleri
            final key = '${item.subject} - ${item.topic}';
            subjectQuestions[key] =
                (subjectQuestions[key] ?? 0) + item.targetQuestions;
            // Konu bazlı çözülen soru istatistikleri
            subjectCompletedQuestions[key] =
                (subjectCompletedQuestions[key] ?? 0) +
                    planTrackings.fold<int>(
                        0, (sum, t) => sum + (t.solvedQuestionCount ?? 0));
          }
        }
      });
    }

    // Toplam çalışma süresini hesapla
    Duration totalDuration = Duration.zero;
    for (var session in periodTrackings) {
      totalDuration += session.netDuration;
    }
    return totalDuration;
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
    Duration totalStudyTime = Duration.zero;
    Map<String, int> subjectQuestions = {};
    Map<String, int> subjectCompletedQuestions = {};
    Map<String, Duration> subjectDurations = {};
    int totalPlannedQuestions = 0;
    int totalCompletedQuestions = 0;

    DateTime periodStart;
    DateTime periodEnd;

    if (viewType == CalendarViewType.weekly) {
      final weekday = selectedMonth.weekday;
      periodStart = selectedMonth.subtract(Duration(days: weekday - 1));
      periodEnd = periodStart.add(const Duration(days: 6));
    } else {
      periodStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
      periodEnd = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    }

    // Periyot planlarını al
    final periodPlans = plans.where((plan) =>
        plan.startDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
        plan.startDate.isBefore(periodEnd.add(const Duration(days: 1))));

    // Periyot içindeki tracking'leri al
    final periodTrackings = sessions.where((session) {
      // Önce tarih kontrolü
      final isInPeriod = session.startTime
              .isAfter(periodStart.subtract(const Duration(days: 1))) &&
          session.startTime.isBefore(periodEnd.add(const Duration(days: 1)));

      if (!isInPeriod) return false;

      // Seansın gününü bul
      final sessionDay = DateFormat('EEEE', 'tr_TR').format(session.startTime);

      // O güne ait aktif planları kontrol et
      bool hasActivePlan = false;
      for (var plan in periodPlans) {
        final planItems = plan.dailyPlans[sessionDay] ?? [];
        hasActivePlan = planItems.any((item) =>
            !item.isDeleted &&
            !item.isMockExam &&
            item.subject == session.subject &&
            item.topic == session.topic);
        if (hasActivePlan) break;
      }

      return hasActivePlan && !session.isMockExam;
    }).toList();

    // İstatistikleri hesapla
    for (var plan in periodPlans) {
      plan.dailyPlans.forEach((day, plans) {
        // Silinen planları filtrele
        final activePlans = plans.where((plan) => !plan.isDeleted);
        for (var item in activePlans) {
          if (!item.isMockExam) {
            totalPlannedQuestions += item.targetQuestions;

            // Bu plana ait tracking'leri bul
            final planDate = plan.startDate.add(Duration(
                days: [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar'
            ].indexOf(day)));

            final planTrackings = periodTrackings.where((t) =>
                t.subject == item.subject &&
                t.topic == item.topic &&
                DateFormat('EEEE', 'tr_TR').format(t.startTime) == day &&
                t.startTime.year == planDate.year &&
                t.startTime.month == planDate.month &&
                t.startTime.day == planDate.day);

            // Toplam çözülen soruları hesapla
            totalCompletedQuestions += planTrackings.fold<int>(
                0, (sum, t) => sum + (t.solvedQuestionCount ?? 0));

            // Konu bazlı soru istatistikleri
            final key = '${item.subject} - ${item.topic}';
            subjectQuestions[key] =
                (subjectQuestions[key] ?? 0) + item.targetQuestions;
            // Konu bazlı çözülen soru istatistikleri
            subjectCompletedQuestions[key] =
                (subjectCompletedQuestions[key] ?? 0) +
                    planTrackings.fold<int>(
                        0, (sum, t) => sum + (t.solvedQuestionCount ?? 0));
          }
        }
      });
    }

    // Toplam çalışma süresini hesapla
    totalStudyTime = _calculateStudyTime(sessions);

    // Konu bazlı çalışma sürelerini hesapla
    for (var subject in subjectQuestions.keys) {
      // Her konu için ayrı süre hesapla
      Duration subjectDuration = Duration.zero;
      final subjectInfo = subject.split(' - ');
      final subjectName = subjectInfo[0];
      final topicName = subjectInfo.length > 1 ? subjectInfo[1] : '';

      final subjectSessions = sessions.where((session) {
        final sessionStart = session.startTime;
        final isInPeriod = (sessionStart.isAfter(periodStart) ||
                sessionStart.isAtSameMomentAs(periodStart)) &&
            sessionStart.isBefore(periodEnd.add(const Duration(days: 1)));
        return isInPeriod &&
            !session.isMockExam &&
            session.subject == subjectName &&
            session.topic == topicName;
      });

      for (var session in subjectSessions) {
        subjectDuration += session.netDuration;
      }
      subjectDurations[subject] = subjectDuration;
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
                Text(
                  viewType == CalendarViewType.weekly
                      ? 'Haftalık Özet'
                      : 'Aylık Özet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CalendarStats(
                        title: 'Toplam Çalışma',
                        value: _formatDuration(totalStudyTime),
                        icon: Icons.timer,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CalendarStats(
                        title: 'Tamamlanan Soru',
                        value:
                            '$totalCompletedQuestions/$totalPlannedQuestions',
                        icon: Icons.question_answer,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjectQuestions.length,
              itemBuilder: (context, index) {
                final subject = subjectQuestions.keys.elementAt(index);
                final questionCount = subjectQuestions[subject]!;
                final duration = subjectDurations[subject]!;
                final completedCount = subjectCompletedQuestions[subject] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.book,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.split(' - ')[0],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              subject.split(' - ')[1],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                            if (subjectCompletedQuestions[subject] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$completedCount/$questionCount',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: AppTheme.secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
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
