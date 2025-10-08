import 'package:flutter/material.dart';

class WeeklyPlanConstants {
  static const List<String> days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  static final cardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.05),
        Colors.white.withOpacity(0.02),
      ],
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
    ),
  );

  static const titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const subtitleTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  static final cardHeaderDecoration = BoxDecoration(
    color: const Color(0xFF252837),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    border: Border(
      bottom: BorderSide(
        color: Colors.white.withOpacity(0.1),
      ),
    ),
  );
}
