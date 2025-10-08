import 'package:flutter/material.dart';
import '../../services/statistics_service.dart';

class TimeBasedMessage {
  static const morningStartHour = 5;
  static const afternoonStartHour = 12;
  static const eveningStartHour = 17;
  static const nightStartHour = 22;

  static TimeOfDay timeOfDay = TimeOfDay.now();

  static bool get isMorning =>
      timeOfDay.hour >= morningStartHour && timeOfDay.hour < afternoonStartHour;
  static bool get isAfternoon =>
      timeOfDay.hour >= afternoonStartHour && timeOfDay.hour < eveningStartHour;
  static bool get isEvening =>
      timeOfDay.hour >= eveningStartHour && timeOfDay.hour < nightStartHour;
  static bool get isNight =>
      timeOfDay.hour >= nightStartHour || timeOfDay.hour < morningStartHour;

  static Color get themeColor {
    if (isMorning) return const Color(0xFFFF9800);
    if (isAfternoon) return const Color(0xFF2196F3);
    if (isEvening) return const Color(0xFF673AB7);
    return const Color(0xFF3F51B5);
  }

  static String get greeting {
    if (isMorning) return 'Günaydın!';
    if (isAfternoon) return 'İyi günler!';
    if (isEvening) return 'İyi akşamlar!';
    return 'İyi geceler!';
  }
}

class WelcomeCard extends StatelessWidget {
  final DailyStats stats;
  final String motivationalMessage;

  const WelcomeCard({
    super.key,
    required this.stats,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TimeBasedMessage.themeColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TimeBasedMessage.themeColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TimeBasedMessage.greeting,
              style: TextStyle(
                color: TimeBasedMessage.themeColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              motivationalMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
