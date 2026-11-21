enum DoseStatus {
  pending,
  taken,
  snoozed,
  skipped;

  String get displayName {
    switch (this) {
      case DoseStatus.pending:
        return 'Pending';
      case DoseStatus.taken:
        return 'Taken';
      case DoseStatus.snoozed:
        return 'Snoozed';
      case DoseStatus.skipped:
        return 'Skipped';
    }
  }

  static DoseStatus fromString(String? value) {
    return DoseStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => DoseStatus.pending,
    );
  }
}

class DoseLogEntity {
  final String id;
  final String medicineId;
  final String medicineName;
  final num doseQuantity;
  final String doseUnit;
  final DateTime scheduledDate; // Normalized to year, month, day
  final String scheduledTime; // "HH:mm" e.g. "08:00"
  final DoseStatus status;
  final DateTime? actualActionTime;
  final DateTime? snoozeUntilTime;
  final String? skipReason;
  final bool isAlarmMuted;
  final String? customTime; // If overridden for today

  DoseLogEntity({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.doseQuantity,
    required this.doseUnit,
    required this.scheduledDate,
    required this.scheduledTime,
    this.status = DoseStatus.pending,
    this.actualActionTime,
    this.snoozeUntilTime,
    this.skipReason,
    this.isAlarmMuted = false,
    this.customTime,
  });

  DoseLogEntity copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    num? doseQuantity,
    String? doseUnit,
    DateTime? scheduledDate,
    String? scheduledTime,
    DoseStatus? status,
    DateTime? actualActionTime,
    DateTime? snoozeUntilTime,
    String? skipReason,
    bool? isAlarmMuted,
    String? customTime,
  }) {
    return DoseLogEntity(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      doseUnit: doseUnit ?? this.doseUnit,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      actualActionTime: actualActionTime ?? this.actualActionTime,
      snoozeUntilTime: snoozeUntilTime ?? this.snoozeUntilTime,
      skipReason: skipReason ?? this.skipReason,
      isAlarmMuted: isAlarmMuted ?? this.isAlarmMuted,
      customTime: customTime ?? this.customTime,
    );
  }
}
