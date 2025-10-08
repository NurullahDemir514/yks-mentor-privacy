import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/mock_exam.dart';
import '../../models/mock_exam_result.dart';
import '../../providers/weekly_plan_provider.dart';
import 'package:provider/provider.dart';
import '../../services/mock_exam_service.dart';
import '../../services/auth_service.dart';

class MockExamCard extends StatefulWidget {
  final MockExam mockExam;

  const MockExamCard({super.key, required this.mockExam});

  @override
  State<MockExamCard> createState() => _MockExamCardState();
}

class _MockExamCardState extends State<MockExamCard> {
  MockExamResult? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResultSilently();
  }

  @override
  void didUpdateWidget(MockExamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mockExam != widget.mockExam) {
      _loadResultSilently();
    }
  }

  Future<void> _loadResultSilently() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;

      final results = await MockExamService.getResults(userId.toHexString());
      final result = results
          .where((r) =>
              r.examType == widget.mockExam.examType &&
              r.publisher == widget.mockExam.publisher &&
              r.date.year == widget.mockExam.date.year &&
              r.date.month == widget.mockExam.date.month &&
              r.date.day == widget.mockExam.date.day)
          .firstOrNull;

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Sonuç yüklenirken hata: $e');
      if (mounted) {
        _isLoading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.mockExam.isCompleted;
    final hasResults = _result != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? hasResults
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3)
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
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.mockExam.publisher,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showDeleteDialog(context),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.withOpacity(0.7),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? hasResults
                          ? Colors.green.withOpacity(0.15)
                          : Colors.blue.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted
                      ? hasResults
                          ? 'Tamamlandı'
                          : 'Sonuç Bekleniyor'
                      : 'Bekliyor',
                  style: TextStyle(
                    color: isCompleted
                        ? hasResults
                            ? Colors.green
                            : Colors.blue
                        : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (hasResults) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_result!.results.values.fold<int>(0, (sum, r) => sum + r.correctAnswers)} Doğru',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '${_result!.results.values.fold<int>(0, (sum, r) => sum + r.wrongAnswers)} Yanlış',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_result!.totalNet.toStringAsFixed(2)} Net',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _result!.totalNet / 120,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: _getProgressColor(_result!.totalNet / 120),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252837),
        title: const Text(
          'Denemeyi Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu denemeyi silmek istediğinizden emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      final weeklyPlanProvider = Provider.of<WeeklyPlanProvider>(
        context,
        listen: false,
      );

      try {
        // Denemeyi sil
        await weeklyPlanProvider.deletePlanItem(
          _getDayName(widget.mockExam.date.weekday),
          widget.mockExam.toDailyPlanItem(),
        );

        // Başarılı silme mesajı göster
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deneme başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Hata mesajı göster
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deneme silinirken bir hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return '';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return Colors.green;
    } else if (progress >= 0.6) {
      return Colors.blue;
    } else if (progress >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
