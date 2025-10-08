import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question_tracking.dart';
import '../../providers/question_tracking_provider.dart';
import '../../constants/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyStats {
  final double averageSuccess;
  final double bestSuccess;
  final double worstSuccess;
  final String bestDay;
  final String worstDay;

  const WeeklyStats({
    required this.averageSuccess,
    required this.bestSuccess,
    required this.worstSuccess,
    required this.bestDay,
    required this.worstDay,
  });
}

class DailyStats {
  final int correctAnswers;
  final int totalQuestions;

  const DailyStats({
    required this.correctAnswers,
    required this.totalQuestions,
  });
}

class AnalysisTab extends StatelessWidget {
  const AnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionTrackingProvider>(
      builder: (context, provider, child) {
        final trackings = provider.allTrackings;

        if (trackings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: AppTheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Analiz için yeterli veri yok',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        // Genel istatistikleri hesapla
        final totalQuestions = trackings.fold<int>(
          0,
          (sum, tracking) => sum + tracking.totalQuestions,
        );
        final totalCorrect = trackings.fold<int>(
          0,
          (sum, tracking) => sum + tracking.correctAnswers,
        );
        final totalWrong = trackings.fold<int>(
          0,
          (sum, tracking) => sum + tracking.wrongAnswers,
        );
        final totalEmpty = trackings.fold<int>(
          0,
          (sum, tracking) => sum + tracking.emptyAnswers,
        );
        final averageSuccess = totalQuestions > 0
            ? (totalCorrect / totalQuestions * 100).toStringAsFixed(1)
            : '0.0';

        // Aktif günleri hesapla
        final activeDays = trackings
            .map((t) => '${t.date.year}-${t.date.month}-${t.date.day}')
            .toSet()
            .length;

        // Günlük ortalama soru sayısı
        final averageQuestionsPerDay = totalQuestions / activeDays;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genel İstatistikler Kartı
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1F1D2B).withOpacity(0.98),
                            const Color(0xFF252837).withOpacity(0.98),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Detaylı İstatistikler',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailedStats(trackings),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1F1D2B).withOpacity(0.98),
                        const Color(0xFF252837).withOpacity(0.98),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primary.withOpacity(0.2),
                                    AppTheme.primary.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.analytics_outlined,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Genel İstatistikler',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getSuccessColor(
                                        double.parse(averageSuccess))
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getSuccessColor(
                                          double.parse(averageSuccess))
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: _getSuccessColor(
                                        double.parse(averageSuccess)),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '%$averageSuccess',
                                    style: TextStyle(
                                      color: _getSuccessColor(
                                          double.parse(averageSuccess)),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stats
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildStatItem(
                                  icon: Icons.assignment_outlined,
                                  label: 'Toplam Soru',
                                  value: totalQuestions.toString(),
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Aktif Gün',
                                  value: activeDays.toString(),
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  icon: Icons.speed_outlined,
                                  label: 'Günlük Ort.',
                                  value:
                                      averageQuestionsPerDay.toStringAsFixed(1),
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildStatItem(
                                  icon: Icons.check_circle_outline,
                                  label: 'Doğru',
                                  value: totalCorrect.toString(),
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  icon: Icons.cancel_outlined,
                                  label: 'Yanlış',
                                  value: totalWrong.toString(),
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  icon: Icons.radio_button_unchecked,
                                  label: 'Boş',
                                  value: totalEmpty.toString(),
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Haftalık Performans Grafiği
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1F1D2B).withOpacity(0.98),
                            const Color(0xFF252837).withOpacity(0.98),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Detaylı Performans Analizi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailedPerformanceAnalysis(trackings),
                        ],
                      ),
                    ),
                  );
                },
                child: _buildWeeklyPerformanceCard(trackings),
              ),
              const SizedBox(height: 24),
              // Ders Bazlı Analiz
              _buildSubjectAnalysisCard(trackings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedStats(List<QuestionTracking> trackings) {
    // En yüksek ve en düşük performans günlerini bul
    var bestDay = trackings.first;
    var worstDay = trackings.first;
    var bestSuccess = 0.0;
    var worstSuccess = 100.0;

    for (final tracking in trackings) {
      final success = tracking.totalQuestions > 0
          ? (tracking.correctAnswers / tracking.totalQuestions * 100)
          : 0.0;

      if (success > bestSuccess) {
        bestSuccess = success;
        bestDay = tracking;
      }
      if (success < worstSuccess && tracking.totalQuestions > 0) {
        worstSuccess = success;
        worstDay = tracking;
      }
    }

    return Column(
      children: [
        // En İyi Performans
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'En İyi Performans',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMMM y', 'tr_TR').format(bestDay.date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Başarı: %${bestSuccess.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Toplam: ${bestDay.totalQuestions} soru (${bestDay.correctAnswers} doğru)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Gelişim Alanı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gelişim Alanı',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMMM y', 'tr_TR').format(worstDay.date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Başarı: %${worstSuccess.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Toplam: ${worstDay.totalQuestions} soru (${worstDay.correctAnswers} doğru)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<MapEntry<DateTime, Map<String, dynamic>>> _prepareLastDaysData(
      List<QuestionTracking> trackings,
      {int maxDays = 30}) {
    final now = DateTime.now();
    final uniqueDates = trackings
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final days = uniqueDates.length < maxDays ? uniqueDates.length : maxDays;

    return List.generate(days, (index) {
      final date = uniqueDates[index];
      final dayTrackings = trackings.where((t) =>
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day);

      int totalQuestions = 0;
      int correctAnswers = 0;
      double success = 0;

      if (dayTrackings.isNotEmpty) {
        totalQuestions =
            dayTrackings.fold<int>(0, (sum, t) => sum + t.totalQuestions);
        correctAnswers =
            dayTrackings.fold<int>(0, (sum, t) => sum + t.correctAnswers);
        success =
            totalQuestions > 0 ? (correctAnswers / totalQuestions * 100) : 0;
      }

      return MapEntry(
        date,
        {
          'success': success,
          'total': totalQuestions,
          'correct': correctAnswers,
        },
      );
    }).reversed.toList();
  }

  Widget _buildDetailedPerformanceAnalysis(List<QuestionTracking> trackings) {
    final last30Days = _prepareLastDaysData(trackings);

    if (last30Days.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri yok',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      );
    }

    final activeDays =
        last30Days.where((day) => day.value['total'] as int > 0).length;
    final title = activeDays == 1 ? '1 günlük veri' : '$activeDays günlük veri';

    return Expanded(
      child: Column(
        children: [
          // Aylık grafik
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.8),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final date = last30Days[touchedSpot.x.toInt()].key;
                        final success = touchedSpot.y;
                        final total = last30Days[touchedSpot.x.toInt()]
                            .value['total'] as int;
                        final correct = last30Days[touchedSpot.x.toInt()]
                            .value['correct'] as int;

                        return LineTooltipItem(
                          '${DateFormat('d MMMM', 'tr_TR').format(date)}\n'
                          '%${success.toStringAsFixed(1)} başarı\n'
                          '$correct/$total doğru',
                          TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: AppTheme.primary.withOpacity(0.2),
                          strokeWidth: 2,
                          dashArray: [3, 3],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 6,
                            color: AppTheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 5,
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
                  checkToShowHorizontalLine: (value) {
                    return true;
                  },
                  checkToShowVerticalLine: (value) {
                    return true;
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
                      getTitlesWidget: (value, meta) {
                        if (value % 5 != 0 ||
                            value < 0 ||
                            value >= last30Days.length) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('d/M', 'tr_TR')
                                .format(last30Days[value.toInt()].key),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '%${value.toInt()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: last30Days.length - 1.0,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: last30Days
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.value['success'] as double,
                            ))
                        .toList(),
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
                      getDotPainter: (spot, percent, barData, index) {
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
                        colors: [
                          AppTheme.primary.withOpacity(0.15),
                          AppTheme.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // İstatistik özeti
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$activeDays aktif gün',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMonthlyStatItem(
                      'Toplam Soru',
                      last30Days.fold<int>(
                          0, (sum, day) => sum + (day.value['total'] as int)),
                      Icons.assignment_outlined,
                      AppTheme.primary,
                    ),
                    _buildMonthlyStatItem(
                      'Doğru',
                      last30Days.fold<int>(
                          0, (sum, day) => sum + (day.value['correct'] as int)),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                    _buildMonthlyStatItem(
                      'Ortalama',
                      last30Days
                              .where((day) => day.value['total'] as int > 0)
                              .fold<double>(
                                  0,
                                  (sum, day) =>
                                      sum + (day.value['success'] as double)) ~/
                          last30Days
                              .where((day) => day.value['total'] as int > 0)
                              .length,
                      Icons.trending_up,
                      Colors.orange,
                      isPercentage: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatItem(
    String label,
    num value,
    IconData icon,
    Color color, {
    bool isPercentage = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            isPercentage ? '%$value' : value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformanceCard(List<QuestionTracking> trackings) {
    final last7Days = _prepareLastDaysData(trackings, maxDays: 7);

    if (last7Days.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1F1D2B).withOpacity(0.98),
              const Color(0xFF252837).withOpacity(0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            'Henüz veri yok',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1F1D2B).withOpacity(0.98),
            const Color(0xFF252837).withOpacity(0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.2),
                        AppTheme.primary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Haftalık Performans',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final date = last7Days[touchedSpot.x.toInt()].key;
                          final success = touchedSpot.y;

                          return LineTooltipItem(
                            '${DateFormat('EEEE', 'tr_TR').format(date)}\n'
                            '%${success.toStringAsFixed(1)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((index) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: AppTheme.primary.withOpacity(0.2),
                            strokeWidth: 2,
                            dashArray: [3, 3],
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 6,
                              color: AppTheme.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
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
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= last7Days.length) {
                            return const SizedBox();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat('E', 'tr_TR')
                                  .format(last7Days[value.toInt()].key)
                                  .substring(0, 2),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '%${value.toInt()}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: last7Days.length - 1.0,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: last7Days
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.value['success'] as double,
                              ))
                          .toList(),
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
                        getDotPainter: (spot, percent, barData, index) {
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
                          colors: [
                            AppTheme.primary.withOpacity(0.15),
                            AppTheme.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectAnalysisCard(List<QuestionTracking> trackings) {
    // Ders bazlı istatistikleri hesapla
    final subjectStats = <String, Map<String, dynamic>>{};

    for (final tracking in trackings) {
      if (!subjectStats.containsKey(tracking.subject)) {
        subjectStats[tracking.subject] = {
          'total': 0,
          'correct': 0,
          'wrong': 0,
          'empty': 0,
          'dates': <DateTime>[],
          'trend': <double>[],
        };
      }

      subjectStats[tracking.subject]!['total'] += tracking.totalQuestions;
      subjectStats[tracking.subject]!['correct'] += tracking.correctAnswers;
      subjectStats[tracking.subject]!['wrong'] += tracking.wrongAnswers;
      subjectStats[tracking.subject]!['empty'] += tracking.emptyAnswers;
      subjectStats[tracking.subject]!['dates'].add(tracking.date);

      // Son 5 günlük trend hesaplama
      final success = tracking.totalQuestions > 0
          ? (tracking.correctAnswers / tracking.totalQuestions * 100)
          : 0.0;
      subjectStats[tracking.subject]!['trend'].add(success);
    }

    // Başarı oranına göre sırala
    final sortedSubjects = subjectStats.entries.toList()
      ..sort((a, b) {
        final aSuccess = a.value['total'] > 0
            ? (a.value['correct'] / a.value['total'] * 100)
            : 0.0;
        final bSuccess = b.value['total'] > 0
            ? (b.value['correct'] / b.value['total'] * 100)
            : 0.0;
        return bSuccess.compareTo(aSuccess);
      });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1F1D2B).withOpacity(0.98),
            const Color(0xFF252837).withOpacity(0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.2),
                        AppTheme.primary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Ders Analizi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
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
                    '${sortedSubjects.length} ders',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: sortedSubjects.length,
            itemBuilder: (context, index) {
              final subject = sortedSubjects[index].key;
              final stats = sortedSubjects[index].value;
              final total = stats['total'] as int;
              final correct = stats['correct'] as int;
              final success = total > 0 ? (correct / total * 100) : 0.0;
              final trend = (stats['trend'] as List<double>).take(5).toList();
              final dates = (stats['dates'] as List<DateTime>).take(5).toList();

              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (context, scrollController) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1F1D2B).withOpacity(0.98),
                              const Color(0xFF252837).withOpacity(0.98),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                subject,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: _buildSubjectDetailStats(stats),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Son çalışma: ${DateFormat('d MMM', 'tr_TR').format(dates.first)}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getSuccessColor(success).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    _getSuccessColor(success).withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              '%${success.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: _getSuccessColor(success),
                                fontSize: 13,
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
                            flex: 3,
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: success / 100,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getSuccessColor(success),
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildMiniStat(
                                        'D', stats['correct'], Colors.green),
                                    _buildMiniStat(
                                        'Y', stats['wrong'], Colors.red),
                                    _buildMiniStat(
                                        'B', stats['empty'], Colors.orange),
                                    _buildMiniStat(
                                        'T', stats['total'], AppTheme.primary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 40,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: trend.asMap().entries.map((entry) {
                                  final value = entry.value;
                                  final color = _getSuccessColor(value);
                                  final height = (value / 100) * 20 +
                                      4; // Min 4px, max 24px

                                  return Tooltip(
                                    message: '%${value.toStringAsFixed(1)}',
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Container(
                                      width: 4,
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDetailStats(Map<String, dynamic> stats) {
    final total = stats['total'] as int;
    final correct = stats['correct'] as int;
    final success = total > 0 ? (correct / total * 100) : 0.0;
    final dates = stats['dates'] as List<DateTime>;
    final trend = stats['trend'] as List<double>;

    return Column(
      children: [
        // Başarı kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getSuccessColor(success).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getSuccessColor(success).withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    success >= 70
                        ? Icons.emoji_events
                        : success >= 50
                            ? Icons.trending_up
                            : Icons.warning_amber,
                    color: _getSuccessColor(success),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Başarı Oranı: %${success.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _getSuccessColor(success),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                success >= 70
                    ? 'Harika gidiyorsun! Bu derste oldukça başarılısın.'
                    : success >= 50
                        ? 'İyi gidiyorsun, biraz daha çalışarak daha da iyileşebilirsin.'
                        : 'Bu derse biraz daha fazla zaman ayırman gerekiyor.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // İstatistikler
        Row(
          children: [
            _buildDetailStatItem(
              'Toplam Soru',
              total.toString(),
              Icons.assignment_outlined,
              AppTheme.primary,
            ),
            const SizedBox(width: 12),
            _buildDetailStatItem(
              'Doğru',
              correct.toString(),
              Icons.check_circle_outline,
              Colors.green,
            ),
            const SizedBox(width: 12),
            _buildDetailStatItem(
              'Yanlış',
              stats['wrong'].toString(),
              Icons.cancel_outlined,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDetailStatItem(
              'Boş',
              stats['empty'].toString(),
              Icons.radio_button_unchecked,
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildDetailStatItem(
              'Çalışma Günü',
              dates.toSet().length.toString(),
              Icons.calendar_today_outlined,
              Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildDetailStatItem(
              'Günlük Ort.',
              (total / dates.toSet().length).toStringAsFixed(1),
              Icons.speed_outlined,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Son çalışmalar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Son Çalışmalar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                      '${dates.take(5).length} çalışma',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                dates.take(5).length,
                (index) {
                  final date = dates[index];
                  final performance = trend[index];
                  final isToday = DateTime.now().difference(date).inDays == 0;
                  final isYesterday =
                      DateTime.now().difference(date).inDays == 1;

                  String dateText = isToday
                      ? 'Bugün'
                      : isYesterday
                          ? 'Dün'
                          : DateFormat('d MMMM', 'tr_TR').format(date);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getSuccessColor(performance).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                _getSuccessColor(performance).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            performance >= 70
                                ? Icons.emoji_events
                                : performance >= 50
                                    ? Icons.trending_up
                                    : Icons.warning_amber,
                            color: _getSuccessColor(performance),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateText,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEEE', 'tr_TR').format(date),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getSuccessColor(performance).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getSuccessColor(performance)
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: _getSuccessColor(performance),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '%${performance.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: _getSuccessColor(performance),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSuccessColor(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }
}

class SubjectStats {
  final String subject;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final double successRate;
  final double trend;

  SubjectStats({
    required this.subject,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.successRate,
    required this.trend,
  });
}

class TopicStats {
  final String topic;
  final int correctAnswers;
  final int totalQuestions;
  final double successRate;

  TopicStats({
    required this.topic,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.successRate,
  });
}
