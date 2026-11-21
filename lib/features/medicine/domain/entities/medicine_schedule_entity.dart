import 'package:flutter/material.dart';

enum FrequencyType {
  everyday,
  specificDays,
  everyOtherDay,
  asNeeded;

  String get displayName {
    switch (this) {
      case FrequencyType.everyday:
        return 'Every day';
      case FrequencyType.specificDays:
        return 'Specific days';
      case FrequencyType.everyOtherDay:
        return 'Every other day';
      case FrequencyType.asNeeded:
        return 'As needed';
    }
  }

  static FrequencyType fromString(String? value) {
    return FrequencyType.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => FrequencyType.everyday,
    );
  }
}

class MedicineScheduleEntity {
  final FrequencyType frequency;
  final List<int> specificDays; // 1 = Monday, ..., 7 = Sunday
  final List<TimeOfDay> times;

  const MedicineScheduleEntity({
    this.frequency = FrequencyType.everyday,
    this.specificDays = const [],
    required this.times,
  });

  MedicineScheduleEntity copyWith({
    FrequencyType? frequency,
    List<int>? specificDays,
    List<TimeOfDay>? times,
  }) {
    return MedicineScheduleEntity(
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      times: times ?? this.times,
    );
  }
}
