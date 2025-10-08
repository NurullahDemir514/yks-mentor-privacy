import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../constants/theme.dart';
import '../constants/exam_subjects.dart';
import '../constants/exam_type.dart';

class TimerWidget extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onTap;

  const TimerWidget({
    super.key,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF252837),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Süre Göstergesi
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  provider.formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Başlat/Durdur/Devam Et Butonu
              IconButton(
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                icon: Icon(
                  provider.isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (provider.selectedSubject == null) {
                    _showTimerDialog(context);
                    return;
                  }

                  if (provider.isRunning) {
                    provider.pauseTimer();
                  } else {
                    if (provider.selectedSubject != null) {
                      provider.resumeTimer();
                    }
                  }
                },
              ),

              // Sıfırla Butonu
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: () => provider.resetTimer(),
              ),

              // Ayarlar Butonu
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showTimerDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1D2B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252837),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Zamanlayıcı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Ders Seçimi
                    Consumer<TimerProvider>(
                      builder: (context, provider, _) => Theme(
                        data: Theme.of(context).copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: const Color(0xFF252837),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: provider.selectedSubject,
                          decoration: const InputDecoration(
                            labelText: 'Ders',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          dropdownColor: const Color(0xFF252837),
                          style: const TextStyle(color: Colors.white),
                          items: ExamSubjects.subjects[ExamType.TYT]!.keys
                              .map((subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              provider.selectSubject(value);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Konu Seçimi
                    Consumer<TimerProvider>(
                      builder: (context, provider, _) {
                        final topics = provider.selectedSubject != null
                            ? ExamSubjects.subjects[ExamType.TYT]![
                                provider.selectedSubject]!
                            : <String>[];

                        return Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: InputDecorationTheme(
                              filled: true,
                              fillColor: const Color(0xFF252837),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: provider.selectedTopic,
                            decoration: const InputDecoration(
                              labelText: 'Konu',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            dropdownColor: const Color(0xFF252837),
                            style: const TextStyle(color: Colors.white),
                            items: topics
                                .map((topic) => DropdownMenuItem(
                                      value: topic,
                                      child: Text(topic),
                                    ))
                                .toList(),
                            onChanged: provider.selectedSubject != null
                                ? (value) {
                                    if (value != null) {
                                      provider.selectTopic(value);
                                    }
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Alt Butonlar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252837),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    Consumer<TimerProvider>(
                      builder: (context, provider, _) => FilledButton(
                        onPressed: provider.selectedSubject != null &&
                                provider.selectedTopic != null
                            ? () {
                                Navigator.pop(context);
                                if (!provider.isRunning) {
                                  provider.startTimer();
                                }
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                        child: const Text('Başlat'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
