import 'medicine_type.dart';
import 'medicine_schedule_entity.dart';
import 'course_duration_entity.dart';

class MedicineEntity {
  final String id;
  final String name;
  final String? purpose; // e.g. "What it's for" / "Nerve pain"
  final MedicineType type;
  final String? strength; // e.g. "75mg"
  final num doseQuantity; // e.g. 1
  final String doseUnit; // e.g. "capsule"
  final MedicineScheduleEntity schedule;
  final CourseDurationEntity duration;
  final List<String> instructions; // e.g. ["With food", "With water"]
  final String? photoPath;
  final DateTime createdAt;
  final bool isActive;
  final int? stockRemaining;
  final int? refillAlertThreshold;
  final bool isPaused;

  MedicineEntity({
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
    DateTime? createdAt,
    this.isActive = true,
    this.stockRemaining,
    this.refillAlertThreshold = 5,
    this.isPaused = false,
  }) : createdAt = createdAt ?? DateTime.now();

  int get daysElapsed {
    final diff = DateTime.now().difference(duration.startDate).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  double? get courseProgressRatio {
    if (duration.durationType == CourseDurationType.days &&
        duration.daysCount != null &&
        duration.daysCount! > 0) {
      final ratio = daysElapsed / duration.daysCount!;
      return ratio.clamp(0.0, 1.0);
    }
    return null;
  }

  bool get isLowStock =>
      stockRemaining != null && stockRemaining! <= (refillAlertThreshold ?? 5);

  MedicineEntity copyWith({
    String? id,
    String? name,
    String? purpose,
    MedicineType? type,
    String? strength,
    num? doseQuantity,
    String? doseUnit,
    MedicineScheduleEntity? schedule,
    CourseDurationEntity? duration,
    List<String>? instructions,
    String? photoPath,
    DateTime? createdAt,
    bool? isActive,
    int? stockRemaining,
    int? refillAlertThreshold,
    bool? isPaused,
  }) {
    return MedicineEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      doseUnit: doseUnit ?? this.doseUnit,
      schedule: schedule ?? this.schedule,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      stockRemaining: stockRemaining ?? this.stockRemaining,
      refillAlertThreshold: refillAlertThreshold ?? this.refillAlertThreshold,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
