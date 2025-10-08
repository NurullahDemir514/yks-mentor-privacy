import 'package:flutter/foundation.dart';
import '../services/mongodb_service.dart';
import '../models/daily_goal.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DailyGoalProvider extends ChangeNotifier {
  final _mongoDBService = MongoDBService.instance;
  DailyGoal? _currentDailyGoal;
  bool _isLoading = false;

  DailyGoal? get currentDailyGoal => _currentDailyGoal;
  bool get isLoading => _isLoading;

  Future<void> setDailyGoal(int questionCount) async {
    try {
      await _mongoDBService.setDailyGoal(questionCount);
      debugPrint('Günlük hedef kaydedildi: $questionCount soru');
      await loadDailyGoal();
    } catch (e) {
      debugPrint('Günlük hedef kaydetme hatası: $e');
      rethrow;
    }
  }

  Future<void> loadDailyGoal() async {
    try {
      _isLoading = true;
      notifyListeners();

      final goal = await _mongoDBService.getDailyGoal();
      if (goal != null) {
        _currentDailyGoal = goal;
        debugPrint(
            'Günlük hedef yüklendi: ${_currentDailyGoal?.questionCount} soru');
      } else {
        _currentDailyGoal = null;
        debugPrint('Bugün için hedef bulunamadı');
      }
    } catch (e) {
      debugPrint('Günlük hedef yükleme hatası: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
