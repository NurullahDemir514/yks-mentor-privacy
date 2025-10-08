import 'package:flutter/material.dart';
import '../../constants/theme.dart';

class TimerClock extends StatelessWidget {
  final String time;

  const TimerClock({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: AppTheme.text.withOpacity(AppTheme.borderOpacity),
        ),
      ),
      child: Text(
        time,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.text,
          fontSize: 56,
          fontWeight: FontWeight.w600,
          height: 1,
          letterSpacing: -0.5,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(AppTheme.shadowOpacity),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
