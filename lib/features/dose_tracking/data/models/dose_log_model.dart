import 'package:hive/hive.dart';
import '../../domain/entities/dose_log_entity.dart';

class DoseLogModel {
  final String id;
  final String medicineId;
  final String medicineName;
  final num doseQuantity;
  final String doseUnit;
  final String scheduledDate; // ISO8601 YYYY-MM-DD
  final String scheduledTime; // "HH:mm"
  final String status;
  final String? actualActionTime;
  final String? snoozeUntilTime;
  final String? skipReason;
  final bool isAlarmMuted;
  final String? customTime;

  DoseLogModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.doseQuantity,
    required this.doseUnit,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    this.actualActionTime,
    this.snoozeUntilTime,
    this.skipReason,
    this.isAlarmMuted = false,
    this.customTime,
  });

  DoseLogEntity toEntity() {
    return DoseLogEntity(
      id: id,
      medicineId: medicineId,
      medicineName: medicineName,
      doseQuantity: doseQuantity,
      doseUnit: doseUnit,
      scheduledDate: DateTime.tryParse(scheduledDate) ?? DateTime.now(),
      scheduledTime: scheduledTime,
      status: DoseStatus.fromString(status),
      actualActionTime: actualActionTime != null ? DateTime.tryParse(actualActionTime!) : null,
      snoozeUntilTime: snoozeUntilTime != null ? DateTime.tryParse(snoozeUntilTime!) : null,
      skipReason: skipReason,
      isAlarmMuted: isAlarmMuted,
      customTime: customTime,
    );
  }

  factory DoseLogModel.fromEntity(DoseLogEntity entity) {
    return DoseLogModel(
      id: entity.id,
      medicineId: entity.medicineId,
      medicineName: entity.medicineName,
      doseQuantity: entity.doseQuantity,
      doseUnit: entity.doseUnit,
      scheduledDate: DateTime(
        entity.scheduledDate.year,
        entity.scheduledDate.month,
        entity.scheduledDate.day,
      ).toIso8601String(),
      scheduledTime: entity.scheduledTime,
      status: entity.status.name,
      actualActionTime: entity.actualActionTime?.toIso8601String(),
      snoozeUntilTime: entity.snoozeUntilTime?.toIso8601String(),
      skipReason: entity.skipReason,
      isAlarmMuted: entity.isAlarmMuted,
      customTime: entity.customTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'doseQuantity': doseQuantity,
      'doseUnit': doseUnit,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'status': status,
      'actualActionTime': actualActionTime,
      'snoozeUntilTime': snoozeUntilTime,
      'skipReason': skipReason,
      'isAlarmMuted': isAlarmMuted,
      'customTime': customTime,
    };
  }

  factory DoseLogModel.fromMap(Map<dynamic, dynamic> map) {
    return DoseLogModel(
      id: (map['id'] as String?) ?? '',
      medicineId: (map['medicineId'] as String?) ?? '',
      medicineName: (map['medicineName'] as String?) ?? '',
      doseQuantity: (map['doseQuantity'] as num?) ?? 1,
      doseUnit: (map['doseUnit'] as String?) ?? 'capsule',
      scheduledDate: (map['scheduledDate'] as String?) ?? DateTime.now().toIso8601String(),
      scheduledTime: (map['scheduledTime'] as String?) ?? '08:00',
      status: (map['status'] as String?) ?? 'pending',
      actualActionTime: map['actualActionTime'] as String?,
      snoozeUntilTime: map['snoozeUntilTime'] as String?,
      skipReason: map['skipReason'] as String?,
      isAlarmMuted: (map['isAlarmMuted'] as bool?) ?? false,
      customTime: map['customTime'] as String?,
    );
  }
}

class DoseLogModelAdapter extends TypeAdapter<DoseLogModel> {
  @override
  final int typeId = 3;

  @override
  DoseLogModel read(BinaryReader reader) {
    final map = reader.readMap();
    return DoseLogModel.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, DoseLogModel obj) {
    writer.writeMap(obj.toMap());
  }
}
