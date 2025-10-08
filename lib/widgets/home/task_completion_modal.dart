import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/weekly_plan.dart';

class TaskCompletionModal extends StatefulWidget {
  final DailyPlanItem plan;
  final Function(Map<String, dynamic> result) onComplete;

  const TaskCompletionModal({
    Key? key,
    required this.plan,
    required this.onComplete,
  }) : super(key: key);

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    DailyPlanItem plan,
  ) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TaskCompletionModal(
        plan: plan,
        onComplete: (result) => Navigator.of(context).pop(result),
      ),
    );
  }

  @override
  State<TaskCompletionModal> createState() => _TaskCompletionModalState();
}

class _TaskCompletionModalState extends State<TaskCompletionModal> {
  late TextEditingController questionCountController;
  late TextEditingController durationController;
  late TextEditingController correctController;
  late TextEditingController wrongController;
  late TextEditingController emptyController;
  bool isValid = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    questionCountController =
        TextEditingController(text: '${widget.plan.targetQuestions}');
    durationController = TextEditingController();
    correctController = TextEditingController(text: '0');
    wrongController = TextEditingController(text: '0');
    emptyController =
        TextEditingController(text: '${widget.plan.targetQuestions}');
  }

  @override
  void dispose() {
    questionCountController.dispose();
    durationController.dispose();
    correctController.dispose();
    wrongController.dispose();
    emptyController.dispose();
    super.dispose();
  }

  void validateForm() {
    final totalQuestions = int.tryParse(questionCountController.text);
    final correct = int.tryParse(correctController.text);
    final wrong = int.tryParse(wrongController.text);
    final duration = int.tryParse(durationController.text);

    if (totalQuestions == null || totalQuestions <= 0) {
      errorMessage = 'Geçerli bir soru sayısı giriniz';
      isValid = false;
    } else if (correct == null || correct < 0) {
      errorMessage = 'Geçerli bir doğru sayısı giriniz';
      isValid = false;
    } else if (wrong == null || wrong < 0) {
      errorMessage = 'Geçerli bir yanlış sayısı giriniz';
      isValid = false;
    } else if (duration != null && duration < 0) {
      errorMessage = 'Geçerli bir süre giriniz';
      isValid = false;
    } else if (correct + wrong > totalQuestions) {
      errorMessage = 'Doğru ve yanlış toplamı soru sayısını aşamaz';
      isValid = false;
    } else {
      errorMessage = null;
      isValid = true;

      // Boş soruları otomatik hesapla
      final newEmpty = totalQuestions - correct - wrong;
      emptyController.text = newEmpty.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.primary.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text('Çalışmayı Tamamla'),
        ],
      ),
      backgroundColor: const Color(0xFF252837),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.plan.subject} - ${widget.plan.topic} çalışmasını tamamlandı olarak işaretlemek istiyor musunuz?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Text(
              'Soru Bilgileri',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: questionCountController,
              decoration: InputDecoration(
                labelText: 'Toplam Soru Sayısı',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(
                  Icons.tag,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
              style: const TextStyle(
                color: Colors.white,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  validateForm();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: correctController,
                    decoration: InputDecoration(
                      labelText: 'Doğru',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green.withOpacity(0.7),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        Icons.check,
                        color: Colors.green.withOpacity(0.6),
                        size: 16,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        validateForm();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: wrongController,
                    decoration: InputDecoration(
                      labelText: 'Yanlış',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.withOpacity(0.7),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        Icons.close,
                        color: Colors.red.withOpacity(0.6),
                        size: 16,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        validateForm();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emptyController,
              decoration: InputDecoration(
                labelText: 'Boş',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(
                  Icons.remove,
                  color: Colors.grey.withOpacity(0.5),
                  size: 16,
                ),
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
                hintText: 'Otomatik hesaplanır',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
              ),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
              keyboardType: TextInputType.number,
              enabled: false,
            ),
            const SizedBox(height: 16),
            const Text(
              'Süre Bilgisi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: 'Çalışma Süresi (dakika)',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
                hintText: 'Opsiyonel',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
              style: const TextStyle(
                color: Colors.white,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  validateForm();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withOpacity(0.7),
          ),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: isValid
              ? () {
                  final questionCount =
                      int.tryParse(questionCountController.text) ??
                          widget.plan.targetQuestions;
                  final duration = int.tryParse(durationController.text);
                  final correct = int.tryParse(correctController.text) ?? 0;
                  final wrong = int.tryParse(wrongController.text) ?? 0;
                  final empty = int.tryParse(emptyController.text) ?? 0;

                  widget.onComplete({
                    'questionCount': questionCount,
                    'duration': duration,
                    'correctAnswers': correct,
                    'wrongAnswers': wrong,
                    'emptyAnswers': empty,
                  });
                }
              : null,
          child: const Text('Tamamla'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.withOpacity(0.2),
            disabledForegroundColor: Colors.grey.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
