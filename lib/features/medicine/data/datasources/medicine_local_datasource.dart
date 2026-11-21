import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine_model.dart';

abstract class MedicineLocalDataSource {
  Future<List<MedicineModel>> getMedicines();
  Stream<List<MedicineModel>> watchMedicines();
  Future<MedicineModel?> getMedicineById(String id);
  Future<void> saveMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String id);
}

class MedicineLocalDataSourceImpl implements MedicineLocalDataSource {
  static const String boxName = 'medicines_box';

  Box<MedicineModel> get _box => Hive.box<MedicineModel>(boxName);

  @override
  Future<List<MedicineModel>> getMedicines() async {
    return _box.values.toList();
  }

  @override
  Stream<List<MedicineModel>> watchMedicines() async* {
    yield _box.values.toList();
    yield* _box.watch().map((_) => _box.values.toList());
  }

  @override
  Future<MedicineModel?> getMedicineById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> saveMedicine(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }
}
