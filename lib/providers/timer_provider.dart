import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_session.dart';
import '../providers/weekly_plan_provider.dart';
import '../models/weekly_plan.dart';
import '../constants/exam_subjects.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/notification_service.dart';
import '../services/mongodb_service.dart';
import '../services/auth_service.dart';
import '../providers/question_tracking_provider.dart';
import '../models/question_tracking.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

class TimerProvider extends ChangeNotifier {
  final WeeklyPlanProvider _weeklyPlanProvider;

  Timer? _timer;
  Duration _duration = const Duration();
  Duration _netDuration = const Duration();
  Duration? _targetDuration;
  DateTime? _startTime;
  DateTime? _pauseTime;
  String? _selectedSubject;
  String? _selectedTopic;
  int? _solvedQuestionCount;
  bool _isRunning = false;
  bool _isLoading = false;
  String? _error;
  List<TimerSession> _sessions = [];
  bool _isMockExam = false;
  String? _mockExamPublisher;
  String? _mockExamId;

  TimerProvider(this._weeklyPlanProvider) {
    _loadSessions();
    // Bildirim callback'lerini ayarla
    NotificationService.instance.onPauseTimer = pauseTimer;
    NotificationService.instance.onResumeTimer = resumeTimer;
  }

  bool get isRunning => _isRunning;
  Duration get duration => _duration;
  Duration get netDuration => _netDuration;
  String? get selectedSubject => _selectedSubject;
  String? get selectedTopic => _selectedTopic;
  int? get solvedQuestionCount => _solvedQuestionCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TimerSession> get sessions => _sessions;
  bool get isMockExam => _isMockExam;
  String? get mockExamPublisher => _mockExamPublisher;
  Duration? get targetDuration => _targetDuration;

  String get formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_duration.inHours);
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  List<DailyPlanItem> getPlannedItemsForDay() {
    final today = DateTime.now();
    final currentPlan = _weeklyPlanProvider.selectedWeekPlan;
    if (currentPlan == null) return [];

    final dayName = _getDayName(today.weekday);
    return currentPlan.dailyPlans[dayName] ?? [];
  }

  void selectSubject(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void selectTopic(String topic) {
    _selectedTopic = topic;
    notifyListeners();
  }

  void setSolvedQuestionCount(int count) {
    _solvedQuestionCount = count;
    notifyListeners();
  }

  void startTimer() {
    if (_timer != null) return;

    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration += const Duration(seconds: 1);
      notifyListeners();
    });
    _isRunning = true;
    notifyListeners();

    // Arka plan bildirimi
    NotificationService.instance.showTimerRunningNotification();
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _pauseTime = DateTime.now();
    notifyListeners();
  }

  void resumeTimer() {
    if (_timer != null) return;

    if (_pauseTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseTime!);
      _netDuration = _duration - pauseDuration;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration += const Duration(seconds: 1);
      notifyListeners();
    });
    _isRunning = true;
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _duration = const Duration();
    _netDuration = const Duration();
    _startTime = null;
    _pauseTime = null;
    _selectedSubject = null;
    _selectedTopic = null;
    _solvedQuestionCount = null;
    _isMockExam = false;
    _mockExamPublisher = null;
    _mockExamId = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSubject = null;
    _selectedTopic = null;
    _solvedQuestionCount = null;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    // Bildirimi kaldır
    NotificationService.instance.cancelTimerNotification();

    // Deneme modu kontrolü
    if (_isMockExam) {
      _isMockExam = false;
      _mockExamPublisher = null;
    }

    notifyListeners();
  }

  void setSubjectAndTopic(String subject, {String? topic}) {
    _selectedSubject = subject;
    _selectedTopic = topic;
    notifyListeners();
  }

  void startMockExam(String subject, String publisher, Duration examDuration) {
    _selectedSubject = subject;
    _mockExamPublisher = publisher;
    _isMockExam = true;
    _targetDuration = examDuration;
    _duration = Duration.zero;
    _startTime = DateTime.now();
    startTimer();
    notifyListeners();

    // Deneme bildirimi göster
    NotificationService.instance.showMockExamNotification(subject, publisher);
  }

  Future<void> completeSession(
    int solvedQuestions, {
    required int correctAnswers,
    required int wrongAnswers,
    required int emptyAnswers,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Önce QuestionTracking'i ekle
      final questionTracking = QuestionTracking(
        userId: userId.toHexString(),
        subject: _selectedSubject!,
        topic: _selectedTopic ?? 'Genel Çalışma',
        totalQuestions: solvedQuestions,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        emptyAnswers: emptyAnswers,
        date: DateTime.now(),
      );

      final questionTrackingProvider = Provider.of<QuestionTrackingProvider>(
        context,
        listen: false,
      );
      await questionTrackingProvider.addTracking(questionTracking);

      // Sonra timer session'ı ekle
      final session = TimerSession(
        subject: _selectedSubject!,
        topic: _selectedTopic ?? 'Genel Çalışma',
        startTime: _startTime!,
        endTime: DateTime.now(),
        duration: _duration,
        solvedQuestionCount: solvedQuestions,
        pauses: [],
        isPlanned: true,
        userId: userId.toHexString(),
      );

      await addSession(session);
      resetTimer();
      _error = null;
    } catch (e) {
      _error = 'Oturum kaydedilirken hata oluştu: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSession(TimerSession session) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final collection =
          MongoDBService.instance.getCollection('timer_sessions');
      final map = session.toMap();
      map['userId'] = userId.toHexString();

      await collection.insertOne(map);
      await _loadSessions();
    } catch (e) {
      _error = e.toString();
      debugPrint('Timer oturumu kaydedilirken hata: $e');
      rethrow;
    }
  }

  Future<void> _loadSessions() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final collection =
          MongoDBService.instance.getCollection('timer_sessions');
      final query = where.eq('userId', userId.toHexString());

      // Eğer deneme sınavı modundaysa ve examId varsa, sadece o denemeye ait oturumları getir
      if (_isMockExam && _mockExamId != null) {
        query.and(where.eq('examId', _mockExamId));
      }

      final results = await collection.find(query).toList();

      _sessions = results.map((doc) => TimerSession.fromMap(doc)).toList();
      _sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      _error = e.toString();
      debugPrint('Timer oturumları yüklenirken hata: $e');
    }
  }

  Duration getTotalDurationForTopic(String subject, String topic) {
    final topicSessions = _sessions.where((session) =>
        session.subject == subject &&
        session.topic == topic &&
        session.startTime.year == DateTime.now().year &&
        session.startTime.month == DateTime.now().month &&
        session.startTime.day == DateTime.now().day);

    return topicSessions.fold(
        Duration.zero, (total, session) => total + session.duration);
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

  void startSubjectTimer(
    String subject, {
    String? topic,
    bool isMockExam = false,
  }) {
    _selectedSubject = subject;
    _selectedTopic = topic;
    _isMockExam = isMockExam;
    _startTime = DateTime.now();
    _duration = Duration.zero;
    startTimer();
  }

  void setMockExamPublisher(String publisher) {
    _mockExamPublisher = publisher;
    notifyListeners();
  }

  void setStartTime(DateTime time) {
    _startTime = time;
    notifyListeners();
  }

  Future<void> completeMockExam(
    int correctAnswers,
    int wrongAnswers,
    int emptyAnswers,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      if (_selectedSubject == null) throw Exception('Deneme türü seçilmedi');
      if (_mockExamPublisher == null)
        throw Exception('Deneme yayıncısı seçilmedi');
      if (_mockExamId == null) throw Exception('Deneme ID bulunamadı');

      // QuestionTracking'i ekle
      final questionTracking = QuestionTracking(
        userId: userId.toHexString(),
        subject: _selectedSubject!,
        topic: _mockExamPublisher!,
        totalQuestions: correctAnswers + wrongAnswers + emptyAnswers,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        emptyAnswers: emptyAnswers,
        date: DateTime.now(),
      );

      final questionTrackingProvider = Provider.of<QuestionTrackingProvider>(
        context,
        listen: false,
      );
      await questionTrackingProvider.addTracking(questionTracking);

      // Timer session'ı ekle
      if (_startTime == null) throw Exception('Başlangıç zamanı bulunamadı');

      final session = TimerSession(
        subject: _selectedSubject!,
        topic: _mockExamPublisher!,
        startTime: _startTime!,
        endTime: DateTime.now(),
        duration: _duration,
        solvedQuestionCount: correctAnswers + wrongAnswers + emptyAnswers,
        pauses: [],
        isPlanned: true,
        userId: userId.toHexString(),
        examId: _mockExamId,
      );

      await addSession(session);

      // Güncel planı al ve denemeyi tamamlandı olarak işaretle
      final currentPlan = _weeklyPlanProvider.selectedWeekPlan;
      if (currentPlan != null) {
        final today = _getDayName(DateTime.now().weekday);
        final dailyPlans =
            Map<String, List<DailyPlanItem>>.from(currentPlan.dailyPlans);
        final todayPlans = List<DailyPlanItem>.from(dailyPlans[today] ?? []);

        final examIndex = todayPlans.indexWhere(
            (plan) => plan.isMockExam && plan.examId == _mockExamId);

        if (examIndex != -1) {
          todayPlans[examIndex] =
              todayPlans[examIndex].copyWith(isCompleted: true);
          dailyPlans[today] = todayPlans;
          final updatedPlan = currentPlan.copyWith(dailyPlans: dailyPlans);
          await _weeklyPlanProvider.updateWeeklyPlan(updatedPlan);
        }
      }

      resetTimer();
      _error = null;
    } catch (e) {
      _error = 'Deneme sonuçları kaydedilirken hata oluştu: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMockExam(
      String subject, String publisher, Duration examDuration, String examId) {
    _selectedSubject = subject;
    _mockExamPublisher = publisher;
    _mockExamId = examId;
    _isMockExam = true;
    _targetDuration = examDuration;
    _duration = Duration.zero;
    _startTime = DateTime.now();
    notifyListeners();

    // Deneme bildirimi göster
    NotificationService.instance.showMockExamNotification(subject, publisher);
  }

  void setSubjectTimer(String subject, {String? topic}) {
    _selectedSubject = subject;
    _selectedTopic = topic;
    _isMockExam = false;
    _duration = Duration.zero;
    _startTime = DateTime.now();
    notifyListeners();
  }

  // Manuel olarak süre eklemek için kullanılır (manuel tamamlama durumunda)
  Future<void> addManualDuration(
      String subject, String topic, Duration duration) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Timer session oluştur
      final session = TimerSession(
        subject: subject,
        topic: topic,
        startTime:
            DateTime.now().subtract(duration), // Süreyi geriye doğru hesapla
        endTime: DateTime.now(),
        duration: duration,
        pauses: [],
        isPlanned: true,
        userId: userId.toHexString(),
      );

      // Oturumu kaydet
      await addSession(session);

      debugPrint(
          'Manuel süre eklendi: $subject - $topic, ${duration.inMinutes} dakika');
    } catch (e) {
      debugPrint('Manuel süre eklenirken hata oluştu: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
