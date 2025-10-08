import 'package:flutter/material.dart';
import '../models/question_tracking.dart';
import '../services/mongodb_service.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/auth_service.dart';

class QuestionTrackingProvider extends ChangeNotifier {
  List<QuestionTracking> _trackings = [];
  List<QuestionTracking> _todayTrackings = [];
  bool _isLoading = true;
  int _dailyGoal = 100;
  String? _error;

  List<QuestionTracking> get trackings => _trackings;
  List<QuestionTracking> get todayTrackings => _todayTrackings;
  bool get isLoading => _isLoading;
  int get dailyGoal => _dailyGoal;

  List<QuestionTracking> get allTrackings => _trackings;

  QuestionTrackingProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        _error = 'Kullanıcı oturumu bulunamadı';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final trackings = await MongoDBService.instance.getQuestionTrackings();
      _trackings = trackings.where((t) => !t.isMockExam).toList();
      await filterMockExamTrackings();

      final dailyGoal = await MongoDBService.instance.getDailyGoal();

      if (dailyGoal != null) {
        _dailyGoal = dailyGoal.questionCount;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Soru takibi verileri yüklenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_error);
    }
  }

  Future<void> addTracking(QuestionTracking tracking) async {
    try {
      // Deneme sınavı kayıtlarını engelle
      if (tracking.isMockExam ||
          tracking.subject.toUpperCase().contains('TYT') ||
          tracking.subject.toUpperCase().contains('AYT')) {
        debugPrint('Deneme sınavı kaydı engellendi');
        return;
      }

      // Deneme sınavı yayınevlerinin adını içeren kayıtları engelle
      final publishers = [
        'Apotemi',
        'Karekök',
        'Palme',
        '345',
        'Acil',
        'Çap',
        'Endemik',
        'Limit',
        'Özdebir',
      ];
      if (publishers.any((p) => tracking.topic.contains(p))) {
        debugPrint('Deneme sınavı kaydı engellendi');
        return;
      }

      final id = await MongoDBService.instance.createQuestionTracking(tracking);
      tracking = tracking.copyWith(id: id);
      _trackings.add(tracking);

      // Bugünün takibi ise _todayTrackings'e de ekle
      final now = DateTime.now();
      if (tracking.date.year == now.year &&
          tracking.date.month == now.month &&
          tracking.date.day == now.day) {
        _todayTrackings.add(tracking);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Soru takibi eklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> updateTracking(QuestionTracking tracking) async {
    try {
      if (tracking.id == null) throw Exception('Tracking ID bulunamadı');
      await MongoDBService.instance
          .updateQuestionTracking(tracking.id!, tracking);

      final index = _trackings.indexWhere((t) => t.id == tracking.id);
      if (index != -1) {
        _trackings[index] = tracking;

        // Bugünün takibi ise _todayTrackings'i de güncelle
        final now = DateTime.now();
        if (tracking.date.year == now.year &&
            tracking.date.month == now.month &&
            tracking.date.day == now.day) {
          final todayIndex =
              _todayTrackings.indexWhere((t) => t.id == tracking.id);
          if (todayIndex != -1) {
            _todayTrackings[todayIndex] = tracking;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Soru takibi güncellenirken hata: $e');
      rethrow;
    }
  }

  Future<void> deleteTracking(QuestionTracking tracking) async {
    try {
      if (tracking.id == null) throw Exception('Tracking ID bulunamadı');
      await MongoDBService.instance.deleteQuestionTracking(tracking.id!);

      _trackings.removeWhere((t) => t.id == tracking.id);
      _todayTrackings.removeWhere((t) => t.id == tracking.id);

      notifyListeners();
    } catch (e) {
      debugPrint('Soru takibi silinirken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> setDailyGoal(int goal) async {
    try {
      await MongoDBService.instance.setDailyGoal(goal);
      _dailyGoal = goal;
      notifyListeners();
    } catch (e) {
      debugPrint('Günlük hedef ayarlanırken hata: $e');
      rethrow;
    }
  }

  Future<void> loadTodayTrackings() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Bugünün takiplerini mevcut takipler arasından filtrele
      _todayTrackings = _trackings.where((tracking) {
        return tracking.userId == userId.toHexString() &&
            tracking.date.isAfter(startOfDay) &&
            tracking.date.isBefore(endOfDay) &&
            !tracking.isMockExam; // Deneme sınavı olmayanları filtrele
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Bugünün takipleri yüklenirken hata: $e');
    }
  }

  Future<List<QuestionTracking>> getTrackingsForDate(DateTime date) async {
    final trackings = await _trackings.where((tracking) {
      return tracking.date.year == date.year &&
          tracking.date.month == date.month &&
          tracking.date.day == date.day &&
          !tracking.isMockExam; // Deneme sınavı olmayanları filtrele
    }).toList();
    return trackings;
  }

  Future<void> filterMockExamTrackings() async {
    try {
      _trackings = _trackings.where((tracking) {
        // Deneme sınavı olarak işaretlenmiş kayıtları filtrele
        if (tracking.isMockExam) return false;

        // Konu adında "TYT" veya "AYT" geçen kayıtları filtrele
        if (tracking.subject.toUpperCase().contains('TYT') ||
            tracking.subject.toUpperCase().contains('AYT')) {
          return false;
        }

        // Konu adında deneme sınavı yayınevlerinin adı geçen kayıtları filtrele
        final publishers = [
          'Apotemi',
          'Karekök',
          'Palme',
          '345',
          'Acil',
          'Çap',
          'Endemik',
          'Limit',
          'Özdebir',
        ];
        if (publishers.any((p) => tracking.topic.contains(p))) {
          return false;
        }

        return true;
      }).toList();

      // Bugünün takiplerini de güncelle
      final now = DateTime.now();
      _todayTrackings = _trackings.where((tracking) {
        return tracking.date.year == now.year &&
            tracking.date.month == now.month &&
            tracking.date.day == now.day;
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Deneme sınavı takipleri filtrelenirken hata: $e');
    }
  }
}
