import 'package:flutter/material.dart';
import '../../../../../constants/theme.dart';
import '../../../../../models/timer_session.dart';
import '../../../../../models/weekly_plan.dart';
import 'calendar_header.dart';
import 'calendar_stats.dart';
import 'package:intl/intl.dart';

class CalendarStatsCards extends StatelessWidget {
  final DateTime selectedMonth;
  final CalendarViewType viewType;
  final List<WeeklyPlan> plans;
  final List<TimerSession> sessions;

  const CalendarStatsCards({
    super.key,
    required this.selectedMonth,
    required this.viewType,
    required this.plans,
    required this.sessions,
  });

  Duration _calculateStudyTime(List<TimerSession> sessions,
      {bool onlyMockExams = false}) {
    DateTime periodStart;
    DateTime periodEnd;

    if (viewType == CalendarViewType.weekly) {
      periodStart =
          selectedMonth.subtract(Duration(days: selectedMonth.weekday - 1));
      periodEnd = periodStart.add(const Duration(days: 7));
    } else {
      periodStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
      periodEnd = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    }

    // Periyot planlarını al
    final periodPlans = plans.where((plan) =>
        plan.startDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
        plan.startDate.isBefore(periodEnd.add(const Duration(days: 1))));

    // Aktif planların günlerini ve konu bilgilerini topla
    Map<String, Set<String>> activePlansByDay = {};
    for (var plan in periodPlans) {
      plan.dailyPlans.forEach((day, items) {
        for (var item in items.where((item) => !item.isDeleted)) {
          if ((onlyMockExams && item.isMockExam) ||
              (!onlyMockExams && !item.isMockExam)) {
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
            final dateKey = DateFormat('yyyy-MM-dd').format(planDate);

            activePlansByDay.putIfAbsent(dateKey, () => {});
            activePlansByDay[dateKey]!.add('${item.subject}_${item.topic}');
          }
        }
      });
    }

    final filteredSessions = sessions.where((session) {
      final sessionStart = session.startTime;
      final sessionDay = DateFormat('yyyy-MM-dd').format(sessionStart);
      final sessionKey = '${session.subject}_${session.topic}';

      // Seansın periyot içinde olup olmadığını kontrol et
      final isInPeriod = (sessionStart.isAfter(periodStart) ||
              sessionStart.isAtSameMomentAs(periodStart)) &&
          sessionStart.isBefore(periodEnd.add(const Duration(days: 1)));

      // Deneme veya ders kontrolü
      final isCorrectType =
          onlyMockExams ? session.isMockExam : !session.isMockExam;

      // Aktif plan günü ve konu kontrolü
      final isActivePlan =
          activePlansByDay[sessionDay]?.contains(sessionKey) ?? false;

      return isInPeriod && isCorrectType && isActivePlan;
    });

    return filteredSessions.fold(
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

  Map<String, dynamic> _calculateStats() {
    int totalPlannedQuestions = 0;
    int totalCompletedQuestions = 0;
    int mockExamCount = 0;
    int lessonCount = 0;

    DateTime periodStart;
    DateTime periodEnd;

    if (viewType == CalendarViewType.weekly) {
      periodStart =
          selectedMonth.subtract(Duration(days: selectedMonth.weekday - 1));
      periodEnd = periodStart.add(const Duration(days: 7));
    } else {
      periodStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
      periodEnd = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    }

    final periodPlans = plans.where((plan) =>
        plan.startDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
        plan.startDate.isBefore(periodEnd.add(const Duration(days: 1))));

    // Periyot içindeki tracking'leri al
    final periodTrackings = sessions.where((session) =>
        session.startTime
            .isAfter(periodStart.subtract(const Duration(days: 1))) &&
        session.startTime.isBefore(periodEnd.add(const Duration(days: 1))));

    for (var plan in periodPlans) {
      plan.dailyPlans.forEach((day, plans) {
        for (var item in plans) {
          if (!item.isMockExam) {
            totalPlannedQuestions += item.targetQuestions;
            // Bu plana ait tracking'leri bul
            final planTrackings = periodTrackings.where(
                (t) => t.subject == item.subject && t.topic == item.topic);
            // Toplam çözülen soruları hesapla
            totalCompletedQuestions += planTrackings.fold<int>(
                0, (sum, t) => sum + (t.solvedQuestionCount ?? 0));
          }
          if (item.isMockExam) {
            mockExamCount++;
          } else {
            lessonCount++;
          }
        }
      });
    }

    return {
      'totalPlannedQuestions': totalPlannedQuestions,
      'totalCompletedQuestions': totalCompletedQuestions,
      'mockExamCount': mockExamCount,
      'lessonCount': lessonCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final studyTime = _calculateStudyTime(sessions);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: CalendarStats(
              title: 'Çalışma Süresi',
              value: _formatDuration(studyTime),
              icon: Icons.timer,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CalendarStats(
              title: 'Toplam Soru',
              value:
                  '${stats['totalCompletedQuestions']}/${stats['totalPlannedQuestions']}',
              icon: Icons.question_answer,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
