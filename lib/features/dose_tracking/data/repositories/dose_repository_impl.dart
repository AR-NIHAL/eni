import '../../domain/entities/dose_log_entity.dart';
import '../../domain/repositories/dose_repository.dart';
import '../datasources/dose_local_datasource.dart';
import '../models/dose_log_model.dart';

class DoseRepositoryImpl implements DoseRepository {
  final DoseLocalDataSource localDataSource;

  DoseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DoseLogEntity>> getDoseLogsForDate(DateTime date) async {
    final models = await localDataSource.getDoseLogsForDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DoseLogEntity>> watchDoseLogsForDate(DateTime date) {
    return localDataSource.watchDoseLogsForDate(date).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Stream<List<DoseLogEntity>> watchDoseLogsForMedicine(String medicineId) {
    return localDataSource.watchDoseLogsForMedicine(medicineId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<List<DoseLogEntity>> getAllDoseLogs() async {
    final models = await localDataSource.getAllDoseLogs();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DoseLogEntity>> watchAllDoseLogs() {
    return localDataSource.watchAllDoseLogs().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<DoseLogEntity?> getDoseLog(
      String medicineId, DateTime date, String scheduledTime) async {
    final model = await localDataSource.getDoseLog(medicineId, date, scheduledTime);
    return model?.toEntity();
  }

  @override
  Future<void> saveDoseLog(DoseLogEntity log) async {
    final model = DoseLogModel.fromEntity(log);
    await localDataSource.saveDoseLog(model);
  }

  @override
  Future<void> deleteDoseLog(String id) async {
    await localDataSource.deleteDoseLog(id);
  }
}
