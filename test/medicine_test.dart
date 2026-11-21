import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';
import 'package:medico/features/medicine/data/models/medicine_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('Medicine Entity & Model tests', () {
    test('converts MedicineEntity to MedicineModel and back correctly', () {
      final entity = MedicineEntity(
        id: 'test-id-123',
        name: 'Pregabalin',
        purpose: 'Nerve pain',
        type: MedicineType.capsule,
        strength: '75mg',
        doseQuantity: 1,
        doseUnit: 'capsule',
        schedule: const MedicineScheduleEntity(
          frequency: FrequencyType.everyday,
          times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
        ),
        duration: CourseDurationEntity(
          durationType: CourseDurationType.days,
          daysCount: 10,
        ),
        instructions: ['With food', 'With water'],
        stockRemaining: 30,
        refillAlertThreshold: 5,
        isPaused: false,
      );

      final model = MedicineModel.fromEntity(entity);
      expect(model.name, 'Pregabalin');
      expect(model.type, 'capsule');
      expect(model.schedule.times, ['08:00', '20:00']);
      expect(model.stockRemaining, 30);
      expect(model.isPaused, false);

      final convertedEntity = model.toEntity();
      expect(convertedEntity.name, 'Pregabalin');
      expect(convertedEntity.type, MedicineType.capsule);
      expect(convertedEntity.schedule.times.length, 2);
      expect(convertedEntity.schedule.times.first.hour, 8);
      expect(convertedEntity.instructions, ['With food', 'With water']);
      expect(convertedEntity.stockRemaining, 30);
      expect(convertedEntity.isLowStock, false);
    });

    test('calculates course progress ratio and low stock correctly', () {
      final entity = MedicineEntity(
        id: 'test-2',
        name: 'Amoxicillin',
        type: MedicineType.capsule,
        doseQuantity: 1,
        doseUnit: 'capsule',
        schedule: const MedicineScheduleEntity(
          times: [TimeOfDay(hour: 9, minute: 0)],
        ),
        duration: CourseDurationEntity(
          durationType: CourseDurationType.days,
          daysCount: 10,
          startDate: DateTime.now().subtract(const Duration(days: 4)),
        ),
        stockRemaining: 3,
        refillAlertThreshold: 5,
      );

      expect(entity.daysElapsed, 5);
      expect(entity.courseProgressRatio, 0.5);
      expect(entity.isLowStock, true);
    });
  });
}
