import 'package:flutter/material.dart';
import '../models/weekly_plan.dart';
import '../providers/question_tracking_provider.dart';
import '../models/question_tracking.dart';
import '../providers/weekly_plan_provider.dart';

// İstatistik hesaplama için soyut sınıf
abstract class IStatisticsService {
  Future<DailyStats> getDailyStats(DateTime date);
  Future<WeeklyStats> getWeeklyStats();
  Future<String> getMotivationalMessage(DailyStats stats);
  List<DailyPlanItem> sortPlansByCompletion(List<DailyPlanItem> plans);
}

// İstatistik modeli
class DailyStats {
  final int solvedQuestions;
  final int targetQuestions;
  final int completedTasks;
  final int totalTasks;
  final double progress;
  final int? yesterdaySolvedQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final List<TimeOfDay> productiveHours;
  final List<String> todaysTopics;

  DailyStats({
    required this.solvedQuestions,
    required this.targetQuestions,
    required this.completedTasks,
    required this.totalTasks,
    required this.progress,
    this.yesterdaySolvedQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.productiveHours,
    required this.todaysTopics,
  });
}

class WeeklyStats {
  final int weeklyTargetQuestions;
  final int weeklySolvedQuestions;
  final double weeklyProgress;

  WeeklyStats({
    required this.weeklyTargetQuestions,
    required this.weeklySolvedQuestions,
    required this.weeklyProgress,
  });
}

// Servis implementasyonu
class StatisticsService implements IStatisticsService {
  final QuestionTrackingProvider _trackingProvider;
  final WeeklyPlanProvider _weeklyPlanProvider;

  StatisticsService(this._trackingProvider, this._weeklyPlanProvider);

  @override
  Future<DailyStats> getDailyStats(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final currentPlan = _weeklyPlanProvider.selectedWeekPlan;
    final today = _getDayName(date.weekday);
    final yesterday =
        _getDayName(date.subtract(const Duration(days: 1)).weekday);

    // Aktif planları al
    final todayPlans = currentPlan?.dailyPlans[today]
            ?.where((plan) => !plan.isDeleted)
            .toList() ??
        [];
    final yesterdayPlans = currentPlan?.dailyPlans[yesterday]
            ?.where((plan) => !plan.isDeleted)
            .toList() ??
        [];

    final activePlanKeys =
        todayPlans.map((p) => '${p.subject}_${p.topic}').toSet();
    final activeYesterdayPlanKeys =
        yesterdayPlans.map((p) => '${p.subject}_${p.topic}').toSet();

    // Deneme hariç ve aktif planlara ait tracking'ler
    final todayTrackings = _trackingProvider.todayTrackings.where((t) {
      final key = '${t.subject}_${t.topic}';
      return !t.isMockExam && activePlanKeys.contains(key);
    });

    final yesterdayTrackings = (await _trackingProvider
            .getTrackingsForDate(date.subtract(const Duration(days: 1))))
        .where((t) {
      final key = '${t.subject}_${t.topic}';
      return !t.isMockExam && activeYesterdayPlanKeys.contains(key);
    });

    int solvedQuestions = 0;
    int correctAnswers = 0;
    int wrongAnswers = 0;
    int emptyAnswers = 0;
    int yesterdaySolvedQuestions = 0;

    for (var tracking in todayTrackings) {
      solvedQuestions += tracking.totalQuestions;
      correctAnswers += tracking.correctAnswers;
      wrongAnswers += tracking.wrongAnswers;
      emptyAnswers += tracking.emptyAnswers;
    }

    for (var tracking in yesterdayTrackings) {
      yesterdaySolvedQuestions += tracking.totalQuestions;
    }

    int targetQuestions = 0;
    int completedTasks = 0;

    // Deneme hariç planlar (soru hedefi için)
    final nonMockPlans = todayPlans.where((plan) => !plan.isMockExam).toList();

    // Soru hedefi için sadece konu çalışmalarını topla
    for (var plan in nonMockPlans) {
      targetQuestions += plan.targetQuestions;
    }

    // Tamamlanan görevler için tüm planları kontrol et
    for (var plan in todayPlans) {
      if (plan.isCompleted) completedTasks++;
    }

    // İlerleme yüzdesi (deneme hariç)
    final progress =
        targetQuestions > 0 ? solvedQuestions / targetQuestions : 0.0;

    return DailyStats(
      solvedQuestions: solvedQuestions,
      targetQuestions: targetQuestions,
      completedTasks: completedTasks,
      totalTasks: todayPlans.length, // Tüm görevlerin sayısı
      progress: progress,
      yesterdaySolvedQuestions:
          yesterdaySolvedQuestions > 0 ? yesterdaySolvedQuestions : null,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      emptyAnswers: emptyAnswers,
      productiveHours: const [],
      todaysTopics: todayPlans.map((p) => p.topic).toList(),
    );
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

  List<TimeOfDay> _calculateProductiveHours(List<QuestionTracking> trackings) {
    // Saat başına çözülen soru sayısını hesapla
    final hourlyQuestions = <int, int>{};
    for (final tracking in trackings) {
      final hour = tracking.date.hour;
      hourlyQuestions[hour] =
          (hourlyQuestions[hour] ?? 0) + tracking.totalQuestions;
    }

    // En verimli 3 saati bul
    final sortedHours = hourlyQuestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours
        .take(3)
        .map((e) => TimeOfDay(hour: e.key, minute: 0))
        .toList();
  }

  @override
  Future<WeeklyStats> getWeeklyStats() async {
    final currentPlan = _weeklyPlanProvider.selectedWeekPlan;
    if (currentPlan == null) {
      return WeeklyStats(
        weeklyTargetQuestions: 0,
        weeklySolvedQuestions: 0,
        weeklyProgress: 0,
      );
    }

    // Haftalık aktif planları topla
    Map<String, Set<String>> activePlansByDay = {};
    for (var entry in currentPlan.dailyPlans.entries) {
      final activePlans =
          entry.value.where((plan) => !plan.isDeleted && !plan.isMockExam);
      activePlansByDay[entry.key] =
          activePlans.map((p) => '${p.subject}_${p.topic}').toSet();
    }

    // Haftalık toplam hedef soru sayısı (deneme hariç)
    int weeklyTarget = 0;
    for (var dayPlans in currentPlan.dailyPlans.values) {
      weeklyTarget += dayPlans
          .where((plan) => !plan.isMockExam && !plan.isDeleted)
          .fold(0, (sum, plan) => sum + plan.targetQuestions);
    }

    // Bu haftanın başlangıç ve bitiş tarihleri
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Bu hafta çözülen toplam soru sayısı (deneme hariç)
    int weeklySolved = 0;
    for (var day = startOfWeek;
        day.isBefore(endOfWeek);
        day = day.add(const Duration(days: 1))) {
      final dayName = _getDayName(day.weekday);
      final activePlanKeys = activePlansByDay[dayName] ?? {};

      final dayTrackings = await _trackingProvider.getTrackingsForDate(day);

      // Her gün için konu bazlı toplam (sadece aktif planlar için)
      for (var tracking in dayTrackings.where((t) => !t.isMockExam)) {
        final key = '${tracking.subject}_${tracking.topic}';
        if (activePlanKeys.contains(key)) {
          weeklySolved += tracking.totalQuestions;
        }
      }
    }

    return WeeklyStats(
      weeklyTargetQuestions: weeklyTarget,
      weeklySolvedQuestions: weeklySolved,
      weeklyProgress: weeklyTarget > 0 ? weeklySolved / weeklyTarget : 0,
    );
  }

  @override
  Future<String> getMotivationalMessage(DailyStats stats) async {
    final List<String> messages = [];

    if (stats.solvedQuestions > 0) {
      final correctPercentage =
          (stats.correctAnswers / stats.solvedQuestions * 100).toInt();

      // Başarı durumuna göre mesajlar
      if (correctPercentage >= 80) {
        messages.add(
            'Harika! %$correctPercentage başarı oranıyla kendini aşıyorsun.');
      } else if (correctPercentage >= 60) {
        messages.add(
            'İyi gidiyorsun, %$correctPercentage başarı oranını yükseltmeye devam.');
      } else {
        messages.add('Her soru yeni bir öğrenme fırsatı. Vazgeçmeden devam!');
      }

      // Çözülen soru sayısına göre ekstra motivasyon
      if (stats.solvedQuestions >= 50) {
        messages.add(
            'Bugün kendini aşıyorsun! ${stats.solvedQuestions} soru çözdün.');
      } else if (stats.solvedQuestions >= 30) {
        messages.add('Temponu korumaya devam et, başarı senin ellerinde.');
      }

      // Dünle karşılaştırma
      if (stats.yesterdaySolvedQuestions != null &&
          stats.yesterdaySolvedQuestions! > 0) {
        final difference =
            stats.solvedQuestions - stats.yesterdaySolvedQuestions!;
        if (difference > 10) {
          messages.add('Dünden çok daha iyisin, bu motivasyonla devam!');
        }
      }

      // Boş sorular için yapıcı öneri
      if (stats.emptyAnswers > stats.solvedQuestions * 0.3) {
        messages.add(
            'Emin olmadığın sorularda da şansını dene, her tahmin yeni bir öğrenme.');
      }
    } else {
      // Günün saatine göre başlangıç mesajları
      final hour = DateTime.now().hour;
      if (hour < 12) {
        messages.add('Güne başlarken kendine bir hedef koy ve ona odaklan.');
      } else if (hour < 17) {
        messages.add(
            'Hala önünde harika fırsatlar var, başlamak için hiçbir zaman geç değil.');
      } else {
        messages.add('Günü verimli bitirmek için hala zamanın var.');
      }
    }

    // En etkili mesajı seç
    return messages.isNotEmpty
        ? messages.first
        : 'Yeni başarılara hazır mısın?';
  }

  @override
  List<DailyPlanItem> sortPlansByCompletion(List<DailyPlanItem> plans) {
    // Tamamlanan görevleri sona al
    return [...plans]..sort((a, b) {
        final aCompleted = _isTaskCompleted(a);
        final bCompleted = _isTaskCompleted(b);

        if (aCompleted == bCompleted) {
          // İkisi de tamamlanmış veya tamamlanmamışsa sıralamayı koru
          return 0;
        }
        // Tamamlanmamışları üste al
        return aCompleted ? 1 : -1;
      });
  }

  bool _isTaskCompleted(DailyPlanItem plan) {
    final planTrackings = _trackingProvider.todayTrackings
        .where((tracking) =>
            tracking.subject == plan.subject && tracking.topic == plan.topic)
        .toList();

    final solved =
        planTrackings.fold<int>(0, (sum, t) => sum + t.totalQuestions);

    return solved >= plan.targetQuestions;
  }
}
