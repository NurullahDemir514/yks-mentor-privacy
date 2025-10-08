import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../constants/weekly_plan_constants.dart';

class WeeklyProgressCard extends StatelessWidget {
  final int completedQuestions;
  final int totalQuestions;

  const WeeklyProgressCard({
    super.key,
    required this.completedQuestions,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: WeeklyPlanConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bu Haftaki İlerleme',
                style: WeeklyPlanConstants.titleTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: totalQuestions > 0 ? completedQuestions / totalQuestions : 0,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$completedQuestions / $totalQuestions soru tamamlandı',
            style: WeeklyPlanConstants.subtitleTextStyle,
          ),
        ],
      ),
    );
  }
}
