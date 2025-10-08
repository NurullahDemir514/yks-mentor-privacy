import 'package:flutter/material.dart';
import '../../models/question_tracking.dart';
import '../../models/weekly_plan.dart';
import '../../constants/theme.dart';
import 'package:provider/provider.dart';
import '../../providers/weekly_plan_provider.dart';
import '../../providers/question_tracking_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/exam_subjects.dart';
import '../../services/auth_service.dart';

class DailyTrackingTab extends StatelessWidget {
  final Function(QuestionTracking) onDelete;
  final Function(QuestionTracking) onEdit;

  const DailyTrackingTab({
    super.key,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionTrackingProvider>(
      builder: (context, provider, child) {
        final trackings = provider.todayTrackings;

        if (trackings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.today_outlined,
                  size: 64,
                  color: AppTheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bugün henüz soru çözülmemiş',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        // Günlük istatistikleri hesapla
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDailySummaryCard(
                totalQuestions,
                totalCorrect,
                totalWrong,
                totalEmpty,
                averageSuccess,
              ),
              const SizedBox(height: 24),
              _buildTrackingsList(trackings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailySummaryCard(
    int total,
    int correct,
    int wrong,
    int empty,
    String average,
  ) {
    final now = DateTime.now();
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');
    final dayFormat = DateFormat('EEEE', 'tr_TR');

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
                    Icons.calendar_today,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(now),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayFormat.format(now),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSuccessColor(double.parse(average))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getSuccessColor(double.parse(average))
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: _getSuccessColor(double.parse(average)),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '%$average',
                        style: TextStyle(
                          color: _getSuccessColor(double.parse(average)),
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
                const Text(
                  'Günlük İstatistikler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDailyStatItem(
                      icon: Icons.assignment_outlined,
                      label: 'Toplam',
                      value: total,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildDailyStatItem(
                      icon: Icons.check_circle_outline,
                      label: 'Doğru',
                      value: correct,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildDailyStatItem(
                      icon: Icons.cancel_outlined,
                      label: 'Yanlış',
                      value: wrong,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _buildDailyStatItem(
                      icon: Icons.radio_button_unchecked,
                      label: 'Boş',
                      value: empty,
                      color: Colors.orange,
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

  Widget _buildDailyStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
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
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingsList(List<QuestionTracking> trackings) {
    // Oturumları ders ve konularına göre grupla
    final groupedTrackings = <String, List<QuestionTracking>>{};
    for (var tracking in trackings) {
      final key = '${tracking.subject}|${tracking.topic}';
      if (!groupedTrackings.containsKey(key)) {
        groupedTrackings[key] = [];
      }
      groupedTrackings[key]!.add(tracking);
    }

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withOpacity(0.15),
                      AppTheme.secondary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Çözülen Sorular',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...groupedTrackings.entries.map((entry) {
            final trackings = entry.value;
            final firstTracking = trackings.first;

            // Grup için toplam istatistikleri hesapla
            final totalQuestions = trackings.fold<int>(
              0,
              (sum, t) => sum + t.totalQuestions,
            );
            final totalCorrect = trackings.fold<int>(
              0,
              (sum, t) => sum + t.correctAnswers,
            );
            final totalWrong = trackings.fold<int>(
              0,
              (sum, t) => sum + t.wrongAnswers,
            );
            final totalEmpty = trackings.fold<int>(
              0,
              (sum, t) => sum + t.emptyAnswers,
            );
            final averageSuccess = totalQuestions > 0
                ? (totalCorrect / totalQuestions * 100)
                : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1F1D2B).withOpacity(0.98),
                    const Color(0xFF252837).withOpacity(0.98),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  backgroundColor: Colors.transparent,
                  collapsedBackgroundColor: Colors.transparent,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstTracking.subject,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (firstTracking.topic.isNotEmpty)
                              Text(
                                firstTracking.topic,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          '${trackings.length} Oturum',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getSuccessColor(averageSuccess).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            _getSuccessColor(averageSuccess).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '%${averageSuccess.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: _getSuccessColor(averageSuccess),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(
                            height: 1,
                            color: Color(0xFF363B54),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuestionStat('Toplam', totalQuestions),
                                _buildQuestionStat(
                                    'Doğru', totalCorrect, Colors.green),
                                _buildQuestionStat(
                                    'Yanlış', totalWrong, Colors.red),
                                _buildQuestionStat(
                                    'Boş', totalEmpty, Colors.orange),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...trackings
                              .map((tracking) =>
                                  _buildTrackingItem(context, tracking))
                              .toList(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTrackingItem(BuildContext context, QuestionTracking tracking) {
    final success = tracking.correctAnswers / tracking.totalQuestions * 100;
    final timeFormat = DateFormat('HH:mm', 'tr_TR');

    Future<void> _confirmDelete(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF252837),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Soru kaydını sil',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Bu soru kaydını silmek istediğinizden emin misiniz?',
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'İptal',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () {
                  onDelete(tracking);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Sil',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }

    Future<void> _showEditDialog(BuildContext context) async {
      Widget _buildQuestionInput({
        required TextEditingController controller,
        required String label,
        required Color color,
      }) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: color.withOpacity(0.5),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gerekli';
                  }
                  return null;
                },
              ),
            ],
          ),
        );
      }

      final correctController =
          TextEditingController(text: tracking.correctAnswers.toString());
      final wrongController =
          TextEditingController(text: tracking.wrongAnswers.toString());
      final emptyController =
          TextEditingController(text: tracking.emptyAnswers.toString());
      final notesController = TextEditingController(text: tracking.notes ?? '');

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 400),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.2),
                                AppTheme.primary.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tracking.subject,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  if (tracking.topic.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                        '•',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tracking.topic,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                          letterSpacing: 0.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soru Bilgileri',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildQuestionInput(
                              controller: correctController,
                              label: 'Doğru',
                              color: Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _buildQuestionInput(
                              controller: wrongController,
                              label: 'Yanlış',
                              color: Colors.red,
                            ),
                            const SizedBox(width: 12),
                            _buildQuestionInput(
                              controller: emptyController,
                              label: 'Boş',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Notlar (İsteğe bağlı)',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primary.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white60,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('İptal'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () async {
                            try {
                              // Sayısal değerleri kontrol et
                              final correct =
                                  int.tryParse(correctController.text);
                              final wrong = int.tryParse(wrongController.text);
                              final empty = int.tryParse(emptyController.text);

                              if (correct == null ||
                                  wrong == null ||
                                  empty == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Lütfen geçerli sayılar girin'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (correct < 0 || wrong < 0 || empty < 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Soru sayıları negatif olamaz'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final total = correct + wrong + empty;

                              final updatedTracking = QuestionTracking(
                                id: tracking.id,
                                userId: tracking.userId,
                                subject: tracking.subject,
                                topic: tracking.topic,
                                totalQuestions: total,
                                correctAnswers: correct,
                                wrongAnswers: wrong,
                                emptyAnswers: empty,
                                date: tracking.date,
                                notes: notesController.text.isEmpty
                                    ? null
                                    : notesController.text,
                              );

                              await onEdit(updatedTracking);

                              if (!context.mounted) return;
                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Değişiklikler kaydedildi'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hata oluştu: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Kaydet'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showEditDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Sol taraf - Saat ve İstatistikler
                Expanded(
                  child: Row(
                    children: [
                      // Saat
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppTheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(tracking.date),
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // İstatistikler
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCompactStat(
                                tracking.correctAnswers, Colors.green),
                            _buildCompactStat(
                                tracking.wrongAnswers, Colors.red),
                            _buildCompactStat(
                                tracking.emptyAnswers, Colors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Sağ taraf - Başarı ve Silme
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSuccessColor(success).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getSuccessColor(success).withOpacity(0.2),
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
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.withOpacity(0.7),
                        size: 18,
                      ),
                      onPressed: () => _confirmDelete(context),
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

  Widget _buildCompactStat(int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuestionStat(String label, int value, [Color? color]) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getSuccessColor(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }
}
