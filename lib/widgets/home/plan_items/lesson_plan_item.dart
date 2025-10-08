import 'package:flutter/material.dart';
import '../../../models/weekly_plan.dart';
import '../../../providers/question_tracking_provider.dart';
import '../../../providers/timer_provider.dart';
import '../../../widgets/base/base_lesson_plan_item.dart';
import 'package:provider/provider.dart';
import '../../../widgets/app_scaffold.dart';

class LessonPlanItem extends BaseLessonPlanItem {
  final QuestionTrackingProvider questionTrackingProvider;

  const LessonPlanItem({
    super.key,
    required super.plan,
    required this.questionTrackingProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _LessonPlanItemContent(
      plan: plan,
      questionTrackingProvider: questionTrackingProvider,
      isCompleted: isCompletedForDay(context),
    );
  }
}

class _LessonPlanItemContent extends StatefulWidget {
  final DailyPlanItem plan;
  final QuestionTrackingProvider questionTrackingProvider;
  final bool isCompleted;

  const _LessonPlanItemContent({
    required this.plan,
    required this.questionTrackingProvider,
    required this.isCompleted,
  });

  @override
  State<_LessonPlanItemContent> createState() => _LessonPlanItemContentState();
}

class _LessonPlanItemContentState extends State<_LessonPlanItemContent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final trackings = widget.questionTrackingProvider.todayTrackings.where(
        (t) =>
            t.subject == widget.plan.subject &&
            t.topic == widget.plan.topic &&
            t.date.year == widget.plan.date.year &&
            t.date.month == widget.plan.date.month &&
            t.date.day == widget.plan.date.day);

    final totalSolved = trackings.fold<int>(
      0,
      (sum, tracking) => sum + tracking.totalQuestions,
    );

    final totalCorrect =
        trackings.fold<int>(0, (sum, t) => sum + t.correctAnswers);
    final totalWrong = trackings.fold<int>(0, (sum, t) => sum + t.wrongAnswers);

    final progress = widget.plan.targetQuestions > 0
        ? totalSolved / widget.plan.targetQuestions
        : 0.0;

    final netOran = totalSolved > 0
        ? ((totalCorrect - (totalWrong * 0.25)) / totalSolved) * 100
        : 0.0;

    final isTimerRunningForThisPlan = timerProvider.isRunning &&
        timerProvider.selectedSubject == widget.plan.subject &&
        timerProvider.selectedTopic == widget.plan.topic;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isCompleted
            ? Colors.green.withOpacity(0.03)
            : isTimerRunningForThisPlan
                ? Colors.blue.withOpacity(0.03)
                : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isCompleted
              ? Colors.green.withOpacity(0.2)
              : isTimerRunningForThisPlan
                  ? Colors.blue.withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
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
                      color: widget.isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.isCompleted
                            ? Colors.green.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.plan.subject,
                      style: TextStyle(
                        color: widget.isCompleted ? Colors.green : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.plan.topic,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(widget.isCompleted ? 0.6 : 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        decoration: widget.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white.withOpacity(0.6),
                        decorationThickness: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!_isExpanded) ...[
                    if (isTimerRunningForThisPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          timerProvider.formattedTime,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                    else if (widget.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Tamamlandı',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${totalSolved}/${widget.plan.targetQuestions}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 400),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
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
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$totalCorrect Doğru',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$totalWrong Yanlış',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '%${netOran.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                color: progress >= 1.0
                                    ? Colors.green
                                    : Colors.orange,
                                minHeight: 6,
                              ),
                            ),
                            if (!widget.isCompleted &&
                                !isTimerRunningForThisPlan) ...[
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () {
                                  _startTimer(context);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.05),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  totalSolved > 0
                                      ? 'Çalışmaya Devam Et'
                                      : 'Çalışmaya Başla',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  sizeCurve: Curves.easeOutQuart,
                  firstCurve: Curves.easeOutQuart,
                  secondCurve: Curves.easeOutQuart,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool isCompletedForDay(BuildContext context) {
    return widget.isCompleted;
  }

  void _startTimer(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    // Timer bilgilerini ayarla ama başlatma
    timerProvider.setSubjectTimer(
      widget.plan.subject,
      topic: widget.plan.topic,
    );

    // Timer sayfasına yönlendir
    AppScaffold.of(context)?.changePage(4);
  }
}
