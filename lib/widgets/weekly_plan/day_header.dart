import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/weekly_plan.dart';

class DayHeader extends StatelessWidget {
  final String day;
  final List<DailyPlanItem> plans;

  const DayHeader({
    super.key,
    required this.day,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = plans.where((plan) => plan.isCompleted).length;
    final progress = plans.isEmpty ? 0.0 : completedCount / plans.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withOpacity(0.15),
                      AppTheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plans.length} Görev',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progress == 1.0
                      ? Colors.green.withOpacity(0.1)
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: progress == 1.0
                        ? Colors.green.withOpacity(0.2)
                        : AppTheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      progress == 1.0
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      color: progress == 1.0 ? Colors.green : AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      progress == 1.0
                          ? 'Tamamlandı'
                          : '$completedCount/${plans.length}',
                      style: TextStyle(
                        color:
                            progress == 1.0 ? Colors.green : AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Flexible(
                flex: completedCount,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        progress == 1.0
                            ? Colors.green.withOpacity(0.7)
                            : AppTheme.primary.withOpacity(0.7),
                        progress == 1.0 ? Colors.green : AppTheme.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (progress == 1.0 ? Colors.green : AppTheme.primary)
                                .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: plans.length - completedCount,
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
