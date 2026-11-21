import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import '../../../medicine/domain/repositories/medicine_repository.dart';
import '../entities/dose_log_entity.dart';
import '../repositories/dose_repository.dart';

class MarkDoseTakenUseCase {
  final DoseRepository doseRepository;
  final MedicineRepository medicineRepository;

  MarkDoseTakenUseCase({
    required this.doseRepository,
    required this.medicineRepository,
  });

  Future<DoseLogEntity> call({
    required MedicineEntity medicine,
    required DateTime date,
    required String scheduledTime,
  }) async {
    final existing = await doseRepository.getDoseLog(medicine.id, date, scheduledTime);
    final logId = existing?.id ?? IdGenerator.generate();

    final log = DoseLogEntity(
      id: logId,
      medicineId: medicine.id,
      medicineName: medicine.name,
      doseQuantity: medicine.doseQuantity,
      doseUnit: medicine.doseUnit,
      scheduledDate: DateTime(date.year, date.month, date.day),
      scheduledTime: scheduledTime,
      status: DoseStatus.taken,
      actualActionTime: DateTime.now(),
      isAlarmMuted: existing?.isAlarmMuted ?? false,
      customTime: existing?.customTime,
    );

    await doseRepository.saveDoseLog(log);

    // Deduct stock if tracked
    if (medicine.stockRemaining != null) {
      final remaining = medicine.stockRemaining! - medicine.doseQuantity.toInt();
      final updatedMedicine = medicine.copyWith(
        stockRemaining: remaining < 0 ? 0 : remaining,
      );
      await medicineRepository.updateMedicine(updatedMedicine);
    }

    // Cancel notification
    final notifId = getNotificationId(medicine.id, scheduledTime);
    await NotificationService.instance.cancelReminder(notifId);

    return log;
  }
}

class UndoDoseUseCase {
  final DoseRepository doseRepository;
  final MedicineRepository medicineRepository;

  UndoDoseUseCase({
    required this.doseRepository,
    required this.medicineRepository,
  });

  Future<void> call({
    required DoseLogEntity log,
    required MedicineEntity medicine,
  }) async {
    // If it was taken, restore the stock
    if (log.status == DoseStatus.taken && medicine.stockRemaining != null) {
      final restored = medicine.stockRemaining! + log.doseQuantity.toInt();
      final updated = medicine.copyWith(stockRemaining: restored);
      await medicineRepository.updateMedicine(updated);
    }

    // Delete or reset log
    await doseRepository.deleteDoseLog(log.id);

    // Re-schedule reminder if needed
    final parts = (log.customTime ?? log.scheduledTime).split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      final scheduledDateTime = DateTime(
        log.scheduledDate.year,
        log.scheduledDate.month,
        log.scheduledDate.day,
        hour,
        minute,
      );

      final notifId = getNotificationId(medicine.id, log.scheduledTime);
      await NotificationService.instance.scheduleDoseReminder(
        id: notifId,
        title: 'Time for ${medicine.name}',
        body: 'Take ${medicine.doseQuantity} ${medicine.doseUnit}',
        scheduledDateTime: scheduledDateTime,
        isMuted: log.isAlarmMuted,
      );
    }
  }
}

class SnoozeDoseUseCase {
  final DoseRepository doseRepository;

  SnoozeDoseUseCase(this.doseRepository);

  Future<DoseLogEntity> call({
    required MedicineEntity medicine,
    required DateTime date,
    required String scheduledTime,
    required Duration duration,
  }) async {
    final existing = await doseRepository.getDoseLog(medicine.id, date, scheduledTime);
    final logId = existing?.id ?? IdGenerator.generate();
    final snoozeUntil = DateTime.now().add(duration);

    final log = DoseLogEntity(
      id: logId,
      medicineId: medicine.id,
      medicineName: medicine.name,
      doseQuantity: medicine.doseQuantity,
      doseUnit: medicine.doseUnit,
      scheduledDate: DateTime(date.year, date.month, date.day),
      scheduledTime: scheduledTime,
      status: DoseStatus.snoozed,
      snoozeUntilTime: snoozeUntil,
      isAlarmMuted: existing?.isAlarmMuted ?? false,
      customTime: existing?.customTime,
    );

    await doseRepository.saveDoseLog(log);

    // Schedule snooze alert
    final notifId = getNotificationId(medicine.id, scheduledTime);
    await NotificationService.instance.scheduleDoseReminder(
      id: notifId,
      title: 'Snoozed: Time for ${medicine.name}',
      body: 'Take ${medicine.doseQuantity} ${medicine.doseUnit}',
      scheduledDateTime: snoozeUntil,
      isMuted: log.isAlarmMuted,
    );

    return log;
  }
}

class SkipDoseUseCase {
  final DoseRepository doseRepository;

  SkipDoseUseCase(this.doseRepository);

  Future<DoseLogEntity> call({
    required MedicineEntity medicine,
    required DateTime date,
    required String scheduledTime,
    required String reason,
  }) async {
    final existing = await doseRepository.getDoseLog(medicine.id, date, scheduledTime);
    final logId = existing?.id ?? IdGenerator.generate();

    final log = DoseLogEntity(
      id: logId,
      medicineId: medicine.id,
      medicineName: medicine.name,
      doseQuantity: medicine.doseQuantity,
      doseUnit: medicine.doseUnit,
      scheduledDate: DateTime(date.year, date.month, date.day),
      scheduledTime: scheduledTime,
      status: DoseStatus.skipped,
      actualActionTime: DateTime.now(),
      skipReason: reason,
      isAlarmMuted: existing?.isAlarmMuted ?? false,
      customTime: existing?.customTime,
    );

    await doseRepository.saveDoseLog(log);

    // Cancel notification
    final notifId = getNotificationId(medicine.id, scheduledTime);
    await NotificationService.instance.cancelReminder(notifId);

    return log;
  }
}

class ToggleDoseMuteUseCase {
  final DoseRepository doseRepository;

  ToggleDoseMuteUseCase(this.doseRepository);

  Future<DoseLogEntity> call({
    required MedicineEntity medicine,
    required DateTime date,
    required String scheduledTime,
  }) async {
    final existing = await doseRepository.getDoseLog(medicine.id, date, scheduledTime);
    final logId = existing?.id ?? IdGenerator.generate();
    final newMuted = !(existing?.isAlarmMuted ?? false);

    final log = DoseLogEntity(
      id: logId,
      medicineId: medicine.id,
      medicineName: medicine.name,
      doseQuantity: medicine.doseQuantity,
      doseUnit: medicine.doseUnit,
      scheduledDate: DateTime(date.year, date.month, date.day),
      scheduledTime: scheduledTime,
      status: existing?.status ?? DoseStatus.pending,
      actualActionTime: existing?.actualActionTime,
      snoozeUntilTime: existing?.snoozeUntilTime,
      skipReason: existing?.skipReason,
      isAlarmMuted: newMuted,
      customTime: existing?.customTime,
    );

    await doseRepository.saveDoseLog(log);

    // Re-schedule reminder with updated mute flag
    final parts = (log.customTime ?? log.scheduledTime).split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      final scheduledDateTime = DateTime(
        log.scheduledDate.year,
        log.scheduledDate.month,
        log.scheduledDate.day,
        hour,
        minute,
      );

      final notifId = getNotificationId(medicine.id, log.scheduledTime);
      await NotificationService.instance.scheduleDoseReminder(
        id: notifId,
        title: 'Time for ${medicine.name}',
        body: 'Take ${medicine.doseQuantity} ${medicine.doseUnit}',
        scheduledDateTime: scheduledDateTime,
        isMuted: newMuted,
      );
    }

    return log;
  }
}

class UpdateDoseTimeForTodayUseCase {
  final DoseRepository doseRepository;

  UpdateDoseTimeForTodayUseCase(this.doseRepository);

  Future<DoseLogEntity> call({
    required MedicineEntity medicine,
    required DateTime date,
    required String originalScheduledTime,
    required String newTime24, // "HH:mm"
  }) async {
    final existing = await doseRepository.getDoseLog(medicine.id, date, originalScheduledTime);
    final logId = existing?.id ?? IdGenerator.generate();

    final log = DoseLogEntity(
      id: logId,
      medicineId: medicine.id,
      medicineName: medicine.name,
      doseQuantity: medicine.doseQuantity,
      doseUnit: medicine.doseUnit,
      scheduledDate: DateTime(date.year, date.month, date.day),
      scheduledTime: originalScheduledTime,
      status: existing?.status ?? DoseStatus.pending,
      actualActionTime: existing?.actualActionTime,
      snoozeUntilTime: existing?.snoozeUntilTime,
      skipReason: existing?.skipReason,
      isAlarmMuted: existing?.isAlarmMuted ?? false,
      customTime: newTime24,
    );

    await doseRepository.saveDoseLog(log);

    // Re-schedule reminder for new time
    final parts = newTime24.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      final notifId = getNotificationId(medicine.id, originalScheduledTime);
      await NotificationService.instance.scheduleDoseReminder(
        id: notifId,
        title: 'Time for ${medicine.name}',
        body: 'Take ${medicine.doseQuantity} ${medicine.doseUnit}',
        scheduledDateTime: scheduledDateTime,
        isMuted: log.isAlarmMuted,
      );
    }

    return log;
  }
}
