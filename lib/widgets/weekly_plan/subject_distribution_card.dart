import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../constants/weekly_plan_constants.dart';

class SubjectDistributionCard extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalQuestions;

  const SubjectDistributionCard({
    super.key,
    required this.distribution,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) return const SizedBox.shrink();

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
                  Icons.pie_chart,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ders Dağılımı',
                style: WeeklyPlanConstants.titleTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...distribution.entries.map((entry) {
            final percentage =
                (entry.value / totalQuestions * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${entry.value} soru (%$percentage)',
                        style: WeeklyPlanConstants.subtitleTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: entry.value / totalQuestions,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
