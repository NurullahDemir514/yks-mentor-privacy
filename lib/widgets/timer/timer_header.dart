import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../providers/timer_provider.dart';

class TimerHeader extends StatelessWidget {
  final TimerProvider provider;

  const TimerHeader({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        _buildTitleSection(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: provider.isMockExam
            ? Colors.orange.withOpacity(0.15)
            : AppTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (provider.isMockExam ? Colors.orange : AppTheme.primary)
              .withOpacity(0.2),
        ),
      ),
      child: Icon(
        provider.isMockExam ? Icons.assignment_outlined : Icons.book_outlined,
        color: provider.isMockExam ? Colors.orange : AppTheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          provider.selectedSubject!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        if (provider.selectedTopic != null ||
            provider.mockExamPublisher != null) ...[
          const SizedBox(height: 2),
          Text(
            provider.isMockExam
                ? '${provider.mockExamPublisher} Denemesi'
                : provider.selectedTopic!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ],
    );
  }
}
