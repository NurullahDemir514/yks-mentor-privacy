import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../providers/timer_provider.dart';
import 'timer_header.dart';
import 'timer_clock.dart';
import 'timer_controls.dart';

class TimerContainer extends StatelessWidget {
  final TimerProvider provider;
  final VoidCallback onComplete;

  const TimerContainer({
    super.key,
    required this.provider,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        provider.isMockExam ? AppTheme.warning : AppTheme.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCenter,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: primaryColor.withOpacity(AppTheme.borderOpacity),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppTheme.shadowOpacity),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimerHeader(provider: provider),
          SizedBox(height: AppTheme.spacingLarge),
          TimerClock(time: provider.formattedTime),
          SizedBox(height: AppTheme.spacingLarge),
          TimerControls(
            provider: provider,
            onComplete: onComplete,
          ),
        ],
      ),
    );
  }
}
