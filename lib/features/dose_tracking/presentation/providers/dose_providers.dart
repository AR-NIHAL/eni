import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import '../../../medicine/presentation/providers/medicine_providers.dart';
import '../../data/datasources/dose_local_datasource.dart';
import '../../data/repositories/dose_repository_impl.dart';
import '../../domain/entities/dose_log_entity.dart';
import '../../domain/repositories/dose_repository.dart';
import '../../domain/usecases/dose_usecases.dart';

// --- Data & Repo Providers ---

final doseLocalDataSourceProvider = Provider<DoseLocalDataSource>((ref) {
  return DoseLocalDataSourceImpl();
});

final doseRepositoryProvider = Provider<DoseRepository>((ref) {
  final ds = ref.watch(doseLocalDataSourceProvider);
  return DoseRepositoryImpl(localDataSource: ds);
});

// --- UseCase Providers ---

final markDoseTakenUseCaseProvider = Provider<MarkDoseTakenUseCase>((ref) {
  final doseRepo = ref.watch(doseRepositoryProvider);
  final medRepo = ref.watch(medicineRepositoryProvider);
  return MarkDoseTakenUseCase(doseRepository: doseRepo, medicineRepository: medRepo);
});

final undoDoseUseCaseProvider = Provider<UndoDoseUseCase>((ref) {
  final doseRepo = ref.watch(doseRepositoryProvider);
  final medRepo = ref.watch(medicineRepositoryProvider);
  return UndoDoseUseCase(doseRepository: doseRepo, medicineRepository: medRepo);
});

final snoozeDoseUseCaseProvider = Provider<SnoozeDoseUseCase>((ref) {
  final doseRepo = ref.watch(doseRepositoryProvider);
  return SnoozeDoseUseCase(doseRepo);
});

final skipDoseUseCaseProvider = Provider<SkipDoseUseCase>((ref) {
  final doseRepo = ref.watch(doseRepositoryProvider);
  return SkipDoseUseCase(doseRepo);
});

final toggleDoseMuteUseCaseProvider = Provider<ToggleDoseMuteUseCase>((ref) {
  final doseRepo = ref.watch(doseRepositoryProvider);
  return ToggleDoseMuteUseCase(doseRepo);
});

final updateDoseTimeForTodayUseCaseProvider = Provider<UpdateDoseTimeForTodayUseCase>((ref) {
  final doseRepo = ref.watch(doseRepositoryProvider);
  return UpdateDoseTimeForTodayUseCase(doseRepo);
});

// Watch logs for a specific day
final dailyDoseLogsProvider = StreamProvider.family<List<DoseLogEntity>, DateTime>((ref, date) {
  final repo = ref.watch(doseRepositoryProvider);
  return repo.watchDoseLogsForDate(date);
});

// Watch logs for a specific medicine
final medicineDoseLogsProvider = StreamProvider.family<List<DoseLogEntity>, String>((ref, medicineId) {
  final repo = ref.watch(doseRepositoryProvider);
  return repo.watchDoseLogsForMedicine(medicineId);
});

// Model for an actionable scheduled dose
class ScheduledDoseItem {
  final MedicineEntity medicine;
  final String originalTime; // "HH:mm"
  final TimeOfDay effectiveTime; // If overridden or snoozed
  final DoseLogEntity? log;
  final bool isSnoozed;
  final DateTime? snoozedUntil;
  final bool isMuted;

  ScheduledDoseItem({
    required this.medicine,
    required this.originalTime,
    required this.effectiveTime,
    this.log,
    this.isSnoozed = false,
    this.snoozedUntil,
    this.isMuted = false,
  });

  bool get isTaken => log?.status == DoseStatus.taken;
  bool get isSkipped => log?.status == DoseStatus.skipped;
  bool get isPending => !isTaken && !isSkipped;
}

// Next upcoming dose calculation provider
final nextDoseItemProvider = Provider.family<ScheduledDoseItem?, DateTime>((ref, date) {
  final medicinesAsync = ref.watch(medicinesStreamProvider);
  final logsAsync = ref.watch(dailyDoseLogsProvider(date));

  final medicines = medicinesAsync.value ?? [];
  final logs = logsAsync.value ?? [];

  if (medicines.isEmpty) return null;

  final Map<String, DoseLogEntity> logMap = {
    for (var l in logs) '${l.medicineId}_${l.scheduledTime}': l
  };

  final List<ScheduledDoseItem> allDosesToday = [];

  for (final med in medicines) {
    if (!med.isActive || med.isPaused) continue;

    for (final t in med.schedule.times) {
      final timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      final log = logMap['${med.id}_$timeStr'];

      TimeOfDay effectiveTime = t;
      bool isSnoozed = false;
      DateTime? snoozedUntil;

      if (log != null) {
        if (log.status == DoseStatus.snoozed && log.snoozeUntilTime != null) {
          isSnoozed = true;
          snoozedUntil = log.snoozeUntilTime;
          effectiveTime = TimeOfDay(
            hour: log.snoozeUntilTime!.hour,
            minute: log.snoozeUntilTime!.minute,
          );
        } else if (log.customTime != null) {
          final parts = log.customTime!.split(':');
          if (parts.length >= 2) {
            effectiveTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? t.hour,
              minute: int.tryParse(parts[1]) ?? t.minute,
            );
          }
        }
      }

      allDosesToday.add(ScheduledDoseItem(
        medicine: med,
        originalTime: timeStr,
        effectiveTime: effectiveTime,
        log: log,
        isSnoozed: isSnoozed,
        snoozedUntil: snoozedUntil,
        isMuted: log?.isAlarmMuted ?? false,
      ));
    }
  }

  // Filter only pending or snoozed doses (exclude taken and skipped)
  final pendingDoses = allDosesToday.where((item) => item.isPending).toList();

  if (pendingDoses.isEmpty) return null;

  final now = TimeOfDay.now();
  final nowMins = now.hour * 60 + now.minute;

  // Sort by effective time
  pendingDoses.sort((a, b) {
    final aMins = a.effectiveTime.hour * 60 + a.effectiveTime.minute;
    final bMins = b.effectiveTime.hour * 60 + b.effectiveTime.minute;
    return aMins.compareTo(bMins);
  });

  // Find the first dose that is >= now or the earliest snoozed/upcoming dose
  for (final dose in pendingDoses) {
    final dMins = dose.effectiveTime.hour * 60 + dose.effectiveTime.minute;
    if (dMins >= nowMins || dose.isSnoozed) {
      return dose;
    }
  }

  // If all are earlier in the day but still pending, return the earliest pending one
  return pendingDoses.first;
});
