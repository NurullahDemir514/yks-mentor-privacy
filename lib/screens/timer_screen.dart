import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weekly_plan.dart';
import '../providers/timer_provider.dart';
import '../providers/weekly_plan_provider.dart';
import '../constants/theme.dart';
import '../widgets/timer/complete_session_dialog.dart';
import '../widgets/timer/timer_container.dart';
import '../widgets/timer/empty_timer.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _TimerBody(),
        ),
      ),
    );
  }
}

class _TimerBody extends StatelessWidget {
  const _TimerBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (provider.selectedSubject != null)
                TimerContainer(
                  provider: provider,
                  onComplete: () => _showCompleteDialog(context),
                )
              else
                const Expanded(child: EmptyTimer()),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCompleteDialog(BuildContext context) async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final weeklyPlanProvider =
        Provider.of<WeeklyPlanProvider>(context, listen: false);

    // Timer'ı durdur
    if (timerProvider.isRunning) {
      timerProvider.pauseTimer();
    }

    // Eğer deneme modundaysa ve timer durdurulmuşsa direkt sıfırla
    if (timerProvider.isMockExam) {
      // Güncel planı al
      final currentPlan = weeklyPlanProvider.selectedWeekPlan;
      if (currentPlan != null) {
        final today = _getDayName(DateTime.now().weekday);
        final dailyPlans =
            Map<String, List<DailyPlanItem>>.from(currentPlan.dailyPlans);
        final todayPlans = List<DailyPlanItem>.from(dailyPlans[today] ?? []);

        // Denemeyi bul ve güncelle
        final examIndex = todayPlans.indexWhere((plan) =>
            plan.isMockExam &&
            plan.subject == timerProvider.selectedSubject &&
            plan.topic == timerProvider.mockExamPublisher);

        if (examIndex != -1) {
          // Denemeyi tamamlandı olarak işaretle
          todayPlans[examIndex] =
              todayPlans[examIndex].copyWith(isCompleted: true);
          dailyPlans[today] = todayPlans;

          // Planı güncelle
          final updatedPlan = currentPlan.copyWith(dailyPlans: dailyPlans);
          await weeklyPlanProvider.updateWeeklyPlan(updatedPlan);
        }
      }

      timerProvider.resetTimer();

      // Deneme tamamlandı mesajını göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Deneme tamamlandı! Sonuçları eklemek için deneme kartına tıklayabilirsiniz.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Normal çalışma modu için dialog göster
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteSessionDialog(
        subject: timerProvider.selectedSubject!,
        topic: timerProvider.selectedTopic!,
        duration: timerProvider.duration,
        isMockExam: timerProvider.isMockExam,
      ),
    );

    // Dialog kapandıktan sonra timer'ı sıfırla
    timerProvider.resetTimer();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Pazartesi';
      case DateTime.tuesday:
        return 'Salı';
      case DateTime.wednesday:
        return 'Çarşamba';
      case DateTime.thursday:
        return 'Perşembe';
      case DateTime.friday:
        return 'Cuma';
      case DateTime.saturday:
        return 'Cumartesi';
      case DateTime.sunday:
        return 'Pazar';
      default:
        return '';
    }
  }
}
