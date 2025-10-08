import 'package:flutter/material.dart';
import '../../models/weekly_plan.dart';
import '../../models/mock_exam_result.dart';
import '../../constants/theme.dart';
import 'edit_mock_exam_modal.dart';

class MockExamItem extends StatelessWidget {
  final DailyPlanItem plan;
  final MockExamResult? result;
  final Function(DailyPlanItem, String) onPlanItemDelete;
  final String day;

  const MockExamItem({
    super.key,
    required this.plan,
    required this.result,
    required this.onPlanItemDelete,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.isDeleted) {
      return const SizedBox.shrink();
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
          onTap: () {},
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
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
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
                        plan.isCompleted ? 'Tamamlandı' : 'Bekliyor',
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
                            builder: (context) => EditMockExamModal(
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
