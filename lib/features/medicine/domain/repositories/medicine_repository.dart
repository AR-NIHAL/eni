import '../entities/medicine_entity.dart';

abstract class MedicineRepository {
  Future<List<MedicineEntity>> getMedicines();
  Stream<List<MedicineEntity>> watchMedicines();
  Future<MedicineEntity?> getMedicineById(String id);
  Future<void> saveMedicine(MedicineEntity medicine);
  Future<void> deleteMedicine(String id);
  Future<void> updateMedicine(MedicineEntity medicine);
}
