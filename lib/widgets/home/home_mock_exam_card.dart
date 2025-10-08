import 'package:flutter/material.dart';
import 'package:yks_mentor/models/mock_exam_result.dart';
import '../../models/mock_exam.dart';
import '../../providers/timer_provider.dart';
import '../../constants/exam_type.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../services/auth_service.dart';
import '../../services/mock_exam_service.dart';
import 'mock_exam_result_dialog.dart';

class HomeMockExamCard extends StatefulWidget {
  final MockExam mockExam;

  const HomeMockExamCard({super.key, required this.mockExam});

  @override
  State<HomeMockExamCard> createState() => _HomeMockExamCardState();
}

class _HomeMockExamCardState extends State<HomeMockExamCard> {
  MockExamResult? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResultSilently();
  }

  @override
  void didUpdateWidget(HomeMockExamCard oldWidget) {
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
              r.examId == widget.mockExam.examId &&
              r.examType == widget.mockExam.examType.name &&
              r.publisher == widget.mockExam.publisher)
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
    final hasValidExamId = widget.mockExam.examId != null;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCompleted
              ? hasResults
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3)
              : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _buildExamTypeString(widget.mockExam),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  widget.mockExam.publisher,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: FilledButton.icon(
                  onPressed: !hasValidExamId || hasResults
                      ? null
                      : () => _handleButtonPress(context),
                  icon: Icon(
                    isCompleted
                        ? hasResults
                            ? Icons.check_circle_rounded
                            : Icons.edit_note_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 12,
                  ),
                  label: Text(
                    !hasValidExamId
                        ? 'Geçersiz Deneme'
                        : isCompleted
                            ? hasResults
                                ? 'Tamamlandı'
                                : 'Denemeyi Ekle'
                            : 'Başla',
                    style: const TextStyle(fontSize: 10),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: isCompleted
                        ? hasResults
                            ? Colors.green.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    foregroundColor: isCompleted
                        ? hasResults
                            ? Colors.green
                            : Colors.blue
                        : Colors.orange,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: isCompleted
                            ? hasResults
                                ? Colors.green.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasResults) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${_result!.results.values.fold<int>(0, (sum, r) => sum + r.correctAnswers)}D',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${_result!.results.values.fold<int>(0, (sum, r) => sum + r.wrongAnswers)}Y',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${_result!.totalNet.toStringAsFixed(2)} Net',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _result!.totalNet / 120,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: _getProgressColor(_result!.totalNet / 120),
                      minHeight: 3,
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

  String _buildExamTypeString(MockExam exam) {
    if (exam.examType == ExamType.TYT) return 'TYT';
    if (exam.examType == ExamType.AYT && exam.aytField != null) {
      return 'AYT ${exam.aytField!.displayName}';
    }
    return exam.examType.name;
  }

  Future<void> _handleButtonPress(BuildContext context) async {
    if (widget.mockExam.examId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçersiz deneme ID\'si'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.mockExam.isCompleted) {
      // Deneme sonuçlarını girmek için modal'ı göster
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MockExamResultDialog(
          mockExam: widget.mockExam,
          duration: Provider.of<TimerProvider>(context, listen: false).duration,
          onSaved: () => _loadResultSilently(),
        ),
      );
      // Sonuçları arkaplanda yeniden yükle
      _loadResultSilently();
      return;
    }

    final timerProvider = Provider.of<TimerProvider>(
      context,
      listen: false,
    );

    // Deneme türüne göre süreyi ayarla
    final examDuration = widget.mockExam.examType == ExamType.TYT
        ? const Duration(minutes: 165)
        : const Duration(minutes: 180);

    // Deneme zamanlayıcısını başlat
    timerProvider.setMockExam(
      _buildExamTypeString(widget.mockExam),
      widget.mockExam.publisher,
      examDuration,
      widget.mockExam.examId!,
    );

    // Zamanlayıcı sayfasına git
    AppScaffold.of(context)?.changePage(3);
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
