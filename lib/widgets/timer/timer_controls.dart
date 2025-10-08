import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../providers/timer_provider.dart';

class TimerControls extends StatelessWidget {
  final TimerProvider provider;
  final VoidCallback onComplete;

  const TimerControls({
    super.key,
    required this.provider,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (provider.isRunning || provider.duration.inSeconds > 0)
          _buildStopButton(),
        if (provider.isRunning || provider.duration.inSeconds > 0)
          SizedBox(width: AppTheme.spacingLarge),
        _buildMainButton(),
      ],
    );
  }

  Widget _buildMainButton() {
    final Color primaryColor =
        provider.isMockExam ? AppTheme.warning : AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          if (!provider.isRunning)
            BoxShadow(
              color: primaryColor.withOpacity(AppTheme.shadowOpacity),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
        ],
      ),
      child: IconButton.filled(
        onPressed: () {
          if (provider.isRunning) {
            provider.pauseTimer();
          } else {
            provider.startTimer();
          }
        },
        style: IconButton.styleFrom(
          backgroundColor: provider.isRunning
              ? AppTheme.surfaceLight.withOpacity(0.1)
              : primaryColor,
          foregroundColor: provider.isRunning ? primaryColor : AppTheme.text,
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            side: BorderSide(
              color: provider.isRunning
                  ? primaryColor.withOpacity(AppTheme.borderOpacity)
                  : Colors.transparent,
            ),
          ),
        ),
        icon: Icon(
          provider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.error.withOpacity(AppTheme.shadowOpacity),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: IconButton.filled(
        onPressed: onComplete,
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.error.withOpacity(0.15),
          foregroundColor: AppTheme.error,
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            side: BorderSide(
              color: AppTheme.error.withOpacity(AppTheme.borderOpacity),
            ),
          ),
        ),
        icon: const Icon(
          Icons.stop_rounded,
          size: 32,
        ),
      ),
    );
  }
}
