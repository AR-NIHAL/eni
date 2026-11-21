import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/dose_tracking/domain/entities/dose_log_entity.dart';
import 'package:medico/features/dose_tracking/data/models/dose_log_model.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';
import 'package:medico/features/dose_tracking/domain/usecases/dose_usecases.dart';
import 'package:medico/features/dose_tracking/domain/repositories/dose_repository.dart';
import 'package:medico/features/medicine/domain/repositories/medicine_repository.dart';

class MockDoseRepository implements DoseRepository {
  final Map<String, DoseLogEntity> storage = {};

  @override
  Future<void> deleteDoseLog(String id) async {
    storage.remove(id);
  }

  @override
  Future<DoseLogEntity?> getDoseLog(
      String medicineId, DateTime date, String scheduledTime) async {
    return storage.values.where((l) =>
        l.medicineId == medicineId &&
        l.scheduledTime == scheduledTime &&
        l.scheduledDate.year == date.year &&
        l.scheduledDate.month == date.month &&
        l.scheduledDate.day == date.day).firstOrNull;
  }

  @override
  Future<List<DoseLogEntity>> getDoseLogsForDate(DateTime date) async {
    return storage.values.where((l) =>
        l.scheduledDate.year == date.year &&
        l.scheduledDate.month == date.month &&
        l.scheduledDate.day == date.day).toList();
  }

  @override
  Future<void> saveDoseLog(DoseLogEntity log) async {
    storage[log.id] = log;
  }

  @override
  Stream<List<DoseLogEntity>> watchDoseLogsForDate(DateTime date) async* {
    yield await getDoseLogsForDate(date);
  }

  @override
  Stream<List<DoseLogEntity>> watchDoseLogsForMedicine(String medicineId) async* {
    yield storage.values.where((l) => l.medicineId == medicineId).toList();
  }

  @override
  Future<List<DoseLogEntity>> getAllDoseLogs() async {
    return storage.values.toList();
  }

  @override
  Stream<List<DoseLogEntity>> watchAllDoseLogs() async* {
    yield storage.values.toList();
  }
}

class MockMedicineRepository implements MedicineRepository {
  MedicineEntity? currentMedicine;

  @override
  Future<void> deleteMedicine(String id) async {}

  @override
  Future<MedicineEntity?> getMedicineById(String id) async => currentMedicine;

  @override
  Future<List<MedicineEntity>> getMedicines() async =>
      currentMedicine != null ? [currentMedicine!] : [];

  @override
  Future<void> saveMedicine(MedicineEntity medicine) async {
    currentMedicine = medicine;
  }

  @override
  Future<void> updateMedicine(MedicineEntity medicine) async {
    currentMedicine = medicine;
  }

  @override
  Stream<List<MedicineEntity>> watchMedicines() async* {
    yield currentMedicine != null ? [currentMedicine!] : [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DoseLog Model Tests', () {
    test('converts DoseLogEntity to DoseLogModel and back', () {
      final now = DateTime.now();
      final entity = DoseLogEntity(
        id: 'dose-1',
        medicineId: 'med-1',
        medicineName: 'Maxpro',
        doseQuantity: 3,
        doseUnit: 'capsule',
        scheduledDate: DateTime(now.year, now.month, now.day),
        scheduledTime: '08:00',
        status: DoseStatus.taken,
        actualActionTime: now,
      );

      final model = DoseLogModel.fromEntity(entity);
      expect(model.medicineName, 'Maxpro');
      expect(model.doseQuantity, 3);
      expect(model.status, 'taken');

      final back = model.toEntity();
      expect(back.medicineName, 'Maxpro');
      expect(back.status, DoseStatus.taken);
      expect(back.doseQuantity, 3);
    });
  });

  group('Dose Tracking Use Cases Tests', () {
    late MockDoseRepository mockDoseRepo;
    late MockMedicineRepository mockMedRepo;
    late MedicineEntity testMedicine;
    final testDate = DateTime(2026, 11, 19);

    setUp(() {
      mockDoseRepo = MockDoseRepository();
      mockMedRepo = MockMedicineRepository();
      testMedicine = MedicineEntity(
        id: 'med-123',
        name: 'Maxpro',
        type: MedicineType.capsule,
        doseQuantity: 3,
        doseUnit: 'capsule',
        schedule: const MedicineScheduleEntity(times: []),
        duration: CourseDurationEntity(),
        stockRemaining: 30, // Initially 30 capsules
      );
      mockMedRepo.currentMedicine = testMedicine;
    });

    test('MarkDoseTaken logs status, timestamp, and decrements stock', () async {
      final markUseCase = MarkDoseTakenUseCase(
        doseRepository: mockDoseRepo,
        medicineRepository: mockMedRepo,
      );

      final log = await markUseCase(
        medicine: testMedicine,
        date: testDate,
        scheduledTime: '08:00',
      );

      expect(log.status, DoseStatus.taken);
      expect(log.actualActionTime, isNotNull);
      // Stock should be 30 - 3 = 27
      expect(mockMedRepo.currentMedicine!.stockRemaining, 27);

      // Test Undo
      final undoUseCase = UndoDoseUseCase(
        doseRepository: mockDoseRepo,
        medicineRepository: mockMedRepo,
      );

      await undoUseCase(log: log, medicine: mockMedRepo.currentMedicine!);

      // Stock should be restored back to 30
      expect(mockMedRepo.currentMedicine!.stockRemaining, 30);
      expect(mockDoseRepo.storage.containsKey(log.id), false);
    });

    test('SnoozeDose updates status to snoozed and sets snoozeUntilTime', () async {
      final snoozeUseCase = SnoozeDoseUseCase(mockDoseRepo);

      final log = await snoozeUseCase(
        medicine: testMedicine,
        date: testDate,
        scheduledTime: '08:00',
        duration: const Duration(minutes: 15),
      );

      expect(log.status, DoseStatus.snoozed);
      expect(log.snoozeUntilTime, isNotNull);
      // Stock should remain unchanged
      expect(mockMedRepo.currentMedicine!.stockRemaining, 30);
    });

    test('SkipDose updates status to skipped and does not deduct stock', () async {
      final skipUseCase = SkipDoseUseCase(mockDoseRepo);

      final log = await skipUseCase(
        medicine: testMedicine,
        date: testDate,
        scheduledTime: '08:00',
        reason: 'Out of stock',
      );

      expect(log.status, DoseStatus.skipped);
      expect(log.skipReason, 'Out of stock');
      // Stock unchanged
      expect(mockMedRepo.currentMedicine!.stockRemaining, 30);
    });
  });
}
