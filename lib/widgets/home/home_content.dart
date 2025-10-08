import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/question_tracking_provider.dart';
import '../../providers/weekly_plan_provider.dart';
import '../../services/statistics_service.dart';
import 'welcome_card.dart';
import 'daily_stats_card.dart';
import 'today_plans_list.dart';
import 'empty_state.dart';

class HomeContent extends StatelessWidget {
  final StatisticsService statisticsService;

  const HomeContent({
    super.key,
    required this.statisticsService,
  });

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Pazartesi';
      case DateTime.tuesday:
        return 'Salı';
      case DateTime.wednesday:
        return 'Çarşamba';
      case DateTime.thursday:
        return 'Perşembe';
      case DateTime.friday:
        return 'Cuma';
      case DateTime.saturday:
        return 'Cumartesi';
      case DateTime.sunday:
        return 'Pazar';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyPlanProvider = Provider.of<WeeklyPlanProvider>(context);
    final questionTrackingProvider =
        Provider.of<QuestionTrackingProvider>(context);
    final currentPlan = weeklyPlanProvider.selectedWeekPlan;
    final today = _getDayName(DateTime.now().weekday);
    final todayPlans = currentPlan?.dailyPlans[today] ?? [];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FutureBuilder<DailyStats>(
                future: statisticsService.getDailyStats(DateTime.now()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      FutureBuilder<String>(
                        future: statisticsService
                            .getMotivationalMessage(snapshot.data!),
                        builder: (context, messageSnapshot) {
                          return WelcomeCard(
                            stats: snapshot.data!,
                            motivationalMessage:
                                messageSnapshot.data ?? 'Hoş geldin!',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (todayPlans.isNotEmpty) ...[
                        FutureBuilder<WeeklyStats>(
                          future: statisticsService.getWeeklyStats(),
                          builder: (context, weeklySnapshot) {
                            if (!weeklySnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            return DailyStatsCard(
                              stats: snapshot.data!,
                              weeklyStats: weeklySnapshot.data!,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
              if (todayPlans.isNotEmpty)
                TodayPlansList(
                  plans: statisticsService.sortPlansByCompletion(todayPlans),
                  questionTrackingProvider: questionTrackingProvider,
                )
              else
                const EmptyState(),
            ]),
          ),
        ),
      ],
    );
  }
}
