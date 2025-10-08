import 'exam_type.dart';

class ExamSubjects {
  static final Map<ExamType, Map<String, List<String>>> subjects = {
    ExamType.TYT: {
      'Türkçe': [
        'Sözcükte Anlam',
        'Cümlede Anlam',
        'Paragraf',
        'Paragrafta Anlatım Teknikleri',
        'Paragrafta Düşünceyi Geliştirme Yolları',
        'Paragrafta Yapı',
        'Paragrafta Konu-Ana Düşünce',
        'Paragrafta Yardımcı Düşünce',
        'Ses Bilgisi',
        'Yazım Kuralları',
        'Noktalama İşaretleri',
        'Sözcükte Yapı',
        'Sözcük Türleri',
        'İsimler',
        'Zamirler',
        'Sıfatlar',
        'Zarflar',
        'Edat - Bağlaç - Ünlem',
        'Fiiller',
        'Fiilde Anlam (Kip-Kişi-Yapı)',
        'Ek Fiil',
        'Fiilimsi',
        'Fiilde Çatı',
        'Cümlenin Ögeleri',
        'Cümle Türleri',
        'Anlatım Bozukluğu'
      ],
      'Matematik': [
        'Temel Kavramlar',
        'Sayı Basamakları',
        'Bölme ve Bölünebilme',
        'EBOB - EKOK',
        'Rasyonel Sayılar',
        'Basit Eşitsizlikler',
        'Mutlak Değer',
        'Üslü Sayılar',
        'Köklü Sayılar',
        'Çarpanlara Ayırma',
        'Oran Orantı',
        'Denklem Çözme',
        'Sayı Problemleri',
        'Kesir Problemleri',
        'Yaş Problemleri',
        'Yüzde Problemleri',
        'Kar Zarar Problemleri',
        'Karışım Problemleri',
        'Hareket Problemleri',
        'İşçi Problemleri',
        'Tablo-Grafik Problemleri',
        'Rutin Olmayan Problemler',
        'Kümeler',
        'Mantık',
        'Fonksiyonlar',
        'Polinomlar',
        '2.Dereceden Denklemler',
        'Permütasyon ve Kombinasyon',
        'Olasılık',
        'Veri - İstatistik'
      ],
      'Geometri': [
        'Doğruda Açı',
        'Üçgende Açı',
        'Ek Çizimler',
        'Dik Üçgen',
        'İkizkenar Üçgen',
        'Eşkenar Üçgen',
        'Açıortay',
        'Kenarortay',
        'Üçgende Eşlik - Benzerlik',
        'Açı - Kenar Bağıntıları',
        'Üçgende Alan',
        'Üçgende Merkezler',
        'Çokgenler',
        'Dörtgenler',
        'Deltoid',
        'Paralelkenar',
        'Eşkenar Dörtgen',
        'Dikdörtgen',
        'Kare',
        'Yamuk',
        'Çember ve Daire',
        'Çemberde Açı',
        'Çemberde Uzunluk',
        'Dairede Alan',
        'Noktanın Analitiği',
        'Doğrunun Analitiği',
        'Prizmalar',
        'Küp',
        'Silindir',
        'Piramit',
        'Koni',
        'Küre'
      ],
      'Fizik': [
        'Fizik Bilimine Giriş',
        'Madde ve Özellikleri',
        'Hareket ve Kuvvet',
        'İş, Güç ve Enerji',
        'Isı, Sıcaklık ve Genleşme',
        'Basınç',
        'Kaldırma Kuvveti',
        'Elektrostatik',
        'Elektrik ve Manyetizma',
        'Dalgalar',
        'Optik'
      ],
      'Kimya': [
        'Kimya Bilimi',
        'Atom ve Periyodik Sistem',
        'Kimyasal Türler Arası Etkileşimler',
        'Maddenin Halleri',
        'Doğa ve Kimya',
        'Kimyanın Temel Kanunları',
        'Kimyasal Hesaplamalar',
        'Karışımlar',
        'Asit, Baz ve Tuz',
        'Kimya Her Yerde'
      ],
      'Biyoloji': [
        'Canlıların Ortak Özellikleri',
        'Canlıların Temel Bileşenleri',
        'Hücre ve Organelleri',
        'Hücre Zarından Madde Geçişi',
        'Canlıların Sınıflandırılması',
        'Mitoz ve Eşeysiz Üreme',
        'Mayoz ve Eşeyli Üreme',
        'Kalıtım',
        'Ekosistem Ekolojisi',
        'Güncel Çevre Sorunları'
      ],
      'Tarih': [
        'Tarih ve Zaman',
        'İnsanlığın İlk Dönemleri',
        'İlk ve Orta Çağlarda Türk Dünyası',
        'İslam Medeniyetinin Doğuşu',
        'Türklerin İslamiyet\'i Kabulü',
        'Orta Çağ\'da Dünya',
        'Selçuklu Türkiyesi',
        'Beylikten Devlete Osmanlı',
        'Osmanlı Medeniyeti',
        'Dünya Gücü Osmanlı',
        'Sultan ve Osmanlı Merkez Teşkilatı',
        'Klasik Çağda Osmanlı Toplum Düzeni',
        'Değişen Dünya Dengeleri',
        'XIX. ve XX. Yüzyılda Osmanlı',
        'XX. Yüzyıl Başlarında Osmanlı',
        'Milli Mücadele',
        'Atatürkçülük ve Türk İnkılabı'
      ],
      'Coğrafya': [
        'Doğa ve İnsan',
        'Dünya\'nın Şekli ve Hareketleri',
        'Coğrafi Konum',
        'Harita Bilgisi',
        'İklim Bilgisi',
        'Dünya\'nın Tektonik Oluşumu',
        'Jeolojik Zamanlar',
        'İç Kuvvetler / Dış Kuvvetler',
        'Kayaçlar',
        'Türkiye\'nin Yer Şekilleri',
        'Su - Toprak ve Bitkiler',
        'Nüfus',
        'Türkiye\'de Nüfus',
        'Göç',
        'Ekonomik Faaliyetler',
        'Bölgeler',
        'Uluslararası Ulaşım Hatları',
        'Çevre ve Toplum',
        'Doğal Afetler'
      ],
      'Felsefe': [
        'Felsefenin Konusu',
        'Bilgi Felsefesi',
        'Varlık Felsefesi',
        'Ahlak Felsefesi',
        'Sanat Felsefesi',
        'Din Felsefesi',
        'Siyaset Felsefesi',
        'Bilim Felsefesi',
        'İlk Çağ Felsefesi',
        '2. Yüzyıl ve 15. Yüzyıl Felsefeleri',
        '15. Yüzyıl ve 17. Yüzyıl Felsefeleri',
        '18. Yüzyıl ve 19. Yüzyıl Felsefeleri',
        '20. Yüzyıl Felsefesi'
      ],
      'Din Kültürü': [
        'Bilgi ve İnanç',
        'Din ve İslam',
        'İslam ve İbadet',
        'Gençlik ve Değerler',
        'İslam Medeniyeti',
        'Allah İnancı',
        'Allah\'ın Varlığı ve Birliği',
        'Allah\'ın İsim ve Sıfatları',
        'İnsan ve Özellikleri',
        'İnsanın Allah İle İrtibatı',
        'Hz. Muhammed ve Gençlik',
        'Din ve Aile',
        'Din, Kültür ve Sanat',
        'Din ve Çevre',
        'Din ve Sosyal Değişim',
        'Din ve Ekonomi',
        'Din ve Sosyal Adalet',
        'Ahlaki Tutum ve Davranışlar',
        'İslam Düşüncesinde Yorumlar'
      ],
    },
    ExamType.AYT: {
      'Matematik': [
        'Temel Kavramlar',
        'Sayı Basamakları',
        'Bölme ve Bölünebilme',
        'EBOB - EKOK',
        'Rasyonel Sayılar',
        'Basit Eşitsizlikler',
        'Mutlak Değer',
        'Üslü Sayılar',
        'Köklü Sayılar',
        'Çarpanlara Ayırma',
        'Oran Orantı',
        'Denklem Çözme',
        'Problemler',
        'Kümeler',
        'Mantık',
        'Fonksiyonlar',
        'Polinomlar',
        '2.Dereceden Denklemler',
        'Binom',
        'Permütasyon ve Kombinasyon',
        'Olasılık',
        'Veri - İstatistik',
        'Karmaşık Sayılar',
        '2.Dereceden Eşitsizlikler',
        'Parabol',
        'Trigonometri',
        'Logaritma',
        'Diziler',
        'Limit',
        'Türev',
        'İntegral'
      ],
      'Geometri': [
        'Doğruda Açı',
        'Üçgende Açı',
        'Ek Çizimler',
        'Dik Üçgen',
        'İkizkenar Üçgen',
        'Eşkenar Üçgen',
        'Açıortay',
        'Kenarortay',
        'Üçgende Eşlik - Benzerlik',
        'Açı - Kenar Bağıntıları',
        'Üçgende Alan',
        'Üçgende Merkezler',
        'Çokgenler',
        'Özel Dörtgenler',
        'Çember ve Daire',
        'Noktanın Analitiği',
        'Doğrunun Analitiği',
        'Dönüşüm Geometrisi',
        'Uzay Geometri',
        'Çemberin Analitiği'
      ],
      'Fizik': [
        'Vektörler',
        'Kuvvet, Tork ve Denge',
        'Kütle Merkezi',
        'Basit Makineler',
        'Hareket',
        'Newton\'un Hareket Yasaları',
        'İş, Güç ve Enerji',
        'Atışlar',
        'İtme ve Momentum',
        'Elektrik Alan ve Potansiyel',
        'Paralel Levhalar ve Sığa',
        'Manyetik Alan ve Manyetik Kuvvet',
        'İndüksiyon ve Alternatif Akım',
        'Düzgün Çembersel Hareket',
        'Dönme ve Açısal Momentum',
        'Kütle Çekim ve Kepler Yasaları',
        'Basit Harmonik Hareket',
        'Dalga Mekaniği',
        'Atom Fiziği ve Radyoaktivite',
        'Modern Fizik',
        'Modern Fiziğin Uygulamaları'
      ],
      'Kimya': [
        'Modern Atom Teorisi',
        'Gazlar',
        'Sıvı Çözeltiler',
        'Kimyasal Tepkimelerde Enerji',
        'Kimyasal Tepkimelerde Hız',
        'Kimyasal Tepkimelerde Denge',
        'Asit-Baz Dengesi',
        'Çözünürlük Dengesi',
        'Kimya ve Elektrik',
        'Karbon Kimyasına Giriş',
        'Organik Kimya',
        'Enerji Kaynakları'
      ],
      'Biyoloji': [
        'Sinir Sistemi',
        'Endokrin Sistem',
        'Duyu Organları',
        'Destek ve Hareket Sistemi',
        'Sindirim Sistemi',
        'Dolaşım ve Bağışıklık Sistemi',
        'Solunum Sistemi',
        'Boşaltım Sistemi',
        'Üreme Sistemi',
        'Komünite ve Popülasyon Ekolojisi',
        'Genden Proteine',
        'Canlılarda Enerji Dönüşümleri',
        'Bitki Biyolojisi',
        'Canlılar ve Çevre'
      ],
      'Edebiyat': [
        'Anlam Bilgisi',
        'Şiir Bilgisi',
        'Söz Sanatları',
        'Türk Edebiyatı Dönemleri',
        'İslamiyet Öncesi Türk Edebiyatı',
        'Halk Edebiyatı',
        'Divan Edebiyatı',
        'Tanzimat Edebiyatı',
        'Servet-i Fünun Edebiyatı',
        'Fecr-i Ati Edebiyatı',
        'Milli Edebiyat',
        'Cumhuriyet Dönemi Edebiyatı',
        'Dünya Edebiyatı',
        'Edebi Akımlar'
      ],
      'Tarih': [
        'İki Savaş Arası Dönem',
        'II. Dünya Savaşı',
        'Soğuk Savaş Dönemi',
        'Yumuşama Dönemi',
        'Küreselleşen Dünya',
        'Türkiye\'de Demokratikleşme',
        'Toplumsal Devrim Çağı',
        'XXI. Yüzyıl Eşiğinde Türkiye'
      ],
      'Coğrafya': [
        'Ekosistemler',
        'Biyoçeşitlilik',
        'Enerji Kaynakları',
        'Küresel İklim Değişimi',
        'Nüfus Politikaları',
        'Türkiye\'de Ekonomi',
        'Türkiye\'nin İşlevsel Bölgeleri',
        'Küresel Ticaret',
        'Türkiye Turizmi',
        'Kültür Bölgeleri',
        'Jeopolitik Konum',
        'Çevre Sorunları'
      ],
      'Felsefe': [
        'MÖ 6. - MS 2. Yüzyıl Felsefesi',
        'MS 2. - 15. Yüzyıl Felsefesi',
        '15. - 17. Yüzyıl Felsefesi',
        '18. - 19. Yüzyıl Felsefesi',
        '20. Yüzyıl Felsefesi',
        'Mantığa Giriş',
        'Klasik Mantık',
        'Mantık ve Dil',
        'Sembolik Mantık',
        'Psikoloji Bilimi',
        'Öğrenme ve Bellek',
        'Ruh Sağlığı',
        'Sosyolojiye Giriş',
        'Birey ve Toplum',
        'Toplumsal Yapı'
      ],
      'Din Kültürü': [
        'Dünya ve Ahiret',
        'Kur\'an\'da Hz. Muhammed',
        'Kur\'an\'da Kavramlar',
        'İnançla İlgili Meseleler',
        'Yahudilik ve Hristiyanlık',
        'İslam ve Bilim',
        'Anadolu\'da İslam',
        'Tasavvufi Yorumlar',
        'Güncel Dini Meseleler',
        'Hint ve Çin Dinleri'
      ],
    },
  };

  /// Verilen ders için TYT ve AYT'deki tüm konuları birleştirir
  static List<String> getAllTopicsForSubject(String subject) {
    Set<String> allTopics = {};

    final tytSubjects = subjects[ExamType.TYT];
    if (tytSubjects?.containsKey(subject) ?? false) {
      allTopics.addAll(tytSubjects![subject]!);
    }

    final aytSubjects = subjects[ExamType.AYT];
    if (aytSubjects?.containsKey(subject) ?? false) {
      allTopics.addAll(aytSubjects![subject]!);
    }

    return allTopics.toList();
  }

  /// Tüm dersleri döndürür (TYT ve AYT'deki benzersiz dersler)
  static List<String> getAllSubjects() {
    Set<String> allSubjects = {};

    // TYT dersleri
    allSubjects.addAll(subjects[ExamType.TYT]?.keys ?? {});
    // AYT dersleri
    allSubjects.addAll(subjects[ExamType.AYT]?.keys ?? {});

    return allSubjects.toList();
  }

  // Branşlara göre standart deneme sınavı soru sayıları
  static const Map<String, Map<String, int>> mockExamQuestionCounts = {
    'TYT': {
      'Türkçe': 40,
      'Matematik': 40,
      'Fen Bilimleri': 20,
      'Sosyal Bilimler': 20,
    },
    'AYT': {
      'Matematik': 40,
      'Fen Bilimleri': 40,
      'Türk Dili ve Edebiyatı - Sosyal Bilimler 1': 40,
      'Sosyal Bilimler 2': 40,
    }
  };

  // Branş denemesi için soru sayısını döndürür
  static int getBranchExamQuestionCount(String branch) {
    if (branch.startsWith('AYT ')) {
      final subject = branch.substring(4); // "AYT " prefix'ini kaldır
      return mockExamQuestionCounts['AYT']?[subject] ?? 40;
    } else if (branch.startsWith('TYT ')) {
      final subject = branch.substring(4); // "TYT " prefix'ini kaldır
      return mockExamQuestionCounts['TYT']?[subject] ?? 40;
    }
    return 40; // Varsayılan değer
  }

  // Branş denemesi için konuları döndürür
  static List<String> getBranchTopics(String branch) {
    if (branch.startsWith('AYT ')) {
      final subject = branch.substring(4); // "AYT " prefix'ini kaldır
      return subjects[ExamType.AYT]?[subject] ?? [];
    } else {
      return subjects[ExamType.TYT]?[branch] ?? [];
    }
  }

  // Tüm branşları döndürür (TYT ve AYT için)
  static List<String> getAllBranches() {
    Set<String> branches = {};

    // TYT branşları
    mockExamQuestionCounts['TYT']?.forEach((subject, _) {
      branches.add('TYT $subject');
    });

    // AYT branşları
    mockExamQuestionCounts['AYT']?.forEach((subject, _) {
      branches.add('AYT $subject');
    });

    return branches.toList()..sort();
  }
}

const List<String> examSubjects = [
  'Matematik',
  'Fizik',
  'Kimya',
  'Biyoloji',
  'Türkçe',
  'Edebiyat',
  'Tarih',
  'Coğrafya',
  'Felsefe',
  'Din Kültürü',
  'İngilizce',
];
