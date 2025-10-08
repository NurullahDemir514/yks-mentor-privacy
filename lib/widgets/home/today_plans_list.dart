import 'package:flutter/material.dart';
import '../../models/weekly_plan.dart';
import '../../providers/question_tracking_provider.dart';
import '../../constants/theme.dart';
import 'package:provider/provider.dart';
import '../../providers/weekly_plan_provider.dart';
import 'plan_items/lesson_plan_item.dart';
import 'plan_items/mock_exam_plan_item.dart';

class TodayPlansList extends StatelessWidget {
  final List<DailyPlanItem> plans;
  final QuestionTrackingProvider questionTrackingProvider;

  const TodayPlansList({
    super.key,
    required this.plans,
    required this.questionTrackingProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyPlanProvider>(
      builder: (context, provider, _) {
        final currentPlan = provider.selectedWeekPlan;
        final today = _getDayName(DateTime.now().weekday);
        final plans = currentPlan?.dailyPlans[today]
                ?.where((plan) => !plan.isDeleted)
                .toList() ??
            [];

        final lessonPlans = plans.where((plan) => !plan.isMockExam).toList()
          ..sort((a, b) {
            if (a.isCompleted == b.isCompleted) return 0;
            return a.isCompleted ? 1 : -1;
          });

        final mockExamPlans = plans.where((plan) => plan.isMockExam).toList()
          ..sort((a, b) {
            if (a.isCompleted == b.isCompleted) return 0;
            return a.isCompleted ? 1 : -1;
          });

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.today_outlined,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bugünün Planı',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${plans.length} Görev',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              if (mockExamPlans.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...mockExamPlans.map((plan) => MockExamPlanItem(
                      plan: plan,
                      questionTrackingProvider: questionTrackingProvider,
                    )),
              ],
              if (lessonPlans.isNotEmpty) ...[
                if (mockExamPlans.isNotEmpty) const SizedBox(height: 12),
                ...lessonPlans.map((plan) => LessonPlanItem(
                      plan: plan,
                      questionTrackingProvider: questionTrackingProvider,
                    )),
              ],
            ],
          ),
        );
      },
    );
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
