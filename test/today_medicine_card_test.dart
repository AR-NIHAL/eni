import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';
import 'package:medico/features/today/presentation/widgets/medicine_avatar_badge.dart';
import 'package:medico/features/today/presentation/widgets/today_medicine_card.dart';

void main() {
  group('TodayMedicineCard Widget Tests (Matching Reference Structure)', () {
    testWidgets('renders Bactrim card with 1 tablet · with water and 11:45 AM badge', (tester) async {
      final bactrim = MedicineEntity(
        id: 'med_bactrim',
        name: 'Bactrim',
        type: MedicineType.tablet,
        doseQuantity: 1,
        doseUnit: 'tablet',
        schedule: const MedicineScheduleEntity(
          times: [TimeOfDay(hour: 11, minute: 45)],
        ),
        duration: CourseDurationEntity(durationType: CourseDurationType.ongoing),
        instructions: ['with water'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayMedicineCard(
              medicine: bactrim,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Bactrim'), findsOneWidget);
      expect(find.text('1 tablet · with water'), findsOneWidget);
      expect(find.text('11:45 AM'), findsOneWidget);
      expect(find.byType(MedicineAvatarBadge), findsOneWidget);
    });

    testWidgets('renders Ibuprofen card with 1 tablet · with milk and 2:00 PM badge', (tester) async {
      final ibuprofen = MedicineEntity(
        id: 'med_ibuprofen',
        name: 'Ibuprofen',
        type: MedicineType.tablet,
        doseQuantity: 1,
        doseUnit: 'tablet',
        schedule: const MedicineScheduleEntity(
          times: [TimeOfDay(hour: 14, minute: 0)],
        ),
        duration: CourseDurationEntity(durationType: CourseDurationType.ongoing),
        instructions: ['with milk'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayMedicineCard(
              medicine: ibuprofen,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(find.text('1 tablet · with milk'), findsOneWidget);
      expect(find.text('2:00 PM'), findsOneWidget);
    });

    testWidgets('renders Pregabalin capsule card with 1 capsule · back pain and 9:00 PM badge', (tester) async {
      final pregabalin = MedicineEntity(
        id: 'med_pregabalin',
        name: 'Pregabalin',
        purpose: 'back pain',
        type: MedicineType.capsule,
        doseQuantity: 1,
        doseUnit: 'capsule',
        schedule: const MedicineScheduleEntity(
          times: [TimeOfDay(hour: 21, minute: 0)],
        ),
        duration: CourseDurationEntity(durationType: CourseDurationType.ongoing),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayMedicineCard(
              medicine: pregabalin,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pregabalin'), findsOneWidget);
      expect(find.text('1 capsule · back pain'), findsOneWidget);
      expect(find.text('9:00 PM'), findsOneWidget);
    });

    testWidgets('triggers onTap and onLongPress action sheet correctly', (tester) async {
      bool tapped = false;
      bool deleted = false;

      final med = MedicineEntity(
        id: 'med_1',
        name: 'Bactrim',
        type: MedicineType.tablet,
        doseQuantity: 1,
        doseUnit: 'tablet',
        schedule: const MedicineScheduleEntity(
          times: [TimeOfDay(hour: 11, minute: 45)],
        ),
        duration: CourseDurationEntity(durationType: CourseDurationType.ongoing),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayMedicineCard(
              medicine: med,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bactrim'));
      await tester.pump();
      expect(tapped, isTrue);

      await tester.longPress(find.text('Bactrim'));
      await tester.pumpAndSettle();
      expect(find.text('Delete medicine'), findsOneWidget);

      await tester.tap(find.text('Delete medicine'));
      await tester.pump();
      expect(deleted, isTrue);
    });
  });
}
