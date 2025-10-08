import 'package:flutter/material.dart';
import '../../models/weekly_plan.dart';
import '../../constants/theme.dart';
import '../../providers/question_tracking_provider.dart';
import 'package:provider/provider.dart';

abstract class BaseLessonPlanItem extends StatelessWidget {
  final DailyPlanItem plan;

  const BaseLessonPlanItem({
    super.key,
    required this.plan,
  });

  bool isCompletedForDay(BuildContext context) {
    if (plan.isCompleted) return true;

    final trackings =
        Provider.of<QuestionTrackingProvider>(context, listen: false)
            .todayTrackings
            .where((t) =>
                t.subject == plan.subject &&
                t.topic == plan.topic &&
                t.date.year == plan.date.year &&
                t.date.month == plan.date.month &&
                t.date.day == plan.date.day);

    final totalSolved = trackings.fold<int>(
      0,
      (sum, tracking) => sum + tracking.totalQuestions,
    );

    return plan.targetQuestions > 0 && totalSolved >= plan.targetQuestions;
  }

  Color getProgressColor(double progress) {
    if (progress >= 0.8) {
      return Colors.green;
    } else if (progress >= 0.6) {
      return Colors.blue;
    } else if (progress >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red.withOpacity(0.7);
    }
  }

  Widget buildSubjectBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: Colors.orange,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            plan.subject,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBadge(BuildContext context,
      {bool isTimerRunning = false, String? timerText}) {
    if (isTimerRunning && timerText != null) {
      return Container(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              color: AppTheme.primary,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              timerText,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    final isCompleted = isCompletedForDay(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_outline : Icons.pending_outlined,
            color: isCompleted ? Colors.green : Colors.white.withOpacity(0.7),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'Tamamlandı' : 'Bekliyor',
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopicText() {
    return Text(
      plan.topic,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget buildProgressInfo({
    required int totalSolved,
    required double progress,
    double? netOran,
    String? timePerQuestion,
  }) {
    return Row(
      children: [
        Icon(
          Icons.task_alt,
          size: 14,
          color: getProgressColor(progress),
        ),
        const SizedBox(width: 8),
        Text(
          '$totalSolved/${plan.targetQuestions} Soru',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        if (netOran != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: getProgressColor(netOran / 100).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: getProgressColor(netOran / 100).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '%${netOran.toStringAsFixed(1)} Net',
              style: TextStyle(
                color: getProgressColor(netOran / 100),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
        if (timePerQuestion != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              timePerQuestion,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
