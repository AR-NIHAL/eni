import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';
import '../../../medicine/presentation/providers/medicine_providers.dart';
import '../../domain/entities/adherence_stats_entity.dart';
import '../../domain/entities/day_compliance_summary.dart';
import '../../domain/usecases/calculate_adherence_usecase.dart';

enum HistoryFilter {
  all,
  taken,
  skipped,
  snoozed;

  String get displayName {
    switch (this) {
      case HistoryFilter.all:
        return 'All';
      case HistoryFilter.taken:
        return 'Taken';
      case HistoryFilter.skipped:
        return 'Skipped';
      case HistoryFilter.snoozed:
        return 'Snoozed';
    }
  }
}

// 1. Selected Month (defaults to 1st of current month)
final historySelectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

// 2. Selected Day (null = view whole month, or specific DateTime for single day focus)
final historySelectedDayProvider = StateProvider<DateTime?>((ref) => null);

// 3. Status Filter (all, taken, skipped, snoozed)
final historyFilterProvider = StateProvider<HistoryFilter>((ref) => HistoryFilter.all);

// 4. Calculate Adherence UseCase
final calculateAdherenceUseCaseProvider = Provider<CalculateAdherenceUseCase>((ref) {
  return CalculateAdherenceUseCase();
});

// 5. Watch all dose logs in real-time
final allDoseLogsStreamProvider = StreamProvider<List<DoseLogEntity>>((ref) {
  final repo = ref.watch(doseRepositoryProvider);
  return repo.watchAllDoseLogs();
});

// 6. Day summaries for the selected month
final monthlyDaySummariesProvider = Provider<Map<DateTime, DayComplianceSummary>>((ref) {
  final medicines = ref.watch(medicinesStreamProvider).value ?? [];
  final logs = ref.watch(allDoseLogsStreamProvider).value ?? [];
  final selectedMonth = ref.watch(historySelectedMonthProvider);
  final useCase = ref.watch(calculateAdherenceUseCaseProvider);

  return useCase.computeMonthlyDaySummaries(
    medicines: medicines,
    allLogs: logs,
    year: selectedMonth.year,
    month: selectedMonth.month,
  );
});

// 7. Monthly Adherence Stats
final monthlyAdherenceStatsProvider = Provider<AdherenceStatsEntity>((ref) {
  final medicines = ref.watch(medicinesStreamProvider).value ?? [];
  final logs = ref.watch(allDoseLogsStreamProvider).value ?? [];
  final selectedMonth = ref.watch(historySelectedMonthProvider);
  final useCase = ref.watch(calculateAdherenceUseCaseProvider);

  return useCase.calculateStats(
    medicines: medicines,
    allLogs: logs,
    year: selectedMonth.year,
    month: selectedMonth.month,
  );
});

// 8. Filtered & Sorted Dose Logs for Timeline Display
final filteredHistoryLogsProvider = Provider<List<DoseLogEntity>>((ref) {
  final allLogs = ref.watch(allDoseLogsStreamProvider).value ?? [];
  final selectedMonth = ref.watch(historySelectedMonthProvider);
  final selectedDay = ref.watch(historySelectedDayProvider);
  final filter = ref.watch(historyFilterProvider);

  return allLogs.where((log) {
    // Date filter
    if (selectedDay != null) {
      if (log.scheduledDate.year != selectedDay.year ||
          log.scheduledDate.month != selectedDay.month ||
          log.scheduledDate.day != selectedDay.day) {
        return false;
      }
    } else {
      // Month filter
      if (log.scheduledDate.year != selectedMonth.year ||
          log.scheduledDate.month != selectedMonth.month) {
        return false;
      }
    }

    // Status filter
    switch (filter) {
      case HistoryFilter.all:
        return true;
      case HistoryFilter.taken:
        return log.status == DoseStatus.taken;
      case HistoryFilter.skipped:
        return log.status == DoseStatus.skipped;
      case HistoryFilter.snoozed:
        return log.status == DoseStatus.snoozed;
    }
  }).toList()
    ..sort((a, b) {
      // Sort descending by date, then time
      final dateCmp = b.scheduledDate.compareTo(a.scheduledDate);
      if (dateCmp != 0) return dateCmp;
      return b.scheduledTime.compareTo(a.scheduledTime);
    });
});
