import 'package:hive/hive.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/entities/medicine_type.dart';
import 'medicine_schedule_model.dart';
import 'course_duration_model.dart';

class MedicineModel {
  final String id;
  final String name;
  final String? purpose;
  final String type;
  final String? strength;
  final num doseQuantity;
  final String doseUnit;
  final MedicineScheduleModel schedule;
  final CourseDurationModel duration;
  final List<String> instructions;
  final String? photoPath;
  final String createdAt;
  final bool isActive;
  final int? stockRemaining;
  final int? refillAlertThreshold;
  final bool isPaused;

  MedicineModel({
    required this.id,
    required this.name,
    this.purpose,
    required this.type,
    this.strength,
    required this.doseQuantity,
    required this.doseUnit,
    required this.schedule,
    required this.duration,
    this.instructions = const [],
    this.photoPath,
    required this.createdAt,
    this.isActive = true,
    this.stockRemaining,
    this.refillAlertThreshold = 5,
    this.isPaused = false,
  });

  MedicineEntity toEntity() {
    return MedicineEntity(
      id: id,
      name: name,
      purpose: purpose,
      type: MedicineType.fromString(type),
      strength: strength,
      doseQuantity: doseQuantity,
      doseUnit: doseUnit,
      schedule: schedule.toEntity(),
      duration: duration.toEntity(),
      instructions: instructions,
      photoPath: photoPath,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      isActive: isActive,
      stockRemaining: stockRemaining,
      refillAlertThreshold: refillAlertThreshold,
      isPaused: isPaused,
    );
  }

  factory MedicineModel.fromEntity(MedicineEntity entity) {
    return MedicineModel(
      id: entity.id,
      name: entity.name,
      purpose: entity.purpose,
      type: entity.type.name,
      strength: entity.strength,
      doseQuantity: entity.doseQuantity,
      doseUnit: entity.doseUnit,
      schedule: MedicineScheduleModel.fromEntity(entity.schedule),
      duration: CourseDurationModel.fromEntity(entity.duration),
      instructions: entity.instructions,
      photoPath: entity.photoPath,
      createdAt: entity.createdAt.toIso8601String(),
      isActive: entity.isActive,
      stockRemaining: entity.stockRemaining,
      refillAlertThreshold: entity.refillAlertThreshold,
      isPaused: entity.isPaused,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purpose': purpose,
      'type': type,
      'strength': strength,
      'doseQuantity': doseQuantity,
      'doseUnit': doseUnit,
      'schedule': schedule.toMap(),
      'duration': duration.toMap(),
      'instructions': instructions,
      'photoPath': photoPath,
      'createdAt': createdAt,
      'isActive': isActive,
      'stockRemaining': stockRemaining,
      'refillAlertThreshold': refillAlertThreshold,
      'isPaused': isPaused,
    };
  }

  factory MedicineModel.fromMap(Map<dynamic, dynamic> map) {
    return MedicineModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      purpose: map['purpose'] as String?,
      type: (map['type'] as String?) ?? 'tablet',
      strength: map['strength'] as String?,
      doseQuantity: (map['doseQuantity'] as num?) ?? 1,
      doseUnit: (map['doseUnit'] as String?) ?? 'tablet',
      schedule: MedicineScheduleModel.fromMap(
        Map<dynamic, dynamic>.from(map['schedule'] ?? {}),
      ),
      duration: CourseDurationModel.fromMap(
        Map<dynamic, dynamic>.from(map['duration'] ?? {}),
      ),
      instructions: List<String>.from(map['instructions'] ?? []),
      photoPath: map['photoPath'] as String?,
      createdAt: (map['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
      isActive: (map['isActive'] as bool?) ?? true,
      stockRemaining: map['stockRemaining'] as int?,
      refillAlertThreshold: (map['refillAlertThreshold'] as int?) ?? 5,
      isPaused: (map['isPaused'] as bool?) ?? false,
    );
  }
}

class MedicineModelAdapter extends TypeAdapter<MedicineModel> {
  @override
  final int typeId = 0;

  @override
  MedicineModel read(BinaryReader reader) {
    final map = reader.readMap();
    return MedicineModel.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, MedicineModel obj) {
    writer.writeMap(obj.toMap());
  }
}
