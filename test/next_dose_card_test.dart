import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';
import 'package:medico/features/today/presentation/widgets/next_dose_card.dart';

void main() {
  testWidgets('NextDoseCard renders matching reference structure with big clock, pills and buttons', (tester) async {
    final medicine = MedicineEntity(
      id: 'test_1',
      name: 'Diuretic',
      purpose: 'Blood pressure',
      type: MedicineType.capsule,
      doseQuantity: 1,
      doseUnit: 'capsule',
      schedule: const MedicineScheduleEntity(
        times: [TimeOfDay(hour: 10, minute: 25)],
      ),
      duration: CourseDurationEntity(durationType: CourseDurationType.ongoing),
      instructions: ['With water'],
    );

    bool takenCalled = false;
    bool snoozeCalled = false;
    bool skipCalled = false;
    bool editCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NextDoseCard(
              medicine: medicine,
              doseTime: const TimeOfDay(hour: 10, minute: 25),
              onTaken: () => takenCalled = true,
              onSnooze: () => snoozeCalled = true,
              onSkip: () => skipCalled = true,
              onEditTime: () => editCalled = true,
              onToggleMute: () {},
            ),
          ),
        ),
      ),
    );

    // Verify NEXT DOSE badge
    expect(find.text('NEXT DOSE'), findsOneWidget);

    // Verify subtitle text: Diuretic • 1 dose (capsule)
    expect(find.text('Diuretic • 1 dose (capsule)'), findsOneWidget);

    // Verify Giant Clock
    expect(find.text('10:25'), findsOneWidget);
    expect(find.text('AM'), findsOneWidget);

    // Verify instruction and period tag
    expect(find.text('With water - Morning'), findsOneWidget);

    // Verify buttons
    expect(find.text('Taken'), findsOneWidget);
    expect(find.text('Snooze'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // Verify interactions
    await tester.tap(find.text('Taken'));
    expect(takenCalled, isTrue);

    await tester.tap(find.text('Snooze'));
    expect(snoozeCalled, isTrue);

    await tester.tap(find.text('Skip'));
    expect(skipCalled, isTrue);

    await tester.tap(find.text('Edit'));
    expect(editCalled, isTrue);
  });
}
