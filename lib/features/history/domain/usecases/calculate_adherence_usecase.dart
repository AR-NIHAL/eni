import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import '../../../medicine/domain/entities/medicine_schedule_entity.dart';
import '../entities/adherence_stats_entity.dart';
import '../entities/day_compliance_summary.dart';

class CalculateAdherenceUseCase {
  bool _isMedicineScheduledOnDay(MedicineEntity medicine, DateTime date) {
    if (!medicine.isActive || medicine.isPaused) return false;

    // Check course duration bounds
    final startDate = DateTime(
      medicine.duration.startDate.year,
      medicine.duration.startDate.month,
      medicine.duration.startDate.day,
    );
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isBefore(startDate)) return false;

    if (medicine.duration.endDate != null) {
      final endDate = DateTime(
        medicine.duration.endDate!.year,
        medicine.duration.endDate!.month,
        medicine.duration.endDate!.day,
      );
      if (targetDate.isAfter(endDate)) return false;
    }

    // Check frequency
    switch (medicine.schedule.frequency) {
      case FrequencyType.everyday:
        return true;
      case FrequencyType.specificDays:
        // DateTime.weekday is 1 (Mon) - 7 (Sun)
        return medicine.schedule.specificDays.contains(date.weekday);
      case FrequencyType.everyOtherDay:
        final diff = targetDate.difference(startDate).inDays;
        return diff % 2 == 0;
      case FrequencyType.asNeeded:
        return false;
    }
  }

  Map<DateTime, DayComplianceSummary> computeMonthlyDaySummaries({
    required List<MedicineEntity> medicines,
    required List<DoseLogEntity> allLogs,
    required int year,
    required int month,
  }) {
    final Map<DateTime, DayComplianceSummary> summaries = {};
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);

      // Find all scheduled doses for this day
      int totalScheduled = 0;
      for (final med in medicines) {
        if (_isMedicineScheduledOnDay(med, date)) {
          totalScheduled += med.schedule.times.length;
        }
      }

      // Find logs for this day
      final dayLogs = allLogs.where((l) {
        return l.scheduledDate.year == year &&
            l.scheduledDate.month == month &&
            l.scheduledDate.day == day;
      }).toList();

      final takenCount = dayLogs.where((l) => l.status == DoseStatus.taken).length;
      final skippedCount = dayLogs.where((l) => l.status == DoseStatus.skipped).length;
      final snoozedCount = dayLogs.where((l) => l.status == DoseStatus.snoozed).length;

      // In case user logged more taken doses than statically scheduled
      final effectiveTotal = totalScheduled < (takenCount + skippedCount)
          ? (takenCount + skippedCount)
          : totalScheduled;

      summaries[date] = DayComplianceSummary(
        date: date,
        totalDoses: effectiveTotal,
        takenDoses: takenCount,
        skippedDoses: skippedCount,
        snoozedDoses: snoozedCount,
        logs: dayLogs,
      );
    }

    return summaries;
  }

  AdherenceStatsEntity calculateStats({
    required List<MedicineEntity> medicines,
    required List<DoseLogEntity> allLogs,
    required int year,
    required int month,
  }) {
    final now = DateTime.now();
    final isCurrentMonth = now.year == year && now.month == month;
    final maxDay = isCurrentMonth ? now.day : DateTime(year, month + 1, 0).day;

    final summaries = computeMonthlyDaySummaries(
      medicines: medicines,
      allLogs: allLogs,
      year: year,
      month: month,
    );

    int totalScheduled = 0;
    int takenCount = 0;
    int skippedCount = 0;
    int snoozedCount = 0;

    for (int day = 1; day <= maxDay; day++) {
      final date = DateTime(year, month, day);
      final summary = summaries[date];
      if (summary != null) {
        totalScheduled += summary.totalDoses;
        takenCount += summary.takenDoses;
        skippedCount += summary.skippedDoses;
        snoozedCount += summary.snoozedDoses;
      }
    }

    final double rate = totalScheduled > 0
        ? (takenCount / totalScheduled).clamp(0.0, 1.0)
        : (takenCount > 0 ? 1.0 : 1.0);

    // Calculate current streak (consecutive days with 0 skipped and >0 taken up to today)
    int currentStreak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    while (true) {
      final dayLogs = allLogs.where((l) =>
          l.scheduledDate.year == checkDate.year &&
          l.scheduledDate.month == checkDate.month &&
          l.scheduledDate.day == checkDate.day).toList();

      final taken = dayLogs.where((l) => l.status == DoseStatus.taken).length;
      final skipped = dayLogs.where((l) => l.status == DoseStatus.skipped).length;

      // If today and no logs yet, don't break streak from yesterday
      if (checkDate.year == now.year &&
          checkDate.month == now.month &&
          checkDate.day == now.day &&
          dayLogs.isEmpty) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      if (skipped > 0 || (dayLogs.isNotEmpty && taken == 0)) {
        break;
      }

      if (taken > 0) {
        currentStreak++;
      } else {
        // No meds on that day, if past 30 days stop
        if (now.difference(checkDate).inDays > 30) break;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
      if (currentStreak > 365) break;
    }

    return AdherenceStatsEntity(
      totalScheduled: totalScheduled,
      takenCount: takenCount,
      skippedCount: skippedCount,
      snoozedCount: snoozedCount,
      adherenceRate: rate,
      currentStreakDays: currentStreak,
      longestStreakDays: currentStreak, // or max computed
    );
  }
}
