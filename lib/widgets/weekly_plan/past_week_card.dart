import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/weekly_plan.dart';
import '../../constants/weekly_plan_constants.dart';

class PastWeekCard extends StatelessWidget {
  final WeeklyPlan plan;

  const PastWeekCard({
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

    // İstatistikleri hesapla
    int totalQuestions = 0;
    int completedQuestions = 0;
    int totalMockExams = 0;
    int completedMockExams = 0;
    int totalLessons = 0;
    int completedLessons = 0;

    plan.dailyPlans.forEach((day, dayPlans) {
      for (var item in dayPlans) {
        if (item.isMockExam) {
          totalMockExams++;
          if (item.isCompleted) completedMockExams++;
        } else {
          totalLessons++;
          if (item.isCompleted) completedLessons++;
        }
        totalQuestions += item.targetQuestions;
        if (item.isCompleted) {
          completedQuestions += item.targetQuestions;
        }
      }
    });

    final progress =
        totalQuestions > 0 ? completedQuestions / totalQuestions : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            collapsedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatBadge(
                      '${(progress * 100).toInt()}%',
                      color: _getProgressColor(progress),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem(
                      Icons.assignment_outlined,
                      '$completedMockExams/$totalMockExams',
                      'Deneme',
                      AppTheme.primary,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.menu_book_outlined,
                      '$completedLessons/$totalLessons',
                      'Ders',
                      Colors.orange,
                    ),
                    const Spacer(),
                    _buildStatItem(
                      Icons.check_circle_outline,
                      '$completedQuestions/$totalQuestions',
                      'Soru',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: WeeklyPlanConstants.days.map((day) {
                    final dayPlans = plan.dailyPlans[day] ?? [];
                    if (dayPlans.isEmpty) return const SizedBox.shrink();

                    return _buildDayItem(day, dayPlans);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color.withOpacity(0.7),
          size: 14,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayItem(String day, List<DailyPlanItem> plans) {
    final completedCount = plans.where((p) => p.isCompleted).length;
    final progress = plans.isNotEmpty ? completedCount / plans.length : 0.0;

    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.8,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          title: Row(
            children: [
              Text(
                day,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _buildStatBadge(
                '${(progress * 100).toInt()}%',
                color: _getProgressColor(progress),
              ),
            ],
          ),
          children: [
            if (plans.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: plans.map((plan) => _buildPlanItem(plan)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanItem(DailyPlanItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            item.isCompleted
                ? Icons.check_circle_outline
                : Icons.circle_outlined,
            color:
                item.isCompleted ? Colors.green : Colors.white.withOpacity(0.3),
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.subject} - ${item.topic}',
              style: TextStyle(
                color: Colors.white.withOpacity(item.isCompleted ? 0.5 : 0.7),
                fontSize: 11,
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white.withOpacity(0.3),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.targetQuestions}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red.withOpacity(0.7);
  }
}
