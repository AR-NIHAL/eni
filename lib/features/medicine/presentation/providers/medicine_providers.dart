import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/entities/medicine_type.dart';
import '../../domain/entities/medicine_schedule_entity.dart';
import '../../domain/entities/course_duration_entity.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/usecases/medicine_usecases.dart';
import '../../data/datasources/medicine_local_datasource.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../../../core/utils/id_generator.dart';

// --- Data & Domain Providers ---

final medicineLocalDataSourceProvider = Provider<MedicineLocalDataSource>((ref) {
  return MedicineLocalDataSourceImpl();
});

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  final localDataSource = ref.watch(medicineLocalDataSourceProvider);
  return MedicineRepositoryImpl(localDataSource: localDataSource);
});

final getMedicinesUseCaseProvider = Provider<GetMedicinesUseCase>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return GetMedicinesUseCase(repository);
});

final watchMedicinesUseCaseProvider = Provider<WatchMedicinesUseCase>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return WatchMedicinesUseCase(repository);
});

final saveMedicineUseCaseProvider = Provider<SaveMedicineUseCase>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return SaveMedicineUseCase(repository);
});

final deleteMedicineUseCaseProvider = Provider<DeleteMedicineUseCase>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return DeleteMedicineUseCase(repository);
});

final updateMedicineUseCaseProvider = Provider<UpdateMedicineUseCase>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return UpdateMedicineUseCase(repository);
});

// Stream of all medicines for real-time reactivity
final medicinesStreamProvider = StreamProvider<List<MedicineEntity>>((ref) {
  final watchUseCase = ref.watch(watchMedicinesUseCaseProvider);
  return watchUseCase();
});

// Provider to watch a specific medicine by ID
final medicineByIdProvider = Provider.family<MedicineEntity?, String>((ref, id) {
  final medicinesAsync = ref.watch(medicinesStreamProvider);
  return medicinesAsync.value?.firstWhere(
    (m) => m.id == id,
    orElse: () => null as dynamic,
  );
});

// --- Add Medicine Form State & Notifier ---

class AddMedicineState {
  final String name;
  final String purpose;
  final MedicineType type;
  final String strength;
  final num doseQuantity;
  final FrequencyType frequency;
  final List<int> specificDays;
  final List<TimeOfDay> reminderTimes;
  final CourseDurationType durationType;
  final int daysCount;
  final List<String> instructions;
  final String? photoPath;
  final bool trackRefill;
  final int stockRemaining;
  final int refillAlertThreshold;
  final bool isSaving;
  final String? errorMessage;

  const AddMedicineState({
    this.name = '',
    this.purpose = '',
    this.type = MedicineType.capsule,
    this.strength = '',
    this.doseQuantity = 1,
    this.frequency = FrequencyType.everyday,
    this.specificDays = const [],
    this.reminderTimes = const [],
    this.durationType = CourseDurationType.ongoing,
    this.daysCount = 10,
    this.instructions = const ['With food', 'With water'],
    this.photoPath,
    this.trackRefill = false,
    this.stockRemaining = 30,
    this.refillAlertThreshold = 5,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isValid => name.trim().isNotEmpty;

  AddMedicineState copyWith({
    String? name,
    String? purpose,
    MedicineType? type,
    String? strength,
    num? doseQuantity,
    FrequencyType? frequency,
    List<int>? specificDays,
    List<TimeOfDay>? reminderTimes,
    CourseDurationType? durationType,
    int? daysCount,
    List<String>? instructions,
    String? photoPath,
    bool? trackRefill,
    int? stockRemaining,
    int? refillAlertThreshold,
    bool? isSaving,
    String? errorMessage,
  }) {
    return AddMedicineState(
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      durationType: durationType ?? this.durationType,
      daysCount: daysCount ?? this.daysCount,
      instructions: instructions ?? this.instructions,
      photoPath: photoPath ?? this.photoPath,
      trackRefill: trackRefill ?? this.trackRefill,
      stockRemaining: stockRemaining ?? this.stockRemaining,
      refillAlertThreshold: refillAlertThreshold ?? this.refillAlertThreshold,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class AddMedicineNotifier extends StateNotifier<AddMedicineState> {
  final SaveMedicineUseCase _saveMedicineUseCase;

  AddMedicineNotifier(this._saveMedicineUseCase) : super(const AddMedicineState());

  void setName(String name) => state = state.copyWith(name: name);
  void setPurpose(String purpose) => state = state.copyWith(purpose: purpose);
  void setType(MedicineType type) => state = state.copyWith(type: type);
  void setStrength(String strength) => state = state.copyWith(strength: strength);
  void setDoseQuantity(num qty) => state = state.copyWith(doseQuantity: qty);
  void setFrequency(FrequencyType freq) => state = state.copyWith(frequency: freq);

  void toggleSpecificDay(int day) {
    final list = List<int>.from(state.specificDays);
    if (list.contains(day)) {
      list.remove(day);
    } else {
      list.add(day);
      list.sort();
    }
    state = state.copyWith(specificDays: list);
  }

  void addReminderTime(TimeOfDay time) {
    if (!state.reminderTimes.any((t) => t.hour == time.hour && t.minute == time.minute)) {
      final updated = List<TimeOfDay>.from(state.reminderTimes)..add(time);
      updated.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      state = state.copyWith(reminderTimes: updated);
    }
  }

  void removeReminderTime(TimeOfDay time) {
    final updated = state.reminderTimes
        .where((t) => !(t.hour == time.hour && t.minute == time.minute))
        .toList();
    state = state.copyWith(reminderTimes: updated);
  }

  void setDurationType(CourseDurationType type) => state = state.copyWith(durationType: type);
  void setDaysCount(int count) => state = state.copyWith(daysCount: count);

  void toggleInstruction(String instruction) {
    final list = List<String>.from(state.instructions);
    if (list.contains(instruction)) {
      list.remove(instruction);
    } else {
      list.add(instruction);
    }
    state = state.copyWith(instructions: list);
  }

  void setPhotoPath(String? path) => state = state.copyWith(photoPath: path);
  void setTrackRefill(bool value) => state = state.copyWith(trackRefill: value);
  void setStockRemaining(int stock) => state = state.copyWith(stockRemaining: stock);
  void setRefillAlertThreshold(int threshold) => state = state.copyWith(refillAlertThreshold: threshold);

  void reset() => state = const AddMedicineState();

  Future<bool> saveMedicine() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Please enter a medicine name');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final medicine = MedicineEntity(
        id: IdGenerator.generate(),
        name: state.name.trim(),
        purpose: state.purpose.trim().isEmpty ? null : state.purpose.trim(),
        type: state.type,
        strength: state.strength.trim().isEmpty ? null : state.strength.trim(),
        doseQuantity: state.doseQuantity,
        doseUnit: state.type.defaultUnit,
        schedule: MedicineScheduleEntity(
          frequency: state.frequency,
          specificDays: state.specificDays,
          times: state.reminderTimes.isEmpty
              ? const [TimeOfDay(hour: 8, minute: 0)]
              : state.reminderTimes,
        ),
        duration: CourseDurationEntity(
          durationType: state.durationType,
          daysCount: state.durationType == CourseDurationType.days ? state.daysCount : null,
          startDate: DateTime.now(),
          endDate: state.durationType == CourseDurationType.days
              ? DateTime.now().add(Duration(days: state.daysCount))
              : null,
        ),
        instructions: state.instructions,
        photoPath: state.photoPath,
        createdAt: DateTime.now(),
        isActive: true,
        stockRemaining: state.trackRefill ? state.stockRemaining : null,
        refillAlertThreshold: state.trackRefill ? state.refillAlertThreshold : null,
      );

      await _saveMedicineUseCase(medicine);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to save: $e');
      return false;
    }
  }
}

final addMedicineProvider =
    StateNotifierProvider.autoDispose<AddMedicineNotifier, AddMedicineState>((ref) {
  final saveUseCase = ref.watch(saveMedicineUseCaseProvider);
  return AddMedicineNotifier(saveUseCase);
});
