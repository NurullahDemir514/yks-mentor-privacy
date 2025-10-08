import '../models/weekly_plan.dart';
import '../models/mock_exam.dart';
import '../models/mock_exam_result.dart';
import '../services/mongodb_service.dart';
import '../constants/exam_subjects.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:provider/provider.dart';
import '../providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class MockExamService {
  static Future<List<MockExam>> filterByType(
    List<DailyPlanItem> plans,
    String examType,
    String userId,
  ) async {
    try {
      // Önce deneme sonuçlarını al
      final collection =
          MongoDBService.instance.getCollection('mock_exam_results');
      final results = await collection
          .find(where.eq('userId', userId))
          .map((doc) => MockExamResult.fromMap(doc))
          .toList();

      // Planları filtrele ve deneme sonuçlarıyla eşleştir
      return plans.map((plan) {
        // Bu plan için deneme sonucu var mı kontrol et
        final result = results.firstWhere(
          (r) => r.examId == plan.examId,
          orElse: () => MockExamResult(
            userId: userId,
            examType: plan.subject,
            publisher: plan.topic,
            results: {},
            duration: const Duration(minutes: 0),
            date: plan.date,
            isBranchExam: plan.subject.startsWith('TYT ') ||
                plan.subject.startsWith('AYT '),
            branch: plan.subject.startsWith('TYT ') ||
                    plan.subject.startsWith('AYT ')
                ? plan.subject
                : null,
            examId: plan.examId,
          ),
        );

        return MockExam.fromPlanItem(plan,
            result: result.results.isNotEmpty ? result : null);
      }).toList();
    } catch (e) {
      debugPrint('Deneme filtreleme hatası: $e');
      rethrow;
    }
  }

  static Future<void> saveResult(
      MockExamResult result, BuildContext context) async {
    try {
      debugPrint('Deneme sonucu kaydediliyor...');
      debugPrint('MockExamResult examId: ${result.examId}');

      // Sonucu kaydet
      final collection =
          MongoDBService.instance.getCollection('mock_exam_results');
      await collection.insertOne(result.toMap());
      debugPrint('Deneme sonucu veritabanına kaydedildi');

      // Planı yeniden yükle
      final weeklyPlanProvider = Provider.of<WeeklyPlanProvider>(
        context,
        listen: false,
      );

      debugPrint('Şu anki tarih: ${result.date}');
      debugPrint('${result.date} haftası için plan yükleniyor...');

      // Planı yeniden yükle
      await weeklyPlanProvider.loadPlanForWeek(result.date);
      debugPrint('Plan yeniden yüklendi');

      // Reklam göster
      await AdService.instance.showInterstitialAd();

      debugPrint('Deneme sonucu başarıyla kaydedildi');
    } catch (e) {
      debugPrint('Deneme sonucu kaydedilirken hata: $e');
      rethrow;
    }
  }

  static Future<List<MockExamResult>> getResults(String userId) async {
    final collection =
        MongoDBService.instance.getCollection('mock_exam_results');
    final results = await collection
        .find(where.eq('userId', userId))
        .map((doc) => MockExamResult.fromMap(doc))
        .toList();
    return results;
  }

  // Branş denemelerini getir
  static Future<List<MockExam>> getBranchExams(
    List<DailyPlanItem> plans,
    String branch,
    String userId,
  ) async {
    final collection =
        MongoDBService.instance.getCollection('mock_exam_results');
    final results = await collection
        .find(where.eq('userId', userId).and(where.eq('isBranchExam', true)))
        .map((doc) => MockExamResult.fromMap(doc))
        .toList();

    return plans
        .where((plan) =>
            plan.isMockExam &&
            (plan.subject.startsWith('TYT ') ||
                plan.subject.startsWith('AYT ')) &&
            !plan.isDeleted)
        .map((plan) {
      final result = results.firstWhere(
        (r) => r.examId == plan.examId,
        orElse: () => MockExamResult(
          userId: userId,
          examType: plan.subject.startsWith('TYT ') ? 'TYT' : 'AYT',
          publisher: plan.topic,
          results: {},
          duration: const Duration(minutes: 45),
          date: plan.date,
          isBranchExam: true,
          branch: plan.subject,
          examId: plan.examId,
        ),
      );

      return MockExam.fromPlanItem(plan, result: result);
    }).toList();
  }

  // Branş bazlı istatistikleri getir
  static Future<Map<String, List<MockExamResult>>> getBranchStatistics(
    String userId,
  ) async {
    final collection =
        MongoDBService.instance.getCollection('mock_exam_results');
    final results = await collection
        .find(where.eq('userId', userId).and(where.eq('isBranchExam', true)))
        .map((doc) => MockExamResult.fromMap(doc))
        .toList();

    // Branşlara göre grupla
    final Map<String, List<MockExamResult>> statistics = {};
    for (final result in results) {
      final branch = result.branch!;
      if (!statistics.containsKey(branch)) {
        statistics[branch] = [];
      }
      statistics[branch]!.add(result);
    }

    return statistics;
  }

  // Branş bazlı performans özeti
  static Future<Map<String, Map<String, double>>> getBranchPerformanceSummary(
    String userId,
  ) async {
    final statistics = await getBranchStatistics(userId);
    final Map<String, Map<String, double>> summary = {};

    for (final entry in statistics.entries) {
      final branch = entry.key;
      final results = entry.value;

      if (results.isEmpty) continue;

      final nets = results.map((r) => r.totalNet).toList();
      nets.sort();

      summary[branch] = {
        'average': nets.reduce((a, b) => a + b) / nets.length,
        'highest': nets.last,
        'lowest': nets.first,
        'latest': results.last.totalNet,
      };
    }

    return summary;
  }
}
