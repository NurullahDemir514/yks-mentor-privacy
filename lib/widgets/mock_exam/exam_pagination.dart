import 'package:flutter/material.dart';
import '../../constants/theme.dart';

class ExamPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const ExamPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          icon: Icon(
            Icons.chevron_left,
            color:
                currentPage > 0 ? Colors.white : Colors.white.withOpacity(0.3),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.2),
            ),
          ),
          child: Text(
            '${currentPage + 1} / $totalPages',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: Icon(
            Icons.chevron_right,
            color: currentPage < totalPages - 1
                ? Colors.white
                : Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
