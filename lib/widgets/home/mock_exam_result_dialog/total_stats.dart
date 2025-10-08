import 'package:flutter/material.dart';

class TotalStats extends StatelessWidget {
  final Map<String, Map<String, int>> results;
  final double totalNetScore;
  final int expectedTotal;

  const TotalStats({
    super.key,
    required this.results,
    required this.totalNetScore,
    required this.expectedTotal,
  });

  Color _getScoreColor(double score) {
    if (score >= 35) return Colors.green;
    if (score >= 25) return Colors.blue;
    if (score >= 15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getScoreColor(totalNetScore).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getScoreColor(totalNetScore).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                totalNetScore.toStringAsFixed(2),
                style: TextStyle(
                  color: _getScoreColor(totalNetScore),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Net',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.withOpacity(0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    results.values
                        .fold<int>(0, (sum, r) => sum + r['correct']!)
                        .toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red.withOpacity(0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    results.values
                        .fold<int>(0, (sum, r) => sum + r['wrong']!)
                        .toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.remove_circle_outline,
                    color: Colors.orange.withOpacity(0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    results.values
                        .fold<int>(0, (sum, r) => sum + r['empty']!)
                        .toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalNetScore / expectedTotal,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: _getScoreColor(totalNetScore),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
