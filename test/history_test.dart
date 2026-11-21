import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/dose_tracking/domain/entities/dose_log_entity.dart';
import 'package:medico/features/history/domain/entities/adherence_stats_entity.dart';
import 'package:medico/features/history/domain/usecases/calculate_adherence_usecase.dart';
import 'package:medico/features/history/presentation/widgets/adherence_hero_card.dart';
import 'package:medico/features/history/presentation/widgets/dose_history_timeline_tile.dart';
import 'package:medico/features/history/presentation/widgets/monthly_heatmap_widget.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';

void main() {
  final now = DateTime.now();
  final testMed = MedicineEntity(
    id: 'med_1',
    name: 'Pregabalin',
    purpose: 'Pain relief',
    type: MedicineType.capsule,
    strength: '50 mg',
    doseQuantity: 1,
    doseUnit: 'capsule',
    schedule: MedicineScheduleEntity(
      frequency: FrequencyType.everyday,
      times: [const TimeOfDay(hour: 9, minute: 0)],
    ),
    duration: CourseDurationEntity(
      durationType: CourseDurationType.days,
      daysCount: 30,
      startDate: DateTime(now.year, now.month, 1),
    ),
    createdAt: DateTime(now.year, now.month, 1),
  );

  group('CalculateAdherenceUseCase Tests', () {
    final useCase = CalculateAdherenceUseCase();

    test('calculates 100% adherence when all doses are taken', () {
      final logs = [
        DoseLogEntity(
          id: 'log_1',
          medicineId: testMed.id,
          medicineName: testMed.name,
          doseQuantity: 1,
          doseUnit: 'capsule',
          scheduledDate: DateTime(now.year, now.month, 1),
          scheduledTime: '09:00',
          status: DoseStatus.taken,
        ),
      ];

      final stats = useCase.calculateStats(
        medicines: [testMed],
        allLogs: logs,
        year: now.year,
        month: now.month,
      );

      expect(stats.takenCount, 1);
      expect(stats.skippedCount, 0);
      expect(stats.adherencePercentage, greaterThan(0));
    });

    test('calculates lower adherence when doses are skipped', () {
      final logs = [
        DoseLogEntity(
          id: 'log_1',
          medicineId: testMed.id,
          medicineName: testMed.name,
          doseQuantity: 1,
          doseUnit: 'capsule',
          scheduledDate: DateTime(now.year, now.month, 1),
          scheduledTime: '09:00',
          status: DoseStatus.taken,
        ),
        DoseLogEntity(
          id: 'log_2',
          medicineId: testMed.id,
          medicineName: testMed.name,
          doseQuantity: 1,
          doseUnit: 'capsule',
          scheduledDate: DateTime(now.year, now.month, 2),
          scheduledTime: '09:00',
          status: DoseStatus.skipped,
          skipReason: 'Side effects',
        ),
      ];

      final stats = useCase.calculateStats(
        medicines: [testMed],
        allLogs: logs,
        year: now.year,
        month: now.month,
      );

      expect(stats.takenCount, 1);
      expect(stats.skippedCount, 1);
    });
  });

  group('History Widgets Rendering Tests', () {
    testWidgets('AdherenceHeroCard renders percentage score and metrics', (tester) async {
      const stats = AdherenceStatsEntity(
        totalScheduled: 50,
        takenCount: 47,
        skippedCount: 3,
        snoozedCount: 1,
        adherenceRate: 0.94,
        currentStreakDays: 12,
        longestStreakDays: 12,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdherenceHeroCard(stats: stats),
          ),
        ),
      );

      expect(find.text('ADHERENCE SCORE'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('High Adherence'), findsOneWidget);
      expect(find.text('47'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('12d'), findsOneWidget);
    });

    testWidgets('DoseHistoryTimelineTile renders dose info and skip reason', (tester) async {
      final log = DoseLogEntity(
        id: 'test_log',
        medicineId: 'med_1',
        medicineName: 'Augmentin',
        doseQuantity: 1,
        doseUnit: 'tablet',
        scheduledDate: DateTime.now(),
        scheduledTime: '14:00',
        status: DoseStatus.skipped,
        skipReason: 'Doctor advised',
        actualActionTime: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DoseHistoryTimelineTile(log: log),
            ),
          ),
        ),
      );

      expect(find.text('Augmentin'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Reason: Doctor advised'), findsOneWidget);
    });

    testWidgets('MonthlyHeatmapWidget renders weekday headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MonthlyHeatmapWidget(
                selectedMonth: DateTime(2026, 11, 1),
                selectedDay: null,
                daySummaries: const {},
                onDaySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Adherence Heatmap'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
    });
  });
}
