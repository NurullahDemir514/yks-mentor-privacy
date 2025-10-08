import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mock_exam.dart';
import '../../constants/theme.dart';

class ExamListItem extends StatelessWidget {
  final MockExam exam;

  const ExamListItem({
    super.key,
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: exam.result != null
              ? Colors.green.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
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
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  exam.publisher,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exam.topic,
                  style: TextStyle(
                    color: exam.result != null
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration:
                        exam.result != null ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white.withOpacity(0.6),
                    decorationThickness: 2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: exam.result != null
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: exam.result != null
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  exam.result != null ? 'Tamamlandı' : 'Bekliyor',
                  style: TextStyle(
                    color: exam.result != null ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (exam.result != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildResultItem(
                  Icons.check_circle_outline,
                  Colors.green,
                  '${exam.correctAnswers} D',
                ),
                const SizedBox(width: 12),
                _buildResultItem(
                  Icons.cancel_outlined,
                  Colors.red,
                  '${exam.wrongAnswers} Y',
                ),
                const SizedBox(width: 12),
                _buildResultItem(
                  Icons.remove_circle_outline,
                  Colors.orange,
                  '${exam.emptyAnswers} B',
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(exam.net!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getScoreColor(exam.net!).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '${exam.net!.toStringAsFixed(2)} Net',
                    style: TextStyle(
                      color: _getScoreColor(exam.net!),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('d MMMM y', 'tr_TR').format(exam.date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              if (exam.result != null) ...[
                const Spacer(),
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  '${exam.duration?.inMinutes ?? 0} dk',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 35) return Colors.green;
    if (score >= 25) return Colors.blue;
    if (score >= 15) return Colors.orange;
    return Colors.red;
  }
}
