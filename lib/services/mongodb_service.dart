import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/question_tracking.dart';
import '../models/daily_goal.dart';
import 'package:flutter/foundation.dart';
import '../models/weekly_plan.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class MongoDBService {
  static final MongoDBService instance = MongoDBService._init();
  Db? _db;
  DbCollection? _usersCollection;
  bool _isInitialized = false;

  // MongoDB bağlantı bilgileri
  static const String _connectionString =
      'mongodb+srv://memirdemir115:Nd5454341745@yks-mentor.dsxtw.mongodb.net/yks_mentor?retryWrites=true&w=majority&appName=yks-mentor';

  // Koleksiyon isimleri
  static const String questionTrackingCollection = 'question_tracking';
  static const String dailyGoalsCollection = 'daily_goals';
  static const String weeklyPlansCollection = 'weekly_plans';

  MongoDBService._init();

  Future<void> init() async {
    if (_isInitialized && _db != null && _db!.isConnected) return;

    try {
      debugPrint('MongoDB bağlantısı başlatılıyor...');
      _db = await Db.create(_connectionString);
      await _db!.open();
      debugPrint('MongoDB bağlantısı başarılı');

      _usersCollection = _db!.collection('users');
      _isInitialized = true;
    } catch (e) {
      debugPrint('MongoDB bağlantı hatası: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _db == null || !_db!.isConnected) {
      debugPrint('MongoDB bağlantısı yeniden başlatılıyor...');
      await init();
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> registerUser(
      String email, String password, String name) async {
    try {
      await _ensureInitialized();

      debugPrint('Kayıt denemesi: $email');
      final existingUser =
          await _usersCollection!.findOne(where.eq('email', email));
      if (existingUser != null) {
        throw Exception('Bu e-posta adresi zaten kullanımda');
      }

      final hashedPassword = _hashPassword(password);
      final user = {
        'email': email,
        'password': hashedPassword,
        'name': name,
        'createdAt': DateTime.now(),
      };

      final result = await _usersCollection!.insertOne(user);
      if (!result.isSuccess) {
        throw Exception('Kullanıcı kaydedilemedi');
      }
      user['_id'] = result.id;
      user.remove('password');
      return user;
    } catch (e) {
      debugPrint('Kayıt hatası detayı: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      await _ensureInitialized();

      final hashedPassword = _hashPassword(password);
      final user = await _usersCollection!
          .findOne(where.eq('email', email).eq('password', hashedPassword));

      if (user != null) {
        // Oturum bilgilerini temizle
        user.remove('password');
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Giriş hatası: $e');
      rethrow;
    }
  }

  Future<void> logoutUser(String userId) async {
    try {
      await _ensureInitialized();
      // Çıkış işlemi için özel bir şey yapmaya gerek yok
    } catch (e) {
      debugPrint('Çıkış hatası: $e');
      rethrow;
    }
  }

  Future<bool> validateSession(String userId, String sessionId) async {
    try {
      await _ensureInitialized();
      final user =
          await _usersCollection!.findOne(where.id(ObjectId.parse(userId)));
      return user != null;
    } catch (e) {
      debugPrint('Oturum doğrulama hatası: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      await _ensureInitialized();

      if (_usersCollection == null) {
        throw Exception('Veritabanı bağlantısı kurulamadı');
      }

      final user =
          await _usersCollection!.findOne(where.id(ObjectId.parse(userId)));
      if (user != null) {
        user.remove('password');
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Kullanıcı getirme hatası: $e');
      rethrow;
    }
  }

  // Veritabanı bağlantısını kontrol et
  Future<void> _checkConnection() async {
    if (_db == null || !_db!.isConnected) {
      await init();
    }
  }

  // Koleksiyon alma metodu
  DbCollection getCollection(String collectionName) {
    if (_db == null || !_db!.isConnected) {
      throw Exception('Veritabanı bağlantısı yok');
    }
    return _db!.collection(collectionName);
  }

  // Soru Takibi İşlemleri
  Future<ObjectId> createQuestionTracking(QuestionTracking tracking) async {
    try {
      await _checkConnection();
      final collection = _db!.collection(questionTrackingCollection);

      // Deneme sınavı kayıtlarını engelle
      if (tracking.isMockExam ||
          tracking.subject.toUpperCase().contains('TYT') ||
          tracking.subject.toUpperCase().contains('AYT')) {
        throw Exception('Deneme sınavı kaydı oluşturulamaz');
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
        throw Exception('Deneme sınavı kaydı oluşturulamaz');
      }

      debugPrint('Yeni soru kaydı oluşturuluyor...');
      debugPrint('Ders: ${tracking.subject}');
      debugPrint('Konu: ${tracking.topic}');
      debugPrint('Toplam Soru: ${tracking.totalQuestions}');
      debugPrint('Tarih: ${tracking.date.toIso8601String()}');

      // Yeni kayıt oluştur
      final result = await collection.insertOne(tracking.toMap());

      debugPrint('Kayıt başarıyla oluşturuldu. ID: ${result.id}');
      return result.id as ObjectId;
    } catch (e) {
      debugPrint('Soru takibi oluşturulurken hata: $e');
      rethrow;
    }
  }

  Future<List<QuestionTracking>> getQuestionTrackings() async {
    try {
      await _checkConnection();
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Kullanıcının tüm kayıtlarını getir ve deneme sınavlarını filtrele
      final List<Map<String, dynamic>> results = await _db!
          .collection(questionTrackingCollection)
          .find(where.eq('userId', userId.toHexString()).ne('isMockExam', true))
          .toList();

      return results.map((doc) => QuestionTracking.fromMap(doc)).toList();
    } catch (e) {
      debugPrint('Soru takiplerini getirme hatası: $e');
      rethrow;
    }
  }

  Future<List<QuestionTracking>> getQuestionTrackingsBySubject(
      String subject) async {
    try {
      await _checkConnection();
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final List<Map<String, dynamic>> results = await _db!
          .collection(questionTrackingCollection)
          .find(where
              .eq('subject', subject)
              .eq('userId', userId)
              .ne('isMockExam', true))
          .toList();
      return results.map((doc) => QuestionTracking.fromMap(doc)).toList();
    } catch (e) {
      debugPrint('Derse göre soru takiplerini getirme hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteQuestionTracking(ObjectId id) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final collection = _db!.collection(questionTrackingCollection);
      await collection
          .deleteOne(where.id(id).eq('userId', userId.toHexString()));
    } catch (e) {
      throw Exception('Soru takibi silinirken hata oluştu: $e');
    }
  }

  Future<void> updateQuestionTracking(
      ObjectId id, QuestionTracking tracking) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final collection = _db!.collection(questionTrackingCollection);
      final map = tracking.toMap();
      map.remove('_id'); // ID'yi güncelleme işleminden çıkar
      await collection.updateOne(
        where.id(id).eq('userId', userId.toHexString()),
        {'\$set': map},
      );
    } catch (e) {
      throw Exception('Soru takibi güncellenirken hata oluştu: $e');
    }
  }

  // Günlük Hedef İşlemleri
  Future<DailyGoal?> getDailyGoal() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dailyGoals = await _db!
          .collection(dailyGoalsCollection)
          .find(where
              .eq('userId', userId.toHexString())
              .gte('date', startOfDay.toIso8601String())
              .lt('date', endOfDay.toIso8601String()))
          .toList();

      if (dailyGoals.isEmpty) return null;
      return DailyGoal.fromMap(dailyGoals.first);
    } catch (e) {
      debugPrint('Günlük hedef alınırken hata: $e');
      return null;
    }
  }

  Future<void> setDailyGoal(int questionCount) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final dailyGoal = DailyGoal(
        questionCount: questionCount,
        date: startOfDay,
        userId: userId.toHexString(),
      );

      // Bugünün hedefini sil
      await _db!.collection(dailyGoalsCollection).deleteMany(where
          .eq('userId', userId.toHexString())
          .gte('date', startOfDay.toIso8601String())
          .lt('date',
              startOfDay.add(const Duration(days: 1)).toIso8601String()));

      // Yeni hedefi ekle
      await _db!.collection(dailyGoalsCollection).insertOne(dailyGoal.toMap());
    } catch (e) {
      debugPrint('Günlük hedef kaydedilirken hata: $e');
      rethrow;
    }
  }

  // Haftalık Plan İşlemleri
  Future<void> createWeeklyPlan(WeeklyPlan plan) async {
    try {
      await _checkConnection();
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final planMap = plan.toMap();
      planMap['userId'] = userId.toHexString();

      // Önce mevcut haftanın planını kontrol et
      final existingPlan = await getCurrentWeeklyPlan(plan.startDate);
      if (existingPlan != null) {
        // Varolan planı güncelle
        await updateWeeklyPlan(plan.copyWith(id: existingPlan.id));
      } else {
        // Yeni plan oluştur
        await _db!.collection(weeklyPlansCollection).insertOne(planMap);
      }
    } catch (e) {
      debugPrint('Haftalık plan oluşturulurken hata: $e');
      rethrow;
    }
  }

  Future<List<WeeklyPlan>> getAllWeeklyPlans() async {
    try {
      await _checkConnection();
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final result = await _db!
          .collection(weeklyPlansCollection)
          .find(where.eq('userId', userId.toHexString()))
          .toList();

      debugPrint('Bulunan plan sayısı: ${result.length}');
      debugPrint('Kullanıcı ID: ${userId.toHexString()}');

      final plans = result.map((doc) => WeeklyPlan.fromMap(doc)).toList();
      // Tarihe göre sırala
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));
      return plans;
    } catch (e) {
      debugPrint('Tüm haftalık planlar alınırken hata: $e');
      rethrow;
    }
  }

  Future<WeeklyPlan?> getCurrentWeeklyPlan(DateTime startDate) async {
    try {
      await _checkConnection();
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      debugPrint('Kullanıcı ID: ${userId.toHexString()}');

      // Haftanın bitiş tarihini hesapla
      final endDate = startDate.add(const Duration(days: 7));

      debugPrint('Başlangıç tarihi: ${startDate.toIso8601String()}');
      debugPrint('Bitiş tarihi: ${endDate.toIso8601String()}');

      final collection = _db!.collection(weeklyPlansCollection);
      final result = await collection.findOne(
        where
            .eq('userId', userId.toHexString())
            .gte('startDate', startDate)
            .lt('startDate', endDate),
      );

      debugPrint(
          'Sorgu sonucu: ${result != null ? 'Plan bulundu' : 'Plan bulunamadı'}');

      if (result != null) {
        return WeeklyPlan.fromMap(result);
      }
      return null;
    } catch (e) {
      debugPrint('Haftalık plan getirme hatası: $e');
      rethrow;
    }
  }

  Future<void> updateWeeklyPlan(WeeklyPlan plan) async {
    try {
      await _checkConnection();
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final map = plan.toMap();
      map.remove('_id'); // ID'yi güncelleme işleminden çıkar
      await _db!.collection(weeklyPlansCollection).updateOne(
        where.id(plan.id!).eq('userId', userId.toHexString()),
        {'\$set': map},
      );
    } catch (e) {
      debugPrint('Haftalık plan güncellenirken hata: $e');
      rethrow;
    }
  }

  // Veritabanı bağlantısını kapat
  Future<void> close() async {
    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
        debugPrint('MongoDB bağlantısı kapatıldı');
      }
    } catch (e) {
      debugPrint('MongoDB bağlantısını kapatma hatası: $e');
      rethrow;
    }
  }

  // Yardımcı metodlar
  Future<void> deleteMany(String collectionName, List<String> ids) async {
    await _checkConnection();
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final collection = _db!.collection(collectionName);
    await collection.deleteMany(where
        .eq('userId', userId.toHexString())
        .oneFrom('_id', ids.map((id) => ObjectId.parse(id)).toList()));
  }

  Future<bool> validatePassword(String email, String password) async {
    final collection = getCollection('users');
    final user = await collection.findOne(where.eq('email', email));
    if (user == null) return false;
    return user['password'] == _hashPassword(password);
  }

  Future<void> updatePassword(ObjectId userId, String newPassword) async {
    final collection = getCollection('users');
    await collection.update(
      where.eq('_id', userId),
      {
        '\$set': {'password': _hashPassword(newPassword)}
      },
    );
  }

  Future<void> deleteMockExamTrackings() async {
    try {
      await _checkConnection();
      final collection = _db!.collection(questionTrackingCollection);

      // Deneme sınavı olarak işaretlenmiş kayıtları sil
      await collection.deleteMany(where.eq('isMockExam', true));

      // TYT veya AYT içeren kayıtları sil
      await collection.deleteMany(where.match('subject', 'TYT|AYT'));

      // Deneme sınavı yayınevlerinin adını içeren kayıtları sil
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
      for (final publisher in publishers) {
        await collection.deleteMany(where.match('topic', publisher));
      }

      debugPrint('Deneme sınavı takipleri silindi');
    } catch (e) {
      debugPrint('Deneme sınavı takipleri silinirken hata: $e');
      rethrow;
    }
  }

  Future<void> cleanupDeletedPlans() async {
    try {
      debugPrint('Silinen planlar temizleniyor...');
      final plansCollection = _db!.collection(weeklyPlansCollection);
      final questionTrackingCol = _db!.collection(questionTrackingCollection);

      // Tüm haftalık planları getir
      final List<Map<String, dynamic>> allPlans =
          await plansCollection.find().toList();

      // Silinen planların konularını topla
      final Set<Map<String, String>> deletedPlanTopics = {};

      for (var plan in allPlans) {
        final Map<String, List<dynamic>> dailyPlans =
            Map.from(plan['dailyPlans'] as Map);

        // Her günün planlarını kontrol et
        dailyPlans.forEach((day, List<dynamic> plans) {
          for (var item in plans) {
            if (item['isDeleted'] == true) {
              deletedPlanTopics.add({
                'subject': item['subject'] as String,
                'topic': item['topic'] as String,
                'userId': plan['userId'] as String,
              });
            }
          }
        });
      }

      // Silinen planların soru kayıtlarını temizle
      for (var topic in deletedPlanTopics) {
        await questionTrackingCol.deleteMany(
          where
              .eq('subject', topic['subject'])
              .eq('topic', topic['topic'])
              .eq('userId', topic['userId']),
        );
        debugPrint(
            '${topic['subject']} - ${topic['topic']} için tüm soru kayıtları silindi');
      }

      // Planlardan silinen öğeleri temizle
      for (var plan in allPlans) {
        bool hasUpdate = false;
        final Map<String, List<dynamic>> dailyPlans =
            Map.from(plan['dailyPlans'] as Map);

        // Her günün planlarını kontrol et ve silinenleri temizle
        dailyPlans.forEach((day, List<dynamic> plans) {
          final List<dynamic> originalPlans = List.from(plans);
          plans.clear();

          for (var item in originalPlans) {
            if (item['isDeleted'] != true) {
              plans.add(item);
            } else {
              hasUpdate = true;
            }
          }
        });

        // Boş günleri temizle
        dailyPlans.removeWhere((_, plans) => plans.isEmpty);

        if (hasUpdate) {
          await plansCollection.updateOne(
            where.id(plan['_id']),
            modify.set('dailyPlans', dailyPlans),
          );
          debugPrint('${plan['_id']} ID\'li plan güncellendi');
        }
      }

      debugPrint(
          'Silinen planların ve soru kayıtlarının temizlenmesi tamamlandı');
    } catch (e) {
      debugPrint('Silinen planlar temizlenirken hata: $e');
      rethrow;
    }
  }
}
