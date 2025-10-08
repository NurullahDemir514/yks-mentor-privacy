import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../providers/question_tracking_provider.dart';
import '../providers/weekly_plan_provider.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/weekly_plan.dart';
import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';
import '../providers/timer_provider.dart';
import '../services/statistics_service.dart';
import '../widgets/home/welcome_card.dart';
import '../widgets/home/daily_stats_card.dart';
import '../widgets/home/home_content.dart';
import '../widgets/home/home_error.dart';
import '../widgets/home/home_loading.dart';
import 'dart:async';
import '../services/mock_exam_service.dart';
import '../models/mock_exam.dart';
import '../widgets/home/home_mock_exam_card.dart';
import 'package:confetti/confetti.dart';
import '../models/question_tracking.dart';
import '../widgets/home/task_completion_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  late final StatisticsService _statisticsService;
  bool _isStatisticsServiceInitialized = false;
  String? _error;
  bool _isLoading = false;
  late ConfettiController _confettiController;
  bool _isMarkingCompleted = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdService.instance.createBannerAd()..load();
    _initializeData();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final weeklyPlanProvider =
          Provider.of<WeeklyPlanProvider>(context, listen: false);
      final questionTrackingProvider =
          Provider.of<QuestionTrackingProvider>(context, listen: false);

      if (!_isStatisticsServiceInitialized) {
        _statisticsService = StatisticsService(
          questionTrackingProvider,
          weeklyPlanProvider,
        );
        _isStatisticsServiceInitialized = true;
      }

      await weeklyPlanProvider.loadPlanForWeek(DateTime.now());

      if (weeklyPlanProvider.selectedWeekPlan != null) {
        await questionTrackingProvider.loadData();
      }

      if (mounted) {
        setState(() {
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Veri yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF171923),
                  const Color(0xFF0F1117),
                  const Color(0xFF0A0C10),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _buildMainContent(),
                ),
                if (_bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),

          // Konfeti efekti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              maxBlastForce: 5,
              minBlastForce: 2,
              displayTarget: false,
            ),
          ),

          // İşlem sırasında kilitlenme katmanı
          if (_isMarkingCompleted)
            Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        if (_error != null)
          HomeError(
            error: _error!,
            onRetry: _initializeData,
          )
        else if (_isLoading)
          const HomeLoading()
        else
          _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    return Consumer2<WeeklyPlanProvider, QuestionTrackingProvider>(
      builder: (context, weeklyPlanProvider, questionTrackingProvider, _) {
        final currentPlan = weeklyPlanProvider.selectedWeekPlan;
        if (currentPlan == null) {
          return const Center(
            child: Text('Haftalık plan bulunamadı'),
          );
        }

        final today = DateTime.now();
        final dayName = _getDayName(today.weekday);
        final plans = currentPlan.dailyPlans[dayName] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context),
              const SizedBox(height: 16),
              _buildDailyStats(plans, questionTrackingProvider),
              const SizedBox(height: 16),
              _buildTodayPlanList(context, plans, questionTrackingProvider),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final now = DateTime.now();
    String greeting;
    String motivation;

    // Kullanıcı adını düzenle
    String userName = 'Dostum';
    if (user?.name != null) {
      final nameParts = user!.name.split(' ');
      if (nameParts.isNotEmpty) {
        userName = nameParts[0][0].toUpperCase() +
            nameParts[0].substring(1).toLowerCase();
      }
    }

    // Rastgele motivasyon mesajları
    final morningMessages = [
      'Güne güzel bir kahvaltıyla başladın mı? Şimdi çalışma zamanı! 🍳',
      'Erken kalkan yol alır, hadi başlayalım! ⭐️',
      'Bugün harika şeyler başaracaksın, hissediyorum! 💪',
      'Sabah sabah enerjin yüksek, tam çalışma vakti! ✨',
      'Yeni bir gün, yeni hedefler. Hadi denemeleri parçalayalım! 📚',
    ];

    final afternoonMessages = [
      'Öğle yemeğinden sonra biraz tembellik normal, ama hadi kendimize gelelim! 🔋',
      'Şu an tam konsantrasyon vakti, telefonu uzağa koyup başlayalım! 📱',
      'Günün en verimli saatlerindeyiz, değerlendirelim! 📈',
      'Biraz mola verdiysen, şimdi tam gaz devam! 🚀',
      'Yorgunluk mu? Yok öyle bir şey, devam devam! 💪',
    ];

    final eveningMessages = [
      'Akşam çalışması bir başka güzel! Hadi biraz daha! 🌙',
      'Son birkaç konu kaldı, tamamlayalım mı? 📝',
      "Netflix'i sonraya bırak, şimdi soru çözme vakti! 🎯",
      'Bugünün hedeflerine az kaldı, tamamlayalım! ⭐️',
      'Yoruldun biliyorum ama biraz daha gayret! 💫',
    ];

    final nightMessages = [
      'Gece kuşları için ideal çalışma vakti! 🦉',
      'Sessizlik, huzur ve matematik! Harika üçlü! 🎯',
      'Bu saatte çalışıyorsan gerçekten kararlısın! 💪',
      'Geç olsun güç olmasın! Hadi biraz daha! 🌙',
      'Son tekrarlar en akılda kalıcı olur! 📚',
    ];

    final sleepMessages = [
      'Yarın yeni bir gün, dinlenmeyi unutma! 😴',
      'İyi bir uyku, yarınki başarının anahtarı! 🌙',
      'Bugün yeterince çalıştın, şimdi dinlenme vakti! ⭐️',
      'Beynin de senin gibi dinlenmeyi hak ediyor! 💤',
      'Yarın yeni hedeflerle buluşmak üzere! 🌟',
    ];

    // Saate göre rastgele mesaj seç
    if (now.hour < 12) {
      greeting = 'Günaydın';
      motivation = morningMessages[now.minute % morningMessages.length];
    } else if (now.hour < 15) {
      greeting = 'Merhaba';
      motivation = afternoonMessages[now.minute % afternoonMessages.length];
    } else if (now.hour < 18) {
      greeting = 'İyi günler';
      motivation = afternoonMessages[now.minute % afternoonMessages.length];
    } else if (now.hour < 22) {
      greeting = 'İyi akşamlar';
      motivation = eveningMessages[now.minute % eveningMessages.length];
    } else if (now.hour < 03) {
      greeting = 'İyi geceler';
      motivation = nightMessages[now.minute % nightMessages.length];
    } else {
      greeting = 'İyi geceler';
      motivation = sleepMessages[now.minute % sleepMessages.length];
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '$greeting, ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      TextSpan(
                        text: userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motivation,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPlanList(
    BuildContext context,
    List<DailyPlanItem> plans,
    QuestionTrackingProvider questionTrackingProvider,
  ) {
    if (plans.isEmpty) return const SizedBox.shrink();

    // Planları tamamlanma durumuna göre sırala
    final sortedPlans = List<DailyPlanItem>.from(plans);
    sortedPlans.sort((a, b) {
      // Önce denemeleri en üste al
      if (a.isMockExam && !b.isMockExam) return -1;
      if (!a.isMockExam && b.isMockExam) return 1;

      // Her iki öğe için tamamlanma durumunu kontrol et
      bool isACompleted = false;
      bool isBCompleted = false;

      final timerProvider = Provider.of<TimerProvider>(context, listen: false);

      final aTrackings = questionTrackingProvider.todayTrackings
          .where((tracking) =>
              tracking.subject == a.subject &&
              tracking.topic == a.topic &&
              tracking.date.year == DateTime.now().year &&
              tracking.date.month == DateTime.now().month &&
              tracking.date.day == DateTime.now().day)
          .toList();
      final aSolved =
          aTrackings.fold<int>(0, (sum, t) => sum + t.totalQuestions);
      isACompleted = aSolved >= a.targetQuestions;

      final bTrackings = questionTrackingProvider.todayTrackings
          .where((tracking) =>
              tracking.subject == b.subject &&
              tracking.topic == b.topic &&
              tracking.date.year == DateTime.now().year &&
              tracking.date.month == DateTime.now().month &&
              tracking.date.day == DateTime.now().day)
          .toList();
      final bSolved =
          bTrackings.fold<int>(0, (sum, t) => sum + t.totalQuestions);
      isBCompleted = bSolved >= b.targetQuestions;

      // Tamamlananları sona at
      if (isACompleted && !isBCompleted) return 1;
      if (!isACompleted && isBCompleted) return -1;

      // İkisi de tamamlanmış veya tamamlanmamışsa sıralamayı koru
      return 0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Günün Planı',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedPlans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= sortedPlans.length) return const SizedBox.shrink();
            final plan = sortedPlans[index];

            // Eğer deneme ise farklı bir kart göster
            if (plan.isMockExam) {
              final mockExam = MockExam.fromPlanItem(plan);
              return HomeMockExamCard(mockExam: mockExam);
            }

            final todayTrackings = questionTrackingProvider.todayTrackings;

            // Bu plan için toplam çözülen soruları hesapla
            final planTrackings = todayTrackings
                .where((tracking) =>
                    tracking.subject == plan.subject &&
                    tracking.topic == plan.topic &&
                    tracking.date.year == DateTime.now().year &&
                    tracking.date.month == DateTime.now().month &&
                    tracking.date.day == DateTime.now().day)
                .toList();

            final solved =
                planTrackings.fold<int>(0, (sum, t) => sum + t.totalQuestions);

            // İlerleme yüzdesi ve tamamlanma durumu
            final progress = solved / plan.targetQuestions;
            final isCompleted = plan.isCompleted || progress >= 1.0;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF252837),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tamamlandı olarak işaretleme düğmesi - Sola yerleştirildi
                      if (!isCompleted &&
                          !(Provider.of<TimerProvider>(context).isRunning &&
                              Provider.of<TimerProvider>(context)
                                      .selectedSubject ==
                                  plan.subject &&
                              Provider.of<TimerProvider>(context)
                                      .selectedTopic ==
                                  plan.topic))
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Tooltip(
                            message: 'Tamamlandı olarak işaretle',
                            child: TextButton.icon(
                              onPressed: _isMarkingCompleted
                                  ? null
                                  : () async {
                                      if (_isMarkingCompleted) return;

                                      // TaskCompletionModal'ı kullanarak sonuç al
                                      final result =
                                          await TaskCompletionModal.show(
                                              context, plan);

                                      if (result != null) {
                                        setState(() {
                                          _isMarkingCompleted = true;
                                        });

                                        // Yükleme göstergesi
                                        final loadingOverlay = OverlayEntry(
                                          builder: (context) => Container(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        );

                                        // Yükleme göstergesini ekle
                                        Overlay.of(context)
                                            .insert(loadingOverlay);

                                        try {
                                          final weeklyPlanProvider =
                                              Provider.of<WeeklyPlanProvider>(
                                                  context,
                                                  listen: false);

                                          // Günün adını al
                                          final today = _getDayName(
                                              DateTime.now().weekday);

                                          // Planı güncelle
                                          final currentPlan = weeklyPlanProvider
                                              .selectedWeekPlan;
                                          if (currentPlan != null) {
                                            final dailyPlans = Map<String,
                                                    List<DailyPlanItem>>.from(
                                                currentPlan.dailyPlans);
                                            final todayPlans =
                                                List<DailyPlanItem>.from(
                                                    dailyPlans[today] ?? []);

                                            final planIndex =
                                                todayPlans.indexWhere((item) =>
                                                    item.subject ==
                                                        plan.subject &&
                                                    item.topic == plan.topic);

                                            if (planIndex != -1) {
                                              // Soru sayısını ve süreyi güncelle
                                              final questionCount =
                                                  result['questionCount']
                                                      as int;
                                              final duration =
                                                  result['duration'] as int?;

                                              todayPlans[planIndex] =
                                                  todayPlans[planIndex]
                                                      .copyWith(
                                                isCompleted: true,
                                                targetQuestions: questionCount,
                                                duration: duration ??
                                                    todayPlans[planIndex]
                                                        .duration,
                                              );
                                              dailyPlans[today] = todayPlans;

                                              final updatedPlan =
                                                  currentPlan.copyWith(
                                                      dailyPlans: dailyPlans);
                                              await weeklyPlanProvider
                                                  .updateWeeklyPlan(
                                                      updatedPlan);

                                              // Soru takibi için veri ekle
                                              if (questionCount > 0) {
                                                final questionTrackingProvider =
                                                    Provider.of<
                                                        QuestionTrackingProvider>(
                                                  context,
                                                  listen: false,
                                                );

                                                final correctAnswers =
                                                    result['correctAnswers']
                                                            as int? ??
                                                        0;
                                                final wrongAnswers =
                                                    result['wrongAnswers']
                                                            as int? ??
                                                        0;
                                                final emptyAnswers =
                                                    result['emptyAnswers']
                                                            as int? ??
                                                        0;
                                                final duration =
                                                    result['duration'] as int?;

                                                // Soru takibi ekle
                                                await questionTrackingProvider
                                                    .addTracking(
                                                  QuestionTracking(
                                                    userId: AuthService.instance
                                                        .currentUser!.id
                                                        .toHexString(),
                                                    subject: plan.subject,
                                                    topic: plan.topic,
                                                    totalQuestions:
                                                        questionCount,
                                                    correctAnswers:
                                                        correctAnswers,
                                                    wrongAnswers: wrongAnswers,
                                                    emptyAnswers: emptyAnswers,
                                                    date: DateTime.now(),
                                                    duration: duration,
                                                  ),
                                                );

                                                // Süre bilgisi varsa, zamanlayıcı sağlayıcısına da ekle
                                                if (duration != null &&
                                                    duration > 0) {
                                                  final timerProvider = Provider
                                                      .of<TimerProvider>(
                                                    context,
                                                    listen: false,
                                                  );

                                                  // Manuel olarak süre ekle
                                                  timerProvider
                                                      .addManualDuration(
                                                    plan.subject,
                                                    plan.topic,
                                                    Duration(minutes: duration),
                                                  );
                                                }
                                              }

                                              // Yükleme göstergesini kaldır
                                              loadingOverlay.remove();

                                              // Zamanlayıcı çalışıyorsa ve bu öğe için çalışıyorsa durdur
                                              final timerProvider =
                                                  Provider.of<TimerProvider>(
                                                context,
                                                listen: false,
                                              );

                                              if (timerProvider.isRunning &&
                                                  timerProvider
                                                          .selectedSubject ==
                                                      plan.subject &&
                                                  timerProvider.selectedTopic ==
                                                      plan.topic) {
                                                timerProvider.resetTimer();
                                              }

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${plan.subject} - ${plan.topic} tamamlandı olarak işaretlendi'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              // Konfeti efektini oynat
                                              _confettiController.play();

                                              setState(() {
                                                _isMarkingCompleted = false;
                                              });
                                            }
                                          }
                                        } catch (e) {
                                          // Yükleme göstergesini kaldır
                                          loadingOverlay.remove();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Hata oluştu: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );

                                          setState(() {
                                            _isMarkingCompleted = false;
                                          });
                                        }
                                      }
                                    },
                              icon: Icon(
                                Icons.check_box_outline_blank,
                                size: 16,
                                color: _isMarkingCompleted
                                    ? Colors.grey
                                    : Colors.white.withOpacity(0.7),
                              ),
                              label: Text(
                                'Tamamla',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isMarkingCompleted
                                      ? Colors.grey
                                      : Colors.white.withOpacity(0.7),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ),
                      if (isCompleted)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_box,
                                size: 16,
                                color: Colors.green.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tamamlandı',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: plan.isMockExam
                              ? Colors.orange.withOpacity(0.15)
                              : isCompleted
                                  ? Colors.green.withOpacity(0.15)
                                  : AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              plan.subject,
                              style: TextStyle(
                                color: plan.isMockExam
                                    ? Colors.orange
                                    : isCompleted
                                        ? Colors.green
                                        : AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            if (isCompleted)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                plan.topic,
                                style: TextStyle(
                                  color: isCompleted
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Başlat düğmesi - Tamamlanmış görevlerde gösterilmeyecek
                      if (!isCompleted)
                        FilledButton.icon(
                          onPressed: _isMarkingCompleted
                              ? null
                              : () {
                                  final timerProvider =
                                      Provider.of<TimerProvider>(context,
                                          listen: false);
                                  // Eğer bu ders için zamanlayıcı zaten çalışıyorsa zamanlayıcı sayfasına git
                                  if (timerProvider.isRunning &&
                                      timerProvider.selectedSubject ==
                                          plan.subject &&
                                      timerProvider.selectedTopic ==
                                          plan.topic) {
                                    AppScaffold.of(context)?.changePage(4);
                                    return;
                                  }
                                  // Zamanlayıcı çalışmıyorsa veya başka bir ders için çalışıyorsa yeni zamanlayıcı başlat
                                  timerProvider.startSubjectTimer(
                                    plan.subject,
                                    topic: plan.topic,
                                  );
                                },
                          icon: Icon(
                            Provider.of<TimerProvider>(context).isRunning &&
                                    Provider.of<TimerProvider>(context)
                                            .selectedSubject ==
                                        plan.subject &&
                                    Provider.of<TimerProvider>(context)
                                            .selectedTopic ==
                                        plan.topic
                                ? Icons.timer
                                : solved > 0
                                    ? Icons.play_arrow_rounded
                                    : Icons.play_arrow,
                            size: 14,
                          ),
                          label: Text(
                            Provider.of<TimerProvider>(context).isRunning &&
                                    Provider.of<TimerProvider>(context)
                                            .selectedSubject ==
                                        plan.subject &&
                                    Provider.of<TimerProvider>(context)
                                            .selectedTopic ==
                                        plan.topic
                                ? Provider.of<TimerProvider>(context)
                                    .formattedTime
                                : solved > 0
                                    ? 'Devam Et'
                                    : 'Başla',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _isMarkingCompleted
                                ? Colors.grey.withOpacity(0.1)
                                : Provider.of<TimerProvider>(context)
                                            .isRunning &&
                                        Provider.of<TimerProvider>(context)
                                                .selectedSubject ==
                                            plan.subject &&
                                        Provider.of<TimerProvider>(context)
                                                .selectedTopic ==
                                            plan.topic
                                    ? AppTheme.primary.withOpacity(0.15)
                                    : solved > 0
                                        ? AppTheme.primary.withOpacity(0.15)
                                        : Colors.white.withOpacity(0.1),
                            foregroundColor: _isMarkingCompleted
                                ? Colors.grey
                                : Provider.of<TimerProvider>(context)
                                            .isRunning &&
                                        Provider.of<TimerProvider>(context)
                                                .selectedSubject ==
                                            plan.subject &&
                                        Provider.of<TimerProvider>(context)
                                                .selectedTopic ==
                                            plan.topic
                                    ? Colors.white
                                    : solved > 0
                                        ? AppTheme.primary
                                        : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: _isMarkingCompleted
                                    ? Colors.grey.withOpacity(0.3)
                                    : Provider.of<TimerProvider>(context)
                                                .isRunning &&
                                            Provider.of<TimerProvider>(context)
                                                    .selectedSubject ==
                                                plan.subject &&
                                            Provider.of<TimerProvider>(context)
                                                    .selectedTopic ==
                                                plan.topic
                                        ? AppTheme.primary
                                        : solved > 0
                                            ? AppTheme.primary.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.1)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$solved/${plan.targetQuestions} Soru',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.green.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (progress >= 1.0) ...[
                          const SizedBox(width: 6),
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
                              '${Provider.of<TimerProvider>(context).getTotalDurationForTopic(plan.subject, plan.topic).inMinutes} dk',
                              style: TextStyle(
                                color: Colors.green.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 12,
                                  color: Colors.green.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tamamlandı',
                                  style: TextStyle(
                                    color: Colors.green.withOpacity(0.9),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  _getProgressColor(progress).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '%${(progress * 100).toInt()}',
                              style: TextStyle(
                                color: _getProgressColor(progress),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: isCompleted
                          ? Colors.green
                          : _getProgressColor(progress),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bugün için plan yok',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir haftalık plan oluşturarak çalışmaya başlayabilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              // Haftalık plan sayfasına git (index: 1)
              AppScaffold.of(context)?.changePage(1);
            },
            icon: const Icon(
              Icons.add_rounded,
              size: 18,
            ),
            label: const Text('Plan Oluştur'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(
    List<DailyPlanItem> plans,
    QuestionTrackingProvider questionTrackingProvider,
  ) {
    // Deneme olmayan planları filtrele
    final regularPlans = plans.where((plan) => !plan.isMockExam).toList();

    // Toplam soru hedefi ve çözülen soru sayısını hesapla
    final totalTargetQuestions = regularPlans.fold<int>(
      0,
      (sum, plan) => sum + plan.targetQuestions,
    );

    final totalSolvedQuestions =
        questionTrackingProvider.todayTrackings.where((tracking) {
      // Deneme sınavlarına ait kayıtları filtrele
      return regularPlans.any((plan) =>
          tracking.subject == plan.subject && tracking.topic == plan.topic);
    }).fold<int>(0, (sum, tracking) => sum + tracking.totalQuestions);

    // Tamamlanan görev sayısını hesapla
    final completedTasks = regularPlans.where((plan) {
      final planTrackings = questionTrackingProvider.todayTrackings
          .where((tracking) =>
              tracking.subject == plan.subject &&
              tracking.topic == plan.topic &&
              tracking.date.year == DateTime.now().year &&
              tracking.date.month == DateTime.now().month &&
              tracking.date.day == DateTime.now().day)
          .toList();

      final solved =
          planTrackings.fold<int>(0, (sum, t) => sum + t.totalQuestions);

      return solved >= plan.targetQuestions;
    }).length;

    // Genel ilerleme yüzdesi
    final overallProgress = totalTargetQuestions > 0
        ? (totalSolvedQuestions / totalTargetQuestions * 100).toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.15),
            const Color(0xFF252837),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalSolvedQuestions/$totalTargetQuestions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Çözülen Soru',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedTasks/${regularPlans.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tamamlanan Görev',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(overallProgress / 100),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Günlük İlerleme: %$overallProgress',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
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

  Color _getProgressColor(double progress) {
    if (progress >= 1) {
      return Colors.green;
    } else if (progress >= 0.7) {
      return Colors.blue;
    } else if (progress >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
