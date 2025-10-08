import 'package:flutter/material.dart';

class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key});

  int _getRemainingDays() {
    // 2025 YKS tarihi: 14-15 Haziran 2025
    final yksDate = DateTime(2025, 6, 14);
    final today = DateTime.now();
    return yksDate.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final remainingDays = _getRemainingDays();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '2025 YKS\'ye $remainingDays gün',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
