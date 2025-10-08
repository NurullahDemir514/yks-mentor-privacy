import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../constants/theme.dart';

enum CalendarViewType { monthly, weekly }

class CalendarHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final CalendarViewType viewType;
  final Function(DateTime) onMonthChanged;
  final Function(CalendarViewType) onViewTypeChanged;
  final VoidCallback onSummaryTap;

  const CalendarHeader({
    super.key,
    required this.selectedMonth,
    required this.viewType,
    required this.onMonthChanged,
    required this.onViewTypeChanged,
    required this.onSummaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => onMonthChanged(
              viewType == CalendarViewType.monthly
                  ? DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                    )
                  : selectedMonth.subtract(const Duration(days: 7)),
            ),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSummaryTap,
              child: Column(
                children: [
                  Text(
                    viewType == CalendarViewType.monthly
                        ? DateFormat('MMMM y', 'tr_TR')
                            .format(selectedMonth)
                            .toUpperCase()
                        : '${DateFormat('d MMMM', 'tr_TR').format(
                            selectedMonth.subtract(
                              Duration(days: selectedMonth.weekday - 1),
                            ),
                          )} - ${DateFormat('d MMMM', 'tr_TR').format(
                            selectedMonth.add(
                              Duration(days: 7 - selectedMonth.weekday),
                            ),
                          )}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => onMonthChanged(
              viewType == CalendarViewType.monthly
                  ? DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    )
                  : selectedMonth.add(const Duration(days: 7)),
            ),
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewTypeButton(
                  context,
                  CalendarViewType.monthly,
                  Icons.calendar_month_rounded,
                ),
                _buildViewTypeButton(
                  context,
                  CalendarViewType.weekly,
                  Icons.calendar_view_week_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypeButton(
    BuildContext context,
    CalendarViewType type,
    IconData icon,
  ) {
    final isSelected = viewType == type;

    return GestureDetector(
      onTap: () => onViewTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(isSelected ? 1 : 0.5),
          size: 18,
        ),
      ),
    );
  }
}
