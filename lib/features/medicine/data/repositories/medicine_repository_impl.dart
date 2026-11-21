import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_local_datasource.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineLocalDataSource localDataSource;

  MedicineRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MedicineEntity>> getMedicines() async {
    final models = await localDataSource.getMedicines();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<MedicineEntity>> watchMedicines() {
    return localDataSource.watchMedicines().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<MedicineEntity?> getMedicineById(String id) async {
    final model = await localDataSource.getMedicineById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveMedicine(MedicineEntity medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    await localDataSource.saveMedicine(model);
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await localDataSource.deleteMedicine(id);
  }

  @override
  Future<void> updateMedicine(MedicineEntity medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    await localDataSource.saveMedicine(model);
  }
}
