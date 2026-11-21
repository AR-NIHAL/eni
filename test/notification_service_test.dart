import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:medico/core/services/notification_service.dart';
import 'package:medico/features/dose_tracking/data/datasources/dose_local_datasource.dart';
import 'package:medico/features/dose_tracking/data/models/dose_log_model.dart';
import 'package:medico/features/medicine/data/datasources/medicine_local_datasource.dart';
import 'package:medico/features/medicine/data/models/course_duration_model.dart';
import 'package:medico/features/medicine/data/models/medicine_model.dart';
import 'package:medico/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:medico/features/medicine/domain/entities/course_duration_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_schedule_entity.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Helper Tests', () {
    test('getNotificationId produces deterministic positive integers', () {
      final id1 = getNotificationId('med-1', '08:00');
      final id2 = getNotificationId('med-1', '08:00');
      final id3 = getNotificationId('med-1', '20:00');
      final id4 = getNotificationId('med-2', '08:00');

      expect(id1, id2);
      expect(id1 >= 0, true);
      expect(id1, isNot(id3));
      expect(id1, isNot(id4));
    });

    test('getSpecificDayNotificationId differentiates by day of week', () {
      final monId = getSpecificDayNotificationId('med-1', 1, '10:00');
      final wedId = getSpecificDayNotificationId('med-1', 3, '10:00');
      final friId = getSpecificDayNotificationId('med-1', 5, '10:00');

      expect(monId >= 0, true);
      expect(wedId >= 0, true);
      expect(friId >= 0, true);
      expect(monId, isNot(wedId));
      expect(wedId, isNot(friId));
    });

    test('payload serializes and deserializes accurately', () {
      final payload = jsonEncode({
        'medicineId': 'med-99',
        'medicineName': 'Amoxicillin',
        'dose': 2,
        'unit': 'capsule',
        'time': '14:30',
      });

      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      expect(decoded['medicineId'], 'med-99');
      expect(decoded['medicineName'], 'Amoxicillin');
      expect(decoded['dose'], 2);
      expect(decoded['unit'], 'capsule');
      expect(decoded['time'], '14:30');
    });

    test('scheduleMedicineReminders and cancelMedicineReminders handle safely', () async {
      final testMed = MedicineEntity(
        id: 'med-paracetamol',
        name: 'Paracetamol',
        purpose: 'Fever',
        type: MedicineType.tablet,
        doseQuantity: 1,
        doseUnit: 'tablet',
        schedule: const MedicineScheduleEntity(
          frequency: FrequencyType.everyday,
          times: [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 21, minute: 0)],
        ),
        duration: CourseDurationEntity(),
        stockRemaining: 20,
      );

      // Should not throw even in test environment
      await expectLater(
        NotificationService.instance.scheduleMedicineReminders(testMed),
        completes,
      );

      await expectLater(
        NotificationService.instance.cancelMedicineReminders(testMed),
        completes,
      );
    });
  });

  group('Notification Action Response Tests', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('medico_notif_test');
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MedicineModelAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MedicineScheduleModelAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CourseDurationModelAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DoseLogModelAdapter());
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('tapping "Take" action records dose as taken and decrements medicine inventory stock', () async {
      final medBox = await Hive.openBox<MedicineModel>(MedicineLocalDataSourceImpl.boxName);
      final doseBox = await Hive.openBox<DoseLogModel>(DoseLocalDataSourceImpl.boxName);

      final medModel = MedicineModel(
        id: 'med-bp',
        name: 'Amlodipine',
        type: 'tablet',
        doseQuantity: 1,
        doseUnit: 'tablet',
        schedule: MedicineScheduleModel(
          frequency: 'everyday',
          specificDays: [],
          times: ['08:00'],
        ),
        duration: CourseDurationModel(
          durationType: 'ongoing',
          startDate: DateTime.now().toIso8601String(),
        ),
        createdAt: DateTime.now().toIso8601String(),
        stockRemaining: 30,
        refillAlertThreshold: 5,
      );
      await medBox.put('med-bp', medModel);

      final payload = jsonEncode({
        'medicineId': 'med-bp',
        'medicineName': 'Amlodipine',
        'dose': 1,
        'unit': 'tablet',
        'time': '08:00',
      });

      final response = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        actionId: 'taken_action',
        payload: payload,
      );

      await NotificationService.instance.handleNotificationResponse(response);

      // Verify dose was marked taken in Hive
      final logs = doseBox.values.where((l) => l.medicineId == 'med-bp').toList();
      expect(logs.length, 1);
      expect(logs.first.status, 'taken');
      expect(logs.first.doseQuantity, 1);

      // Verify stock was decremented from 30 to 29
      final updatedMed = medBox.get('med-bp');
      expect(updatedMed, isNotNull);
      expect(updatedMed!.stockRemaining, 29);
    });
  });
}
