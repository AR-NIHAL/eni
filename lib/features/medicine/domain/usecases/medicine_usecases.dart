import '../../../../core/services/notification_service.dart';
import '../entities/medicine_entity.dart';
import '../repositories/medicine_repository.dart';

class GetMedicinesUseCase {
  final MedicineRepository repository;

  GetMedicinesUseCase(this.repository);

  Future<List<MedicineEntity>> call() async {
    return await repository.getMedicines();
  }
}

class WatchMedicinesUseCase {
  final MedicineRepository repository;

  WatchMedicinesUseCase(this.repository);

  Stream<List<MedicineEntity>> call() {
    return repository.watchMedicines();
  }
}

class SaveMedicineUseCase {
  final MedicineRepository repository;

  SaveMedicineUseCase(this.repository);

  Future<void> call(MedicineEntity medicine) async {
    await repository.saveMedicine(medicine);
    try {
      await NotificationService.instance.scheduleMedicineReminders(medicine);
    } catch (_) {}
  }
}

class DeleteMedicineUseCase {
  final MedicineRepository repository;

  DeleteMedicineUseCase(this.repository);

  Future<void> call(String id) async {
    try {
      final medicine = await repository.getMedicineById(id);
      if (medicine != null) {
        await NotificationService.instance.cancelMedicineReminders(medicine);
      }
    } catch (_) {}
    await repository.deleteMedicine(id);
  }
}

class UpdateMedicineUseCase {
  final MedicineRepository repository;

  UpdateMedicineUseCase(this.repository);

  Future<void> call(MedicineEntity medicine) async {
    await repository.updateMedicine(medicine);
    try {
      if (medicine.isActive && !medicine.isPaused) {
        await NotificationService.instance.scheduleMedicineReminders(medicine);
      } else {
        await NotificationService.instance.cancelMedicineReminders(medicine);
      }
    } catch (_) {}
  }
}
