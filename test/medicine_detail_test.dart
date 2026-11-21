import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/dose_tracking/domain/entities/dose_log_entity.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medico/features/medicine/presentation/widgets/course_hero_card.dart';
import 'package:medico/features/medicine/presentation/widgets/metadata_chips_row.dart';
import 'package:medico/features/medicine/presentation/widgets/stock_refill_card.dart';
import 'package:medico/features/medicine/presentation/widgets/upcoming_schedule_section.dart';

void main() {
  final testMedicine = MedicineEntity(
    id: 'test_med_1',
    name: 'Pregabalin',
    purpose: 'Lower back pain',
    type: MedicineType.capsule,
    strength: '50 mg',
    doseQuantity: 1,
    doseUnit: 'capsule',
    schedule: MedicineScheduleEntity(
      frequency: FrequencyType.everyday,
      times: [
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 21, minute: 0),
      ],
    ),
    duration: CourseDurationEntity(
      durationType: CourseDurationType.days,
      daysCount: 14,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    instructions: ['After meal'],
    stockRemaining: 20,
    refillAlertThreshold: 5,
    createdAt: DateTime.now(),
  );

  group('UpcomingScheduleSection computeUpcomingSlots Tests', () {
    test('computes next upcoming slots correctly and tags slot 0 as isImmediateNext', () {
      final slots = UpcomingScheduleSection.computeUpcomingSlots(testMedicine, []);

      expect(slots.isNotEmpty, isTrue);
      expect(slots.first.isImmediateNext, isTrue);
      if (slots.length > 1) {
        expect(slots[1].isImmediateNext, isFalse);
      }
    });

    test('skips taken doses and advances to subsequent dose', () {
      final today = DateTime.now();
      final logs = [
        DoseLogEntity(
          id: 'log_1',
          medicineId: testMedicine.id,
          medicineName: testMedicine.name,
          doseQuantity: 1,
          doseUnit: 'capsule',
          scheduledDate: DateTime(today.year, today.month, today.day),
          scheduledTime: '09:00',
          status: DoseStatus.taken,
        ),
      ];

      final slots = UpcomingScheduleSection.computeUpcomingSlots(testMedicine, logs);
      expect(slots.any((s) => s.originalTime == '09:00' && s.dayLabel.contains('day')), isFalse);
    });
  });

  group('Medicine Detail Widgets Rendering', () {
    testWidgets('MetadataChipsRow renders strength, purpose, and instructions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetadataChipsRow(medicine: testMedicine),
          ),
        ),
      );

      expect(find.text('50 mg capsule'), findsOneWidget);
      expect(find.text('Lower back pain'), findsOneWidget);
      expect(find.text('After meal'), findsOneWidget);
    });

    testWidgets('CourseHeroCard renders Course fraction and days left', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseHeroCard(medicine: testMedicine),
          ),
        ),
      );

      expect(find.text('Course'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('/ 14 days'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('days left'), findsOneWidget);
    });

    testWidgets('StockRefillCard renders stock count and Refill button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StockRefillCard(medicine: testMedicine),
            ),
          ),
        ),
      );

      expect(find.text('Supply & Refill'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('Refill'), findsOneWidget);
    });
  });
}
