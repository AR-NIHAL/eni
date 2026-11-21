import 'package:hive_flutter/hive_flutter.dart';
import '../models/dose_log_model.dart';

abstract class DoseLocalDataSource {
  Future<List<DoseLogModel>> getDoseLogsForDate(DateTime date);
  Stream<List<DoseLogModel>> watchDoseLogsForDate(DateTime date);
  Stream<List<DoseLogModel>> watchDoseLogsForMedicine(String medicineId);
  Future<List<DoseLogModel>> getAllDoseLogs();
  Stream<List<DoseLogModel>> watchAllDoseLogs();
  Future<DoseLogModel?> getDoseLog(String medicineId, DateTime date, String scheduledTime);
  Future<void> saveDoseLog(DoseLogModel log);
  Future<void> deleteDoseLog(String id);
}

class DoseLocalDataSourceImpl implements DoseLocalDataSource {
  static const String boxName = 'dose_logs_box';

  Box<DoseLogModel> get _box => Hive.box<DoseLogModel>(boxName);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<List<DoseLogModel>> getDoseLogsForDate(DateTime date) async {
    return _box.values.where((log) {
      final logDate = DateTime.tryParse(log.scheduledDate);
      if (logDate == null) return false;
      return _isSameDay(logDate, date);
    }).toList();
  }

  @override
  Stream<List<DoseLogModel>> watchDoseLogsForDate(DateTime date) async* {
    yield await getDoseLogsForDate(date);
    yield* _box.watch().map((_) {
      return _box.values.where((log) {
        final logDate = DateTime.tryParse(log.scheduledDate);
        if (logDate == null) return false;
        return _isSameDay(logDate, date);
      }).toList();
    });
  }

  @override
  Stream<List<DoseLogModel>> watchDoseLogsForMedicine(String medicineId) async* {
    yield _box.values.where((log) => log.medicineId == medicineId).toList();
    yield* _box.watch().map((_) {
      return _box.values.where((log) => log.medicineId == medicineId).toList();
    });
  }

  @override
  Future<List<DoseLogModel>> getAllDoseLogs() async {
    return _box.values.toList();
  }

  @override
  Stream<List<DoseLogModel>> watchAllDoseLogs() async* {
    yield _box.values.toList();
    yield* _box.watch().map((_) => _box.values.toList());
  }

  @override
  Future<DoseLogModel?> getDoseLog(
      String medicineId, DateTime date, String scheduledTime) async {
    try {
      return _box.values.firstWhere(
        (log) =>
            log.medicineId == medicineId &&
            log.scheduledTime == scheduledTime &&
            _isSameDay(DateTime.parse(log.scheduledDate), date),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDoseLog(DoseLogModel log) async {
    await _box.put(log.id, log);
  }

  @override
  Future<void> deleteDoseLog(String id) async {
    await _box.delete(id);
  }
}
