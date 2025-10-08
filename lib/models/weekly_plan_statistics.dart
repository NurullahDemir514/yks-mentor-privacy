import '../models/weekly_plan.dart';

class WeeklyPlanStatistics {
  final int completedQuestions;
  final int totalQuestions;
  final Map<String, int> subjectDistribution;

  WeeklyPlanStatistics({
    required this.completedQuestions,
    required this.totalQuestions,
    required this.subjectDistribution,
  });

  factory WeeklyPlanStatistics.fromPlan(WeeklyPlan plan) {
    int totalQuestions = 0;
    int completedQuestions = 0;
    final Map<String, int> distribution = {};

    plan.dailyPlans.forEach((day, plans) {
      for (final plan in plans) {
        if (!plan.isMockExam) {
          // Sadece dersleri dahil et
          totalQuestions += plan.targetQuestions;
          if (plan.isCompleted) {
            completedQuestions += plan.targetQuestions;
          }
          distribution[plan.subject] =
              (distribution[plan.subject] ?? 0) + plan.targetQuestions;
        }
      }
    });

    return WeeklyPlanStatistics(
      completedQuestions: completedQuestions,
      totalQuestions: totalQuestions,
      subjectDistribution: distribution,
    );
  }

  double get completionRate =>
      totalQuestions > 0 ? completedQuestions / totalQuestions : 0;
}
