import '../services/mongodb_service.dart';

Future<void> main() async {
  try {
    await MongoDBService.instance.init();
    await MongoDBService.instance.deleteMockExamTrackings();
    print('Deneme sınavı takipleri başarıyla silindi');
  } catch (e) {
    print('Hata: $e');
  } finally {
    await MongoDBService.instance.close();
  }
}
