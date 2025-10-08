import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/weekly_plan.dart';
import '../services/mongodb_service.dart';
import '../services/auth_service.dart';
import '../constants/exam_subjects.dart';

class WeeklyPlanProvider with ChangeNotifier {
  WeeklyPlan? _selectedWeekPlan;
  List<WeeklyPlan> _plans = [];
  Map<String, bool> _expandedDays = {};
  bool _isLoading = false;
  String? _error;
  DateTime _selectedWeek = DateTime.now();

  WeeklyPlanProvider() {
    _init();
  }

  WeeklyPlan? get selectedWeekPlan => _selectedWeekPlan;
  List<WeeklyPlan> get allPlans => _plans;
  Map<String, bool> get expandedDays => _expandedDays;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedWeek => _selectedWeek;

  void setSelectedWeek(DateTime date) {
    _selectedWeek = date;
    notifyListeners();
  }

  Future<void> _init() async {
    try {
      // Önce silinen planları temizle
      await MongoDBService.instance.cleanupDeletedPlans();

      // Sonra planları yükle
      await loadPlanForWeek(DateTime.now());
      await loadAllPlans();
    } catch (e) {
      debugPrint('Provider başlatılırken hata: $e');
    }
  }

  Future<void> loadAllPlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        _error = 'Kullanıcı oturumu bulunamadı';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _plans = await MongoDBService.instance.getAllWeeklyPlans();
      _plans.sort((a, b) => b.startDate.compareTo(a.startDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Haftalık planlar yüklenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_error);
    }
  }

  Future<void> loadPlanForWeek(DateTime date) async {
    try {
      debugPrint('${date.toIso8601String()} haftası için plan yükleniyor...');

      // Haftanın başlangıç gününü hesapla (Pazartesi)
      var startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      startOfWeek =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      debugPrint('Aranan hafta başlangıcı: ${startOfWeek.toIso8601String()}');

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Önce mevcut planları yükle
      _plans = await MongoDBService.instance.getAllWeeklyPlans();
      _plans.sort((a, b) => b.startDate.compareTo(a.startDate));

      // Seçilen haftanın planını bul
      final weekPlan = _plans.firstWhere(
        (plan) => _isSameWeek(plan.startDate, startOfWeek),
        orElse: () => WeeklyPlan(
          dailyPlans: {},
          startDate: startOfWeek,
          userId: userId.toHexString(),
        ),
      );

      // Şu anki haftayı bul
      final now = DateTime.now();
      var currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      currentWeekStart = DateTime(
          currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);

      if (weekPlan.id == null) {
        debugPrint(
            'Seçilen hafta için plan bulunamadı, yeni plan oluşturuluyor');
        // Yeni planı oluştur ve kaydet
        await MongoDBService.instance.createWeeklyPlan(weekPlan);
        _plans.add(weekPlan); // Planlar listesine ekle
        _plans.sort(
            (a, b) => b.startDate.compareTo(a.startDate)); // Tarihe göre sırala

        // Seçilen haftanın planını güncelle
        _selectedWeekPlan = weekPlan;

        // Eğer bu hafta ise currentPlan'ı da güncelle
        if (_isSameWeek(startOfWeek, currentWeekStart)) {
          _selectedWeekPlan = weekPlan;
        }
      } else {
        debugPrint('Seçilen haftanın planı bulundu: ${weekPlan.id}');
        // Seçilen haftanın planını güncelle
        _selectedWeekPlan = weekPlan;

        // Eğer bu hafta ise currentPlan'ı da güncelle
        if (_isSameWeek(startOfWeek, currentWeekStart)) {
          _selectedWeekPlan = weekPlan;
        }
      }

      _error = null;
    } catch (e) {
      debugPrint('Haftalık plan yüklenirken hata: $e');
      _error = 'Haftalık plan yüklenirken bir hata oluştu';
      _selectedWeekPlan = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final start1 = date1.subtract(Duration(days: date1.weekday - 1));
    final start2 = date2.subtract(Duration(days: date2.weekday - 1));

    return DateTime(start1.year, start1.month, start1.day)
        .isAtSameMomentAs(DateTime(start2.year, start2.month, start2.day));
  }

  Future<void> createWeeklyPlan(WeeklyPlan plan) async {
    try {
      debugPrint('Yeni plan oluşturuluyor...');
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Veritabanına kaydet
      await MongoDBService.instance.createWeeklyPlan(plan);
      debugPrint('Plan veritabanına kaydedildi');

      _selectedWeekPlan = plan;

      // Planları yeniden yükle
      await loadAllPlans();
      notifyListeners();
    } catch (e) {
      debugPrint('Plan oluşturulurken hata: $e');
      rethrow;
    }
  }

  Future<void> updateWeeklyPlan(WeeklyPlan plan) async {
    try {
      if (plan.id == null) {
        debugPrint('Plan ID null, yeni plan oluşturuluyor');
        await createWeeklyPlan(plan);
        return;
      }

      debugPrint('Plan güncelleniyor: ${plan.id}');
      await MongoDBService.instance.updateWeeklyPlan(plan);
      debugPrint('Plan veritabanında güncellendi');

      if (_selectedWeekPlan?.id == plan.id) {
        _selectedWeekPlan = plan;
      }

      // Planlar listesini güncelle
      final index = _plans.indexWhere((p) => p.id == plan.id);
      if (index != -1) {
        _plans[index] = plan;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Plan güncellenirken hata: $e');
      rethrow;
    }
  }

  List<DailyPlanItem> getDailyPlanItems(DateTime date) {
    if (_selectedWeekPlan == null) return [];

    final dayName = _getDayName(date.weekday);
    final plans = _selectedWeekPlan!.dailyPlans[dayName] ?? [];
    return plans.where((plan) => !plan.isDeleted).toList();
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

  Future<void> addDailyPlan(
      String day, DailyPlanItem plan, String userId) async {
    try {
      debugPrint('Plan ekleme başlatıldı');
      debugPrint('Gün: $day');
      debugPrint('Ders: ${plan.subject}');
      debugPrint('Konu: ${plan.topic}');

      // Eğer bu bir deneme ise ve examId varsa, bu examId'nin benzersiz olduğunu kontrol et
      if (plan.isMockExam && plan.examId != null) {
        final allPlans =
            _selectedWeekPlan?.dailyPlans.values.expand((e) => e).toList() ??
                [];
        final hasExistingExam = allPlans.any((existingPlan) =>
            existingPlan.examId == plan.examId && !existingPlan.isDeleted);

        if (hasExistingExam) {
          throw Exception('Bu deneme ID\'si zaten kullanımda');
        }
      }

      // Optimistik güncelleme
      if (_selectedWeekPlan == null) {
        _selectedWeekPlan = WeeklyPlan(
          dailyPlans: {
            day: [plan]
          },
          startDate: _selectedWeek,
          userId: userId,
        );
      } else {
        // Günün planlarını al veya yeni liste oluştur
        Map<String, List<DailyPlanItem>> updatedPlans =
            Map.from(_selectedWeekPlan!.dailyPlans);
        if (!updatedPlans.containsKey(day)) {
          updatedPlans[day] = [];
        }
        updatedPlans[day] = [...updatedPlans[day]!, plan];
        _selectedWeekPlan =
            _selectedWeekPlan!.copyWith(dailyPlans: updatedPlans);
      }
      notifyListeners();

      // Veritabanı güncellemesi
      if (_selectedWeekPlan!.id == null) {
        await createWeeklyPlan(_selectedWeekPlan!);
      } else {
        await updateWeeklyPlan(_selectedWeekPlan!);
      }

      // Planları yeniden yükle
      await loadAllPlans();
    } catch (e) {
      debugPrint('Plan eklenirken hata: $e');
      // Hata durumunda eski haline geri dön
      await loadPlanForWeek(_selectedWeek);
      rethrow;
    }
  }

  // Timer entegrasyonu için metodlar
  List<String> getPlannedSubjectsForDay(DateTime date) {
    try {
      debugPrint(
          'getPlannedSubjectsForDay çağrıldı: ${date.toIso8601String()}');

      // Kullanıcı kontrolü
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        debugPrint('Kullanıcı ID bulunamadı');
        return [];
      }

      // Mevcut planı doğrudan _currentPlan'dan al
      if (_selectedWeekPlan == null) {
        debugPrint('Aktif plan bulunamadı');
        return [];
      }

      if (_selectedWeekPlan!.userId != userId.toHexString()) {
        debugPrint('Plan kullanıcıya ait değil');
        return [];
      }

      final dayName = _getDayName(date.weekday);
      debugPrint('Gün adı: $dayName');

      final dailyPlan = _selectedWeekPlan!.dailyPlans[dayName] ?? [];
      debugPrint('Günlük plan öğe sayısı: ${dailyPlan.length}');

      final subjects = dailyPlan
          .where((item) => item.subject.isNotEmpty)
          .map((item) => item.subject)
          .toSet()
          .toList();

      debugPrint('Bulunan dersler: $subjects');
      return subjects;
    } catch (e) {
      debugPrint('getPlannedSubjectsForDay hatası: $e');
      return [];
    }
  }

  bool isSubjectPlannedForDay(String subject, DateTime date) {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return false;

      final currentPlan = getCurrentPlan();
      if (currentPlan == null || currentPlan.userId != userId.toHexString())
        return false;

      final dayName = _getDayName(date.weekday);
      final dailyPlan = currentPlan.dailyPlans[dayName] ?? [];

      return dailyPlan.any((item) => item.subject == subject);
    } catch (e) {
      debugPrint('isSubjectPlannedForDay hatası: $e');
      return false;
    }
  }

  String? getWeeklyPlanIdForSubject(String subject) {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return null;

    final currentPlan = getCurrentPlan();
    if (currentPlan == null || currentPlan.userId != userId.toHexString())
      return null;

    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    final dailyPlan = currentPlan.dailyPlans[dayName] ?? [];

    if (dailyPlan.any((item) => item.subject == subject)) {
      return currentPlan.id?.toHexString();
    }
    return null;
  }

  WeeklyPlan? getCurrentPlan() {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return null;

      final userPlans =
          _plans.where((plan) => plan.userId == userId.toHexString()).toList();
      if (userPlans.isEmpty) return null;

      final now = DateTime.now();
      debugPrint('Şu anki tarih: ${now.toIso8601String()}');

      // Tarihe göre sırala (en yeni plan en başta)
      userPlans.sort((a, b) => b.startDate.compareTo(a.startDate));

      // En son oluşturulan planı döndür
      return userPlans.first;
    } catch (e) {
      debugPrint('Plan getirme hatası: $e');
      return null;
    }
  }

  Future<void> markItemAsCompleted(
      String subject, String topic, int solvedQuestionCount) async {
    try {
      debugPrint(
          'markItemAsCompleted başladı - Ders: $subject, Konu: $topic, Çözülen: $solvedQuestionCount');

      final currentPlan = getCurrentPlan();
      if (currentPlan == null) {
        debugPrint('Aktif plan bulunamadı');
        return;
      }

      final today = DateTime.now();
      final dayName = _getDayName(today.weekday);
      debugPrint('Gün: $dayName');

      final dailyPlans =
          Map<String, List<DailyPlanItem>>.from(currentPlan.dailyPlans);
      final todayPlans = List<DailyPlanItem>.from(dailyPlans[dayName] ?? []);

      final itemIndex = todayPlans.indexWhere(
        (item) =>
            item.subject == subject &&
            (item.isMockExam ? true : item.topic == topic),
      );

      if (itemIndex != -1) {
        debugPrint('Plan öğesi bulundu, güncelleniyor...');
        todayPlans[itemIndex] = todayPlans[itemIndex].copyWith(
          isCompleted: true,
        );

        dailyPlans[dayName] = todayPlans;

        final updatedPlan = currentPlan.copyWith(
          dailyPlans: dailyPlans,
        );

        await updateWeeklyPlan(updatedPlan);
        debugPrint('Plan güncellendi');
        notifyListeners();
      } else {
        debugPrint('Plan öğesi bulunamadı');
      }
    } catch (e) {
      debugPrint('markItemAsCompleted hatası: $e');
      rethrow;
    }
  }

  void toggleDayExpansion(String day) {
    _expandedDays[day] = !(_expandedDays[day] ?? false);
    notifyListeners();
  }

  Future<void> updatePlanItem(
      String day, DailyPlanItem oldPlan, DailyPlanItem newPlan) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return;

    try {
      // Optimistic update
      final plans = _selectedWeekPlan!.dailyPlans[day] ?? [];
      final index = plans.indexWhere((p) =>
          (p.examId != null && p.examId == oldPlan.examId) ||
          (p.subject == oldPlan.subject &&
              p.topic == oldPlan.topic &&
              p.isMockExam == oldPlan.isMockExam));

      if (index != -1) {
        plans[index] = newPlan;
        _selectedWeekPlan!.dailyPlans[day] = plans;
        notifyListeners();
      }

      // Update in database
      await MongoDBService.instance.updateWeeklyPlan(_selectedWeekPlan!);
    } catch (e) {
      debugPrint('Plan güncellenirken hata: $e');
      // Revert optimistic update
      await loadPlanForWeek(_selectedWeek);
    }
  }

  Future<void> deletePlanItem(String day, DailyPlanItem plan) async {
    if (_selectedWeekPlan == null) return;

    try {
      // Eğer bu bir deneme ise ve examId varsa, ilgili sonuçları ve oturumları sil
      if (plan.isMockExam && plan.examId != null) {
        final mockExamResults =
            MongoDBService.instance.getCollection('mock_exam_results');
        final timerSessions =
            MongoDBService.instance.getCollection('timer_sessions');

        // Deneme sonuçlarını sil
        await mockExamResults.deleteOne(
          where.eq('examId', plan.examId),
        );

        // Timer oturumlarını sil
        await timerSessions.deleteMany(
          where.eq('examId', plan.examId),
        );
      }

      // Optimistik güncelleme
      Map<String, List<DailyPlanItem>> updatedPlans = {};
      _selectedWeekPlan!.dailyPlans.forEach((key, plans) {
        updatedPlans[key] = plans
            .where((item) => !(item.subject == plan.subject &&
                item.topic == plan.topic &&
                item.isMockExam == plan.isMockExam &&
                item.examId == plan.examId))
            .toList();
      });

      _selectedWeekPlan = _selectedWeekPlan!.copyWith(dailyPlans: updatedPlans);
      notifyListeners();

      // Veritabanı güncellemesi
      await updateWeeklyPlan(_selectedWeekPlan!);

      // Planları yeniden yükle
      await loadAllPlans();
    } catch (e) {
      debugPrint('Plan silinirken hata: $e');
      // Hata durumunda eski haline geri dön
      await loadPlanForWeek(_selectedWeek);
      rethrow;
    }
  }

  // Optimistik güncellemeler
  void updatePlanItemOptimistic(
      String day, DailyPlanItem oldPlan, DailyPlanItem newPlan) {
    if (_selectedWeekPlan == null) return;

    final plans =
        List<DailyPlanItem>.from(_selectedWeekPlan!.dailyPlans[day] ?? []);
    final index = plans.indexOf(oldPlan);
    if (index != -1) {
      plans[index] = newPlan;
      _selectedWeekPlan = _selectedWeekPlan!.copyWith(
        dailyPlans: Map.from(_selectedWeekPlan!.dailyPlans)..[day] = plans,
      );
      notifyListeners();
    }
  }

  void deletePlanItemOptimistic(String day, DailyPlanItem plan) {
    if (_selectedWeekPlan == null) return;

    final plans =
        List<DailyPlanItem>.from(_selectedWeekPlan!.dailyPlans[day] ?? []);
    // examId'ye göre de kontrol et
    final index = plans.indexWhere((item) =>
        item.subject == plan.subject &&
        item.topic == plan.topic &&
        item.isMockExam == plan.isMockExam &&
        item.examId == plan.examId);
    if (index != -1) {
      plans.removeAt(index);
      _selectedWeekPlan = _selectedWeekPlan!.copyWith(
        dailyPlans: Map.from(_selectedWeekPlan!.dailyPlans)..[day] = plans,
      );
      notifyListeners();
    }
  }

  void addPlanItemOptimistic(String day, DailyPlanItem plan) {
    if (_selectedWeekPlan == null) return;

    final plans =
        List<DailyPlanItem>.from(_selectedWeekPlan!.dailyPlans[day] ?? []);
    plans.add(plan);
    _selectedWeekPlan = _selectedWeekPlan!.copyWith(
      dailyPlans: Map.from(_selectedWeekPlan!.dailyPlans)..[day] = plans,
    );
    notifyListeners();
  }

  Future<void> deleteMockExam(String day, DailyPlanItem mockExam) async {
    await deletePlanItem(day, mockExam);
  }

  Future<void> deleteDailyPlanItem(String day, DailyPlanItem plan) async {
    try {
      if (_selectedWeekPlan == null) return;

      // Günlük planları al
      var dayPlans = _selectedWeekPlan!.dailyPlans[day] ?? [];

      // Planı listeden kaldır
      dayPlans.removeWhere((item) =>
          item.subject == plan.subject &&
          item.topic == plan.topic &&
          item.date.isAtSameMomentAs(plan.date));

      // Güncellenmiş planları kaydet
      final updatedPlans =
          Map<String, List<DailyPlanItem>>.from(_selectedWeekPlan!.dailyPlans);
      updatedPlans[day] = dayPlans;

      // Yeni WeeklyPlan oluştur
      final updatedWeekPlan = _selectedWeekPlan!.copyWith(
        dailyPlans: updatedPlans,
        updatedAt: DateTime.now(),
      );

      // İlgili soru kayıtlarını sil
      final questionTrackingCol =
          MongoDBService.instance.getCollection('question_tracking');
      final userId = AuthService.instance.currentUser?.id;
      if (userId != null) {
        await questionTrackingCol.deleteMany(where
            .eq('subject', plan.subject)
            .eq('topic', plan.topic)
            .eq('userId', userId.toHexString())
            .gte(
                'date',
                DateTime(plan.date.year, plan.date.month, plan.date.day)
                    .toIso8601String())
            .lt(
                'date',
                DateTime(plan.date.year, plan.date.month, plan.date.day, 23, 59,
                        59)
                    .toIso8601String()));
        debugPrint(
            '${plan.subject} - ${plan.topic} için soru kayıtları silindi');
      }

      // Veritabanını güncelle
      await updateWeeklyPlan(updatedWeekPlan);

      notifyListeners();
    } catch (e) {
      debugPrint('Plan silinirken hata: $e');
      rethrow;
    }
  }

  Future<void> cleanupDeletedPlans() async {
    try {
      _isLoading = true;
      notifyListeners();

      await MongoDBService.instance.cleanupDeletedPlans();

      // Planları yeniden yükle
      await loadAllPlans();
      await loadPlanForWeek(_selectedWeek);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Silinen planlar temizlenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_error);
    }
  }
}
