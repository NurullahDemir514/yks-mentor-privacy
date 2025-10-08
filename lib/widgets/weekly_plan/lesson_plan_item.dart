import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/weekly_plan.dart';
import '../../providers/question_tracking_provider.dart';
import '../../widgets/base/base_lesson_plan_item.dart';
import '../../constants/theme.dart';
import 'edit_lesson_plan_modal.dart';
import '../../providers/weekly_plan_provider.dart';

class LessonPlanItem extends BaseLessonPlanItem {
  final String day;
  final Function(DailyPlanItem, String) onPlanItemTap;
  final Function(DailyPlanItem, String) onPlanItemDelete;

  const LessonPlanItem({
    super.key,
    required super.plan,
    required this.day,
    required this.onPlanItemTap,
    required this.onPlanItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Eğer plan silinmişse widget'ı gösterme
    if (plan.isDeleted) {
      return const SizedBox.shrink();
    }

    final trackings = Provider.of<QuestionTrackingProvider>(context)
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

    // Hedef soru sayısına ulaşıldığında otomatik olarak tamamlandı olarak işaretle
    if (totalSolved >= plan.targetQuestions && !plan.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<WeeklyPlanProvider>().updatePlanItem(
              day,
              plan,
              plan.copyWith(isCompleted: true),
            );
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: plan.isCompleted
            ? Colors.green.withOpacity(0.05)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: plan.isCompleted
              ? Colors.green.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: plan.isCompleted
                              ? Colors.green.withOpacity(0.15)
                              : AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: plan.isCompleted
                                ? Colors.green.withOpacity(0.2)
                                : AppTheme.primary.withOpacity(0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          plan.subject,
                          style: TextStyle(
                            color: plan.isCompleted
                                ? Colors.green
                                : AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.topic,
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(plan.isCompleted ? 0.6 : 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                            decoration: plan.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white.withOpacity(0.6),
                            decorationThickness: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: plan.isCompleted
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: plan.isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        plan.isCompleted
                            ? 'Tamamlandı'
                            : '$totalSolved/${plan.targetQuestions}',
                        style: TextStyle(
                          color:
                              plan.isCompleted ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditLessonPlanModal(
                              plan: plan,
                              day: day,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.edit_rounded,
                            color: AppTheme.primary.withOpacity(0.9),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: () => onPlanItemDelete(plan, day),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.delete_rounded,
                            color: Colors.red.withOpacity(0.8),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
