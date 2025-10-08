import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/theme.dart';
import 'result_field.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final Map<String, TextEditingController> controllers;
  final Map<String, int> results;
  final int expectedTotal;
  final Function(String, String, String) onValuesChanged;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.controllers,
    required this.results,
    required this.expectedTotal,
    required this.onValuesChanged,
  });

  Color _getScoreColor(double score) {
    if (score >= 35) return Colors.green;
    if (score >= 25) return Colors.blue;
    if (score >= 15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final netScore = results['correct']! - (results['wrong']! * 0.25);
    final emptyCount =
        expectedTotal - (results['correct']! + results['wrong']!);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                subject,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color:
                      results['correct']! + results['wrong']! <= expectedTotal
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${results['correct']! + results['wrong']!}/$expectedTotal',
                  style: TextStyle(
                    color:
                        results['correct']! + results['wrong']! <= expectedTotal
                            ? Colors.green
                            : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(netScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${netScore.toStringAsFixed(2)} Net',
                  style: TextStyle(
                    color: _getScoreColor(netScore),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ResultField(
                  controller: controllers['correct']!,
                  label: 'D',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onChanged: (value) =>
                      onValuesChanged(subject, 'correct', value),
                  expectedTotal: expectedTotal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ResultField(
                  controller: controllers['wrong']!,
                  label: 'Y',
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                  onChanged: (value) =>
                      onValuesChanged(subject, 'wrong', value),
                  expectedTotal: expectedTotal,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      color: Colors.orange.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'B: $emptyCount',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
