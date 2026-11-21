import 'package:hive/hive.dart';
import '../../domain/entities/course_duration_entity.dart';

class CourseDurationModel {
  final String durationType;
  final int? daysCount;
  final String startDate; // ISO8601
  final String? endDate; // ISO8601

  CourseDurationModel({
    required this.durationType,
    this.daysCount,
    required this.startDate,
    this.endDate,
  });

  CourseDurationEntity toEntity() {
    return CourseDurationEntity(
      durationType: CourseDurationType.fromString(durationType),
      daysCount: daysCount,
      startDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
    );
  }

  factory CourseDurationModel.fromEntity(CourseDurationEntity entity) {
    return CourseDurationModel(
      durationType: entity.durationType.name,
      daysCount: entity.daysCount,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'durationType': durationType,
      'daysCount': daysCount,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  factory CourseDurationModel.fromMap(Map<dynamic, dynamic> map) {
    return CourseDurationModel(
      durationType: (map['durationType'] as String?) ?? 'ongoing',
      daysCount: map['daysCount'] as int?,
      startDate: (map['startDate'] as String?) ?? DateTime.now().toIso8601String(),
      endDate: map['endDate'] as String?,
    );
  }
}

class CourseDurationModelAdapter extends TypeAdapter<CourseDurationModel> {
  @override
  final int typeId = 2;

  @override
  CourseDurationModel read(BinaryReader reader) {
    final map = reader.readMap();
    return CourseDurationModel.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, CourseDurationModel obj) {
    writer.writeMap(obj.toMap());
  }
}
