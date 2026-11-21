import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/day_compliance_summary.dart';

class MonthlyHeatmapWidget extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDay;
  final Map<DateTime, DayComplianceSummary> daySummaries;
  final ValueChanged<DateTime?> onDaySelected;

  const MonthlyHeatmapWidget({
    super.key,
    required this.selectedMonth,
    required this.selectedDay,
    required this.daySummaries,
    required this.onDaySelected,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final firstDayOfWeek = DateTime(selectedMonth.year, selectedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final leadingEmptyCells = firstDayOfWeek - 1;

    const weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adherence Heatmap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (selectedDay != null)
                GestureDetector(
                  onTap: () => onDaySelected(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.cardBorder, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          'Show all month',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((label) {
              return SizedBox(
                width: 34,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmptyCells + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyCells) {
                return const SizedBox.shrink();
              }

              final dayNum = index - leadingEmptyCells + 1;
              final cellDate = DateTime(selectedMonth.year, selectedMonth.month, dayNum);
              final isToday = _isSameDay(cellDate, today);
              final isFuture = cellDate.isAfter(today);
              final isSelected = selectedDay != null && _isSameDay(selectedDay!, cellDate);

              final summary = daySummaries[cellDate];
              final hasTaken = summary != null && summary.takenDoses > 0;
              final hasSkipped = summary != null && summary.hasSkipped;
              final isAllTaken = summary != null && summary.isFullCompliance;

              Color dotColor = Colors.transparent;
              if (!isFuture && summary != null && summary.totalDoses > 0) {
                if (isAllTaken) {
                  dotColor = AppColors.accentLime;
                } else if (hasSkipped) {
                  dotColor = AppColors.error;
                } else if (hasTaken) {
                  dotColor = AppColors.primaryDark;
                } else {
                  dotColor = AppColors.textMuted;
                }
              }

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () {
                        if (isSelected) {
                          onDaySelected(null);
                        } else {
                          onDaySelected(cellDate);
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryDark
                        : (isToday ? AppColors.surfaceSubtle : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryDark
                          : (isToday ? AppColors.accentLime : Colors.transparent),
                      width: isToday ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : (isFuture ? AppColors.textMuted : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentLime : dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(AppColors.accentLime, 'Completed'),
              const SizedBox(width: 16),
              _buildLegendDot(AppColors.primaryDark, 'Partial'),
              const SizedBox(width: 16),
              _buildLegendDot(AppColors.error, 'Skipped'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
