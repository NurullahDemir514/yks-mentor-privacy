import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../constants/weekly_plan_constants.dart';
import '../../models/weekly_plan.dart';

class PastPlanItem extends StatelessWidget {
  final WeeklyPlan plan;

  const PastPlanItem({
    super.key,
    required this.plan,
  });

  static const List<String> months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final startDate = plan.startDate;
    final endDate = startDate.add(const Duration(days: 6));

    int planTotalQuestions = 0;
    int planCompletedQuestions = 0;

    plan.dailyPlans.forEach((day, dayPlans) {
      for (var item in dayPlans) {
        planTotalQuestions += item.targetQuestions;
        if (item.isCompleted) {
          planCompletedQuestions += item.targetQuestions;
        }
      }
    });

    final progress = planTotalQuestions > 0
        ? planCompletedQuestions / planTotalQuestions
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: WeeklyPlanConstants.cardDecoration,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary.withOpacity(0.15),
                          AppTheme.secondary.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$planTotalQuestions Soru',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                borderRadius: BorderRadius.circular(4),
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Text(
                '$planCompletedQuestions / $planTotalQuestions soru tamamlandı',
                style: WeeklyPlanConstants.subtitleTextStyle,
              ),
            ],
          ),
          children: [
            const Divider(
              height: 1,
              color: Colors.white12,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: WeeklyPlanConstants.days.map((day) {
                  final dayPlans = plan.dailyPlans[day] ?? [];
                  if (dayPlans.isEmpty) return const SizedBox.shrink();

                  final dayTotalQuestions = dayPlans.fold<int>(
                    0,
                    (sum, plan) => sum + plan.targetQuestions,
                  );
                  final dayCompletedQuestions = dayPlans.fold<int>(
                    0,
                    (sum, plan) =>
                        sum + (plan.isCompleted ? plan.targetQuestions : 0),
                  );

                  return _buildDaySection(
                    day: day,
                    plans: dayPlans,
                    totalQuestions: dayTotalQuestions,
                    completedQuestions: dayCompletedQuestions,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection({
    required String day,
    required List<DailyPlanItem> plans,
    required int totalQuestions,
    required int completedQuestions,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withOpacity(0.15),
                      AppTheme.secondary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$completedQuestions / $totalQuestions',
                style: WeeklyPlanConstants.subtitleTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...plans.map((item) => _buildPlanItem(item)),
        ],
      ),
    );
  }

  Widget _buildPlanItem(DailyPlanItem item) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        bottom: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.isCompleted
                  ? AppTheme.primary.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isCompleted ? Icons.check : Icons.circle_outlined,
              color: item.isCompleted
                  ? AppTheme.primary
                  : Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.subject} - ${item.topic}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white.withOpacity(0.5),
                decorationThickness: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.targetQuestions}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
