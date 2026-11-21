import '../entities/dose_log_entity.dart';

abstract class DoseRepository {
  Future<List<DoseLogEntity>> getDoseLogsForDate(DateTime date);
  Stream<List<DoseLogEntity>> watchDoseLogsForDate(DateTime date);
  Stream<List<DoseLogEntity>> watchDoseLogsForMedicine(String medicineId);
  Future<List<DoseLogEntity>> getAllDoseLogs();
  Stream<List<DoseLogEntity>> watchAllDoseLogs();
  Future<DoseLogEntity?> getDoseLog(String medicineId, DateTime date, String scheduledTime);
  Future<void> saveDoseLog(DoseLogEntity log);
  Future<void> deleteDoseLog(String id);
}
