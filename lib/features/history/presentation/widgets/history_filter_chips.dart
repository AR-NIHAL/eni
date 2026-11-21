import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/history_providers.dart';

class HistoryFilterChips extends StatelessWidget {
  final HistoryFilter currentFilter;
  final int totalCount;
  final int takenCount;
  final int skippedCount;
  final int snoozedCount;
  final ValueChanged<HistoryFilter> onFilterChanged;

  const HistoryFilterChips({
    super.key,
    required this.currentFilter,
    required this.totalCount,
    required this.takenCount,
    required this.skippedCount,
    required this.snoozedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (HistoryFilter.all, 'All ($totalCount)'),
      (HistoryFilter.taken, 'Taken ($takenCount)'),
      (HistoryFilter.skipped, 'Skipped ($skippedCount)'),
      if (snoozedCount > 0) (HistoryFilter.snoozed, 'Snoozed ($snoozedCount)'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((item) {
          final filter = item.$1;
          final label = item.$2;
          final isSelected = currentFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryDark : AppColors.cardBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
