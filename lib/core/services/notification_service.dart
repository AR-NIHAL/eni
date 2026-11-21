import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/dose_tracking/data/datasources/dose_local_datasource.dart';
import '../../features/dose_tracking/data/models/dose_log_model.dart';
import '../../features/medicine/data/datasources/medicine_local_datasource.dart';
import '../../features/medicine/data/models/medicine_model.dart';
import '../../features/medicine/domain/entities/medicine_entity.dart';
import '../../features/medicine/domain/entities/medicine_schedule_entity.dart';
import '../utils/id_generator.dart';

int getNotificationId(String medicineId, String scheduledTime) {
  return (medicineId.hashCode ^ scheduledTime.hashCode).abs() % 1000000;
}

int getSpecificDayNotificationId(String medicineId, int dayOfWeek, String scheduledTime) {
  return (medicineId.hashCode ^ (dayOfWeek * 7919) ^ scheduledTime.hashCode).abs() % 1000000;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const MethodChannel _nativeChannel =
      MethodChannel('com.medico.app/alarm_sound');

  static const String alarmChannelId = 'medico_alarm_channel_v3';
  static const String alarmChannelName = 'Medication Alarms';

  String? _cachedAlarmUri;

  Future<String?> _getAlarmUri() async {
    if (_cachedAlarmUri != null) return _cachedAlarmUri;
    try {
      _cachedAlarmUri =
          await _nativeChannel.invokeMethod<String>('getAlarmUri');
      return _cachedAlarmUri;
    } catch (_) {
      return null;
    }
  }

  Future<void> init({
    void Function(NotificationResponse response)? onAction,
  }) async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'dose_category',
          actions: [
            DarwinNotificationAction.plain('taken_action', 'Take'),
            DarwinNotificationAction.plain('snooze_action', 'Snooze 10m'),
          ],
        ),
      ],
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Medico',
      appUserModelId: 'com.medico.app',
      guid: '32e731bc-4eb0-4bf6-b51c-4b533cb42e47',
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: onAction ?? handleNotificationResponse,
      );

      // Request Android 13+ Notification & Exact Alarm permissions
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();

        // Delete old silent channel if present so Android applies new alarm configuration
        try {
          await androidImplementation.deleteNotificationChannel(channelId: 'medico_dose_reminders');
        } catch (_) {}

        // Fetch native system alarm URI and register dedicated alarm channel
        final alarmUri = await _getAlarmUri();
        final sound = alarmUri != null ? UriAndroidNotificationSound(alarmUri) : null;

        final channel = AndroidNotificationChannel(
          alarmChannelId,
          alarmChannelName,
          description: 'Loud medication alarm alerts with vibration and alarm ringtone',
          importance: Importance.max,
          playSound: true,
          sound: sound,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize local notifications: $e');
    }
  }

  Future<void> scheduleDoseReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    DateTimeComponents? matchDateTimeComponents,
    bool isMuted = false,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    final alarmUri = await _getAlarmUri();
    final sound = (!isMuted && alarmUri != null)
        ? UriAndroidNotificationSound(alarmUri)
        : null;

    final androidDetails = AndroidNotificationDetails(
      alarmChannelId,
      alarmChannelName,
      channelDescription: 'Loud medication alarm alerts with vibration and alarm ringtone',
      importance: isMuted ? Importance.low : Importance.max,
      priority: isMuted ? Priority.low : Priority.max,
      playSound: !isMuted,
      sound: sound,
      enableVibration: !isMuted,
      vibrationPattern: isMuted
          ? null
          : Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      actions: const [
        AndroidNotificationAction(
          'taken_action',
          'Take',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_action',
          'Snooze 10m',
          showsUserInterface: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: !isMuted,
        presentAlert: true,
        presentBadge: true,
        categoryIdentifier: 'dose_category',
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Automatically schedules recurring alarms for all doses of a medicine
  Future<void> scheduleMedicineReminders(MedicineEntity medicine) async {
    if (!medicine.isActive || medicine.isPaused) return;
    if (medicine.schedule.frequency == FrequencyType.asNeeded) return;

    for (final time in medicine.schedule.times) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final now = DateTime.now();

      // Determine initial future scheduled date time
      var initialDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (initialDate.isBefore(now)) {
        initialDate = initialDate.add(const Duration(days: 1));
      }

      final title = 'Time for ${medicine.name}';
      final purposeInfo = medicine.purpose != null && medicine.purpose!.isNotEmpty
          ? ' • ${medicine.purpose}'
          : '';
      final body = 'Take ${medicine.doseQuantity} ${medicine.doseUnit}$purposeInfo';

      final payload = jsonEncode({
        'medicineId': medicine.id,
        'medicineName': medicine.name,
        'dose': medicine.doseQuantity,
        'unit': medicine.doseUnit,
        'time': timeStr,
      });

      if (medicine.schedule.frequency == FrequencyType.everyday ||
          medicine.schedule.frequency == FrequencyType.everyOtherDay) {
        final notifId = getNotificationId(medicine.id, timeStr);
        await scheduleDoseReminder(
          id: notifId,
          title: title,
          body: body,
          scheduledDateTime: initialDate,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } else if (medicine.schedule.frequency == FrequencyType.specificDays) {
        for (final day in medicine.schedule.specificDays) {
          // Calculate next date matching this day of week (1=Mon ... 7=Sun)
          var daysUntil = (day - now.weekday) % 7;
          if (daysUntil < 0) daysUntil += 7;
          var targetDate = DateTime(
            now.year,
            now.month,
            now.day + daysUntil,
            time.hour,
            time.minute,
          );
          if (targetDate.isBefore(now)) {
            targetDate = targetDate.add(const Duration(days: 7));
          }

          final notifId = getSpecificDayNotificationId(medicine.id, day, timeStr);
          await scheduleDoseReminder(
            id: notifId,
            title: title,
            body: body,
            scheduledDateTime: targetDate,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: payload,
          );
        }
      }
    }
  }

  /// Cancels all scheduled reminders/alarms for a medicine
  Future<void> cancelMedicineReminders(MedicineEntity medicine) async {
    for (final time in medicine.schedule.times) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      await cancelReminder(getNotificationId(medicine.id, timeStr));

      for (int day = 1; day <= 7; day++) {
        await cancelReminder(getSpecificDayNotificationId(medicine.id, day, timeStr));
      }
    }
  }

  /// Handles user tapping [Take] or [Snooze 10m] on a notification
  Future<void> handleNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final medicineId = data['medicineId'] as String?;
      final scheduledTime = data['time'] as String?;
      if (medicineId == null || scheduledTime == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (response.actionId == 'taken_action') {
        final doseBox = Hive.isBoxOpen(DoseLocalDataSourceImpl.boxName)
            ? Hive.box<DoseLogModel>(DoseLocalDataSourceImpl.boxName)
            : await Hive.openBox<DoseLogModel>(DoseLocalDataSourceImpl.boxName);

        final logId = IdGenerator.generate();
        final logModel = DoseLogModel(
          id: logId,
          medicineId: medicineId,
          medicineName: data['medicineName'] as String? ?? 'Medicine',
          doseQuantity: (data['dose'] as num?) ?? 1,
          doseUnit: data['unit'] as String? ?? 'capsule',
          scheduledDate: today.toIso8601String(),
          scheduledTime: scheduledTime,
          status: 'taken',
          actualActionTime: now.toIso8601String(),
          isAlarmMuted: false,
        );
        await doseBox.put(logId, logModel);

        // Deduct inventory stock if tracked
        final medBox = Hive.isBoxOpen(MedicineLocalDataSourceImpl.boxName)
            ? Hive.box<MedicineModel>(MedicineLocalDataSourceImpl.boxName)
            : await Hive.openBox<MedicineModel>(MedicineLocalDataSourceImpl.boxName);

        final medModel = medBox.get(medicineId);
        if (medModel != null && medModel.stockRemaining != null) {
          final entity = medModel.toEntity();
          final remaining = entity.stockRemaining! - logModel.doseQuantity.toInt();
          final updated = entity.copyWith(
            stockRemaining: remaining < 0 ? 0 : remaining,
          );
          await medBox.put(medicineId, MedicineModel.fromEntity(updated));
        }

        final notifId = getNotificationId(medicineId, scheduledTime);
        await cancelReminder(notifId);
      } else if (response.actionId == 'snooze_action') {
        final snoozeUntil = now.add(const Duration(minutes: 10));
        final notifId = getNotificationId(medicineId, scheduledTime);

        await scheduleDoseReminder(
          id: notifId,
          title: 'Snoozed: Time for ${data['medicineName'] ?? 'Medicine'}',
          body: 'Take ${data['dose'] ?? 1} ${data['unit'] ?? 'capsule'}',
          scheduledDateTime: snoozeUntil,
          payload: payload,
        );
      }
    } catch (e) {
      debugPrint('Error handling notification action response: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel notification $id: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }
}
