enum ExamType {
  TYT,
  AYT,
}

enum AYTField {
  MF, // Matematik-Fen (Sayısal)
  EA, // Eşit Ağırlık
  SOZ // Sözel
}

extension AYTFieldExtension on AYTField {
  String get displayName {
    switch (this) {
      case AYTField.MF:
        return 'Sayısal';
      case AYTField.EA:
        return 'Eşit Ağırlık';
      case AYTField.SOZ:
        return 'Sözel';
    }
  }
}

class ExamTypeHelper {
  static const Map<ExamType, int> totalDuration = {
    ExamType.TYT: 165, // 2 saat 45 dakika
    ExamType.AYT: 180 // 3 saat
  };

  static const Map<ExamType, int> totalQuestions = {
    ExamType.TYT: 120, // Toplam 120 soru
    ExamType.AYT: 80 // Her alan için 80 soru
  };

  static const Map<AYTField, Map<String, int>> aytFieldQuestions = {
    AYTField.MF: {
      'AYT Matematik': 40,
      'AYT Fen Bilimleri': 40,
    },
    AYTField.EA: {
      'AYT Matematik': 40,
      'AYT Türk Dili ve Edebiyatı - Sosyal Bilimler 1': 40,
    },
    AYTField.SOZ: {
      'AYT Türk Dili ve Edebiyatı - Sosyal Bilimler 1': 40,
      'AYT Sosyal Bilimler 2': 40
    }
  };
}
