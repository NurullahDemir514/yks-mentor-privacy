import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yks_mentor/constants/theme.dart';
import 'package:yks_mentor/features/weekly_plan/presentation/widgets/calendar/calendar_legend.dart';
import '../../../../../models/weekly_plan.dart';
import '../../../../../models/timer_session.dart';
import '../../../../../providers/timer_provider.dart';
import '../../../../../services/auth_service.dart';
import 'calendar_header.dart';
import 'calendar_day_card.dart';
import 'calendar_detail_modal.dart';
import 'calendar_summary.dart';
import 'calendar_stats.dart';
import 'calendar_stats_cards.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  final List<WeeklyPlan> plans;

  const CalendarView({
    super.key,
    required this.plans,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _selectedMonth;
  CalendarViewType _viewType = CalendarViewType.monthly;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  void _showDayDetails(
      DateTime date, WeeklyPlan plan, List<TimerSession> sessions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarDetailModal(
        date: date,
        plan: plan,
        sessions: sessions,
      ),
    );
  }

  void _showPeriodSummary(List<TimerSession> sessions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarSummary(
        selectedMonth: _selectedMonth,
        viewType: _viewType,
        plans: widget.plans,
        sessions: sessions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final sessions = timerProvider.sessions;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalendarHeader(
              selectedMonth: _selectedMonth,
              viewType: _viewType,
              onMonthChanged: (date) {
                setState(() {
                  _selectedMonth = date;
                });
              },
              onViewTypeChanged: (type) {
                setState(() {
                  _viewType = type;
                });
              },
              onSummaryTap: () => _showPeriodSummary(sessions),
            ),
            CalendarStatsCards(
              selectedMonth: _selectedMonth,
              viewType: _viewType,
              plans: widget.plans,
              sessions: sessions,
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_viewType == CalendarViewType.monthly)
                      _buildMonthlyCalendar(sessions)
                    else
                      _buildWeeklyCalendar(sessions),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: CalendarLegend(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar(List<TimerSession> sessions) {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    // Toplam hafta sayısını hesapla
    final totalWeeks = ((daysInMonth + firstWeekday - 1) / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              'Pzt',
              'Sal',
              'Çar',
              'Per',
              'Cum',
              'Cmt',
              'Paz',
            ]
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height > 600
              ? totalWeeks * 90.0 // Tablet için daha yüksek
              : totalWeeks * 68.0, // Telefon için normal yükseklik
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio:
                  MediaQuery.of(context).size.height > 600 ? 0.9 : 0.85,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: totalWeeks * 7,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1 ||
                  index >= daysInMonth + firstWeekday - 1) {
                return Container();
              }
              final day = index - firstWeekday + 2;
              final date =
                  DateTime(_selectedMonth.year, _selectedMonth.month, day);
              final isToday = DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year;

              final plan = widget.plans.firstWhere(
                (plan) =>
                    plan.startDate
                        .isBefore(date.add(const Duration(days: 1))) &&
                    plan.startDate.add(const Duration(days: 7)).isAfter(date),
                orElse: () => WeeklyPlan(
                  startDate: date,
                  dailyPlans: {},
                  userId: AuthService.instance.currentUser!.id.toHexString(),
                ),
              );

              return CalendarDayCard(
                date: date,
                sessions: sessions,
                plan: plan,
                isToday: isToday,
                onTap: () => _showDayDetails(date, plan, sessions),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(List<TimerSession> sessions) {
    final weekStart =
        _selectedMonth.subtract(Duration(days: _selectedMonth.weekday - 1));
    final isTablet = MediaQuery.of(context).size.height > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 8 : 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isToday = DateTime.now().day == date.day &&
              DateTime.now().month == date.month &&
              DateTime.now().year == date.year;

          final plan = widget.plans.firstWhere(
            (plan) =>
                plan.startDate.isBefore(date.add(const Duration(days: 1))) &&
                plan.startDate.add(const Duration(days: 7)).isAfter(date),
            orElse: () => WeeklyPlan(
              startDate: date,
              dailyPlans: {},
              userId: AuthService.instance.currentUser!.id.toHexString(),
            ),
          );

          final dayName = DateFormat('EEEE', 'tr_TR').format(date);
          final dayPlans = plan.dailyPlans[dayName] ?? [];

          return Container(
            margin: EdgeInsets.only(bottom: isTablet ? 6 : 4),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 65 : 55,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getHeatMapColor(date, sessions),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isToday
                            ? Colors.white
                            : Colors.white.withOpacity(0.1),
                        width: isToday ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'tr_TR').format(date).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 10 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isToday
                              ? Colors.white
                              : Colors.white.withOpacity(0.1),
                          width: isToday ? 1.5 : 1,
                        ),
                      ),
                      child: dayPlans.isEmpty
                          ? Center(
                              child: Text(
                                'Plan yok',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dayPlans.length,
                              itemBuilder: (context, index) {
                                final dailyPlan = dayPlans[index];
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: index < dayPlans.length - 1
                                          ? (isTablet ? 6 : 4)
                                          : 0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: isTablet ? 20 : 16,
                                        decoration: BoxDecoration(
                                          color: dailyPlan.isMockExam
                                              ? AppTheme.primary
                                              : Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          dailyPlan.subject,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getHeatMapColor(DateTime date, List<TimerSession> sessions) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // Günlük çalışma seanslarını filtrele
    final daySessions = sessions.where((session) {
      final sessionStart = session.startTime;
      return (sessionStart.isAfter(dayStart) ||
              sessionStart.isAtSameMomentAs(dayStart)) &&
          sessionStart.isBefore(dayEnd);
    });

    // Çalışma süresi ve soru sayısını hesapla
    final studyTime = daySessions.fold(
        Duration.zero, (total, session) => total + session.netDuration);
    final completedQuestions = daySessions.fold<int>(
        0, (sum, session) => sum + (session.solvedQuestionCount ?? 0));

    // Son 30 günlük maksimum değerleri hesapla
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

    // Bugünün skorlarını normalize et
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
    return Colors.white.withOpacity(0.03); // Varsayılan arka plan
  }
}
