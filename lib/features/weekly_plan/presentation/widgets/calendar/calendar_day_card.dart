import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/weekly_plan.dart';
import '../../../../../constants/theme.dart';
import '../../../../../models/timer_session.dart';
import 'calendar_header.dart';

class CalendarDayCard extends StatelessWidget {
  final DateTime date;
  final List<TimerSession> sessions;
  final WeeklyPlan plan;
  final bool isToday;
  final VoidCallback onTap;

  const CalendarDayCard({
    super.key,
    required this.date,
    required this.sessions,
    required this.plan,
    required this.isToday,
    required this.onTap,
  });

  Color _getProgressColor(Duration studyTime) {
    final hours = studyTime.inHours + (studyTime.inMinutes.remainder(60) / 60);
    if (hours >= 4) return Colors.purple;
    if (hours >= 3) return Colors.blue;
    if (hours >= 2) return Colors.green;
    if (hours >= 1) return Colors.orange;
    return Colors.red.withOpacity(0.7);
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

  Duration _calculateDayStudyTime(DateTime date, List<TimerSession> sessions) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // Günlük çalışma seanslarını filtrele
    final daySessions = sessions.where((session) {
      final sessionStart = session.startTime;

      // Seansın gün içinde olup olmadığını kontrol et
      return (sessionStart.isAfter(dayStart) ||
              sessionStart.isAtSameMomentAs(dayStart)) &&
          sessionStart.isBefore(dayEnd);
    });

    // Toplam süreyi hesapla
    return daySessions.fold(
        Duration.zero, (total, session) => total + session.netDuration);
  }

  int _calculateDayQuestions(DateTime date, List<TimerSession> sessions) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // Günlük çalışma seanslarını filtrele
    final daySessions = sessions.where((session) {
      final sessionStart = session.startTime;

      // Seansın gün içinde olup olmadığını kontrol et
      return (sessionStart.isAfter(dayStart) ||
              sessionStart.isAtSameMomentAs(dayStart)) &&
          sessionStart.isBefore(dayEnd);
    });

    // Toplam soru sayısını hesapla
    return daySessions.fold<int>(
        0, (sum, session) => sum + (session.solvedQuestionCount ?? 0));
  }

  Color _getHeatMapColor(Duration studyTime, int completedQuestions) {
    // Maksimum değerleri hesapla (son 30 günlük verilerden)
    final thirtyDaysAgo = date.subtract(const Duration(days: 30));
    final recentSessions = sessions
        .where((session) =>
            session.startTime.isAfter(thirtyDaysAgo) &&
            session.startTime.isBefore(date.add(const Duration(days: 1))))
        .toList();

    // Son 30 günün maksimum çalışma süresini bul
    final maxStudyHours =
        recentSessions.fold<Duration>(Duration.zero, (maxDuration, session) {
      final sessionDate = session.startTime;
      final dayStart =
          DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayDuration = recentSessions
          .where((s) =>
              s.startTime.isAfter(dayStart) && s.startTime.isBefore(dayEnd))
          .fold<Duration>(Duration.zero, (sum, s) => sum + s.netDuration);

      return dayDuration > maxDuration ? dayDuration : maxDuration;
    });

    // Son 30 günün maksimum soru sayısını bul
    final maxQuestions = recentSessions.fold<int>(0, (maxQuestions, session) {
      final sessionDate = session.startTime;
      final dayStart =
          DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayQuestions = recentSessions
          .where((s) =>
              s.startTime.isAfter(dayStart) && s.startTime.isBefore(dayEnd))
          .fold<int>(0, (sum, s) => sum + (s.solvedQuestionCount ?? 0));

      return dayQuestions > maxQuestions ? dayQuestions : maxQuestions;
    });

    // Bugünün skorlarını maksimum değerlere göre normalize et
    final timeScore = maxStudyHours.inMinutes > 0
        ? studyTime.inMinutes / maxStudyHours.inMinutes
        : 0.0;
    final questionScore =
        maxQuestions > 0 ? completedQuestions / maxQuestions : 0.0;

    // İki skorun ortalamasını al
    final score = (timeScore + questionScore) / 2;

    // Renk skalası (soğuktan sıcağa)
    if (score >= 0.8)
      return const Color(0xFFF4511E).withOpacity(0.8); // Turuncu-kırmızı
    if (score >= 0.6)
      return const Color(0xFFFF9800).withOpacity(0.8); // Turuncu
    if (score >= 0.4)
      return const Color(0xFFFFB74D).withOpacity(0.8); // Açık turuncu
    if (score >= 0.2)
      return const Color(0xFF64B5F6).withOpacity(0.8); // Açık mavi
    if (score > 0) return const Color(0xFF2196F3).withOpacity(0.8); // Mavi
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final studyTime = _calculateDayStudyTime(date, sessions);
    final hasStudyTime = studyTime.inMinutes > 0;
    final completedQuestions = _calculateDayQuestions(date, sessions);

    // Isı haritası rengini hesapla
    final heatMapColor = _getHeatMapColor(studyTime, completedQuestions);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        decoration: BoxDecoration(
          color: heatMapColor,
          border: Border.all(
            color: isToday
                ? Colors.white
                : hasStudyTime
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
            width: isToday ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isToday
                    ? Colors.white
                    : Colors.white.withOpacity(hasStudyTime ? 0.9 : 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasStudyTime) ...[
              SizedBox(
                height: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(studyTime),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            if (completedQuestions > 0) ...[
              SizedBox(
                height: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$completedQuestions soru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
