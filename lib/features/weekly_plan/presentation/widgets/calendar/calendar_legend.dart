import 'package:flutter/material.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Düşük',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.8), // Mavi (düşük)
                    const Color(0xFF64B5F6).withOpacity(0.8), // Açık mavi
                    const Color(0xFFFFB74D).withOpacity(0.8), // Açık turuncu
                    const Color(0xFFFF9800).withOpacity(0.8), // Turuncu
                    const Color(0xFFF4511E).withOpacity(0.8), // Turuncu-kırmızı
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Yüksek',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
