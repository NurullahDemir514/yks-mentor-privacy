import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/mock_exam.dart';
import '../../constants/theme.dart';
import 'package:intl/intl.dart';

class PerformanceChart extends StatelessWidget {
  final List<MockExam> completedExams;
  final String? selectedBranch;

  const PerformanceChart({
    super.key,
    required this.completedExams,
    this.selectedBranch,
  });

  List<MockExam> get lastTenExams {
    final filteredExams = selectedBranch == null
        ? completedExams
        : completedExams
            .where(
                (exam) => exam.branch == selectedBranch && exam.examId != null)
            .toList();
    if (filteredExams.length <= 10) return filteredExams;
    return filteredExams.sublist(filteredExams.length - 10);
  }

  @override
  Widget build(BuildContext context) {
    final exams = lastTenExams;
    final maxY =
        (exams.map((e) => e.net!).reduce((a, b) => a > b ? a : b) * 1.1)
            .roundToDouble();
    final interval = (maxY / 6).roundToDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 12),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.5,
        ),
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: const Color(0xFF1F1D2B),
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 0,
              getTooltipItems: (List<LineBarSpot> spots) {
                return spots.map((spot) {
                  final exam = exams[spot.x.toInt()];
                  return LineTooltipItem(
                    '${DateFormat('d MMMM', 'tr_TR').format(exam.date)}\n${exam.net!.toStringAsFixed(2)} net',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (data, spots) {
              return spots.map((spot) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: AppTheme.primary.withOpacity(0.2),
                    strokeWidth: 2,
                    dashArray: [3, 3],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: AppTheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: interval,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= exams.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      DateFormat('d/M', 'tr_TR').format(
                        exams[value.toInt()].date,
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: exams.length - 1.0,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: exams.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.net!);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.5),
                  AppTheme.primary,
                ],
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withOpacity(0.15),
                    AppTheme.primary.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
