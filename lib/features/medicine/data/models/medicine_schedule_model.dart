import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/medicine_schedule_entity.dart';

class MedicineScheduleModel {
  final String frequency;
  final List<int> specificDays;
  final List<String> times; // Stored as "HH:mm"

  MedicineScheduleModel({
    required this.frequency,
    required this.specificDays,
    required this.times,
  });

  MedicineScheduleEntity toEntity() {
    return MedicineScheduleEntity(
      frequency: FrequencyType.fromString(frequency),
      specificDays: specificDays,
      times: times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }).toList(),
    );
  }

  factory MedicineScheduleModel.fromEntity(MedicineScheduleEntity entity) {
    return MedicineScheduleModel(
      frequency: entity.frequency.name,
      specificDays: entity.specificDays,
      times: entity.times.map((t) {
        final h = t.hour.toString().padLeft(2, '0');
        final m = t.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'specificDays': specificDays,
      'times': times,
    };
  }

  factory MedicineScheduleModel.fromMap(Map<dynamic, dynamic> map) {
    return MedicineScheduleModel(
      frequency: (map['frequency'] as String?) ?? 'everyday',
      specificDays: List<int>.from(map['specificDays'] ?? []),
      times: List<String>.from(map['times'] ?? []),
    );
  }
}

class MedicineScheduleModelAdapter extends TypeAdapter<MedicineScheduleModel> {
  @override
  final int typeId = 1;

  @override
  MedicineScheduleModel read(BinaryReader reader) {
    final map = reader.readMap();
    return MedicineScheduleModel.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, MedicineScheduleModel obj) {
    writer.writeMap(obj.toMap());
  }
}
