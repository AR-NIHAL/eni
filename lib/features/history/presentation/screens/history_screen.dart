import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../providers/history_providers.dart';
import '../widgets/adherence_hero_card.dart';
import '../widgets/dose_history_timeline_tile.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/history_filter_chips.dart';
import '../widgets/monthly_heatmap_widget.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _previousMonth(WidgetRef ref, DateTime current) {
    ref.read(historySelectedMonthProvider.notifier).state =
        DateTime(current.year, current.month - 1, 1);
    ref.read(historySelectedDayProvider.notifier).state = null;
  }

  void _nextMonth(WidgetRef ref, DateTime current) {
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + 1, 1);
    // Don't page beyond current month
    if (next.isAfter(DateTime(now.year, now.month + 1, 1))) return;

    ref.read(historySelectedMonthProvider.notifier).state = next;
    ref.read(historySelectedDayProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(historySelectedMonthProvider);
    final selectedDay = ref.watch(historySelectedDayProvider);
    final currentFilter = ref.watch(historyFilterProvider);

    final stats = ref.watch(monthlyAdherenceStatsProvider);
    final daySummaries = ref.watch(monthlyDaySummariesProvider);
    final logs = ref.watch(filteredHistoryLogsProvider);
    final allLogs = ref.watch(allDoseLogsStreamProvider).value ?? [];

    final monthStr = DateFormat('MMMM yyyy').format(selectedMonth);
    final isCurrentMonth = selectedMonth.year == DateTime.now().year &&
        selectedMonth.month == DateTime.now().month;

    // Counts for filter chips
    final totalInScope = allLogs.where((l) =>
        l.scheduledDate.year == selectedMonth.year &&
        l.scheduledDate.month == selectedMonth.month).length;
    final takenCount = allLogs.where((l) =>
        l.scheduledDate.year == selectedMonth.year &&
        l.scheduledDate.month == selectedMonth.month &&
        l.status == DoseStatus.taken).length;
    final skippedCount = allLogs.where((l) =>
        l.scheduledDate.year == selectedMonth.year &&
        l.scheduledDate.month == selectedMonth.month &&
        l.status == DoseStatus.skipped).length;
    final snoozedCount = allLogs.where((l) =>
        l.scheduledDate.year == selectedMonth.year &&
        l.scheduledDate.month == selectedMonth.month &&
        l.status == DoseStatus.snoozed).length;

    // Group logs by date
    final Map<String, List<DoseLogEntity>> groupedLogs = {};
    for (final log in logs) {
      final dateKey = _formatDateHeader(log.scheduledDate);
      groupedLogs.putIfAbsent(dateKey, () => []).add(log);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: context.canPop()
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                ),
              )
            : null,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _previousMonth(ref, selectedMonth),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              monthStr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isCurrentMonth ? null : () => _nextMonth(ref, selectedMonth),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isCurrentMonth ? AppColors.surfaceSubtle : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isCurrentMonth ? AppColors.textMuted : AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Export report button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => ExportReportSheet.show(
                context,
                selectedMonth: selectedMonth,
                stats: stats,
                logs: logs,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.file_upload_outlined, size: 20, color: AppColors.primaryDark),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Adherence Hero Card
              AdherenceHeroCard(stats: stats),
              const SizedBox(height: 18),

              // 2. Monthly Interactive Calendar Heatmap
              MonthlyHeatmapWidget(
                selectedMonth: selectedMonth,
                selectedDay: selectedDay,
                daySummaries: daySummaries,
                onDaySelected: (day) {
                  ref.read(historySelectedDayProvider.notifier).state = day;
                },
              ),
              const SizedBox(height: 20),

              // 3. Filter Chips
              HistoryFilterChips(
                currentFilter: currentFilter,
                totalCount: totalInScope,
                takenCount: takenCount,
                skippedCount: skippedCount,
                snoozedCount: snoozedCount,
                onFilterChanged: (filter) {
                  ref.read(historyFilterProvider.notifier).state = filter;
                },
              ),
              const SizedBox(height: 20),

              // 4. Dose Timeline Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDay != null
                        ? 'Logs for ${DateFormat('d MMMM').format(selectedDay)}'
                        : 'Dose Activity Log',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${logs.length} ${logs.length == 1 ? 'entry' : 'entries'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Grouped Timeline List
              if (logs.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 36,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No dose activity recorded',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDay != null
                            ? 'No doses logged for this date.'
                            : 'Doses marked as taken or skipped will appear here.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...groupedLogs.entries.map((entry) {
                  final dateHeader = entry.key;
                  final dayLogs = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 4.0),
                        child: Text(
                          dateHeader,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      ...dayLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: DoseHistoryTimelineTile(log: log),
                        );
                      }),
                      const SizedBox(height: 6),
                    ],
                  );
                }),
              ],

              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today, ${DateFormat('d MMM').format(date)}';
    if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('d MMM').format(date)}';
    }
    return DateFormat('EEEE, d MMMM').format(date);
  }
}
