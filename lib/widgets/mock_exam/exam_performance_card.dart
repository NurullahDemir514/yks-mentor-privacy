import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/mock_exam.dart';
import '../../constants/theme.dart';
import 'package:intl/intl.dart';

class ExamPerformanceCard extends StatelessWidget {
  final String examType;
  final List<MockExam> completedExams;
  final String? selectedBranch;

  const ExamPerformanceCard({
    super.key,
    required this.examType,
    required this.completedExams,
    this.selectedBranch,
  });

  double get averageNet =>
      completedExams.map((e) => e.net!).reduce((a, b) => a + b) /
      completedExams.length;
  double get maxNet =>
      completedExams.map((e) => e.net!).reduce((a, b) => a > b ? a : b);
  double get minNet =>
      completedExams.map((e) => e.net!).reduce((a, b) => a < b ? a : b);
  double get lastNet => completedExams.last.net!;

  MockExam get maxExam =>
      completedExams.reduce((a, b) => a.net! > b.net! ? a : b);
  MockExam get minExam =>
      completedExams.reduce((a, b) => a.net! < b.net! ? a : b);
  MockExam get lastExam => completedExams.last;

  Color _getScoreColor(double score) {
    if (score >= 35) return Colors.green;
    if (score >= 25) return Colors.blue;
    if (score >= 15) return Colors.orange;
    return Colors.red;
  }

  void _showOverlay(BuildContext context, String message, GlobalKey key) {
    final overlay = Overlay.of(context);
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero);

    if (renderBox == null || offset == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 48,
        left: offset.dx,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: renderBox.size.width + 32,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1D2B).withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      entry?.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredExams = selectedBranch == null
        ? completedExams
        : completedExams
            .where((exam) => exam.branch == selectedBranch)
            .toList();

    final averageNet = filteredExams.isEmpty
        ? 0.0
        : filteredExams.map((e) => e.net ?? 0).reduce((a, b) => a + b) /
            filteredExams.length;

    final bestNet = filteredExams.isEmpty
        ? 0.0
        : filteredExams.map((e) => e.net ?? 0).reduce(max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (examType == 'TYT' ? Colors.blue : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  examType == 'TYT'
                      ? Icons.assignment_outlined
                      : Icons.assignment_late_outlined,
                  color: examType == 'TYT'
                      ? Colors.blue.withOpacity(0.7)
                      : Colors.orange.withOpacity(0.7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examType == 'BRANCH'
                        ? 'Branş İstatistikleri'
                        : '$examType İstatistikleri',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${filteredExams.length} Deneme',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Ortalama',
                  averageNet,
                  Icons.analytics_outlined,
                  _getScoreColor(averageNet),
                  filteredExams,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'En Yüksek',
                  bestNet,
                  Icons.trending_up_outlined,
                  Colors.green,
                  filteredExams,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'En Düşük',
                  minNet,
                  Icons.trending_down_outlined,
                  Colors.red,
                  filteredExams,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Son Net',
                  lastNet,
                  Icons.flag_outlined,
                  _getScoreColor(lastNet),
                  filteredExams,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: averageNet / 120,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: _getScoreColor(averageNet),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, double value,
      IconData icon, Color color, List<MockExam> filteredExams) {
    String tooltip = '';
    String subtitle = '';
    final key = GlobalKey();

    switch (label) {
      case 'Ortalama':
        tooltip = '${filteredExams.length} denemenin ortalaması';
        break;
      case 'En Yüksek':
        tooltip =
            '${maxExam.publisher} • ${DateFormat('d MMM', 'tr_TR').format(maxExam.date)}';
        subtitle = maxExam.publisher;
        break;
      case 'En Düşük':
        tooltip =
            '${minExam.publisher} • ${DateFormat('d MMM', 'tr_TR').format(minExam.date)}';
        subtitle = minExam.publisher;
        break;
      case 'Son Net':
        tooltip =
            '${lastExam.publisher} • ${DateFormat('d MMM', 'tr_TR').format(lastExam.date)}';
        subtitle = lastExam.publisher;
        break;
    }

    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showOverlay(context, tooltip, key),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(0.8),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle.isNotEmpty ? subtitle : label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
