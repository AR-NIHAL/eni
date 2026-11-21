import 'package:flutter/material.dart';

enum MedicineType {
  tablet,
  capsule,
  syrup,
  drops,
  inhaler,
  injection,
  powder,
  other;

  String get displayName {
    switch (this) {
      case MedicineType.tablet:
        return 'Tablet';
      case MedicineType.capsule:
        return 'Capsule';
      case MedicineType.syrup:
        return 'Syrup';
      case MedicineType.drops:
        return 'Drops';
      case MedicineType.inhaler:
        return 'Inhaler';
      case MedicineType.injection:
        return 'Injection';
      case MedicineType.powder:
        return 'Powder';
      case MedicineType.other:
        return 'Other';
    }
  }

  String get defaultUnit {
    switch (this) {
      case MedicineType.tablet:
        return 'tablet';
      case MedicineType.capsule:
        return 'capsule';
      case MedicineType.syrup:
        return 'ml';
      case MedicineType.drops:
        return 'drops';
      case MedicineType.inhaler:
        return 'puffs';
      case MedicineType.injection:
        return 'mg';
      case MedicineType.powder:
        return 'sachet';
      case MedicineType.other:
        return 'unit';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicineType.tablet:
        return Icons.medication_rounded;
      case MedicineType.capsule:
        return Icons.medication_liquid_rounded;
      case MedicineType.syrup:
        return Icons.local_drink_rounded;
      case MedicineType.drops:
        return Icons.water_drop_rounded;
      case MedicineType.inhaler:
        return Icons.air_rounded;
      case MedicineType.injection:
        return Icons.vaccines_rounded;
      case MedicineType.powder:
        return Icons.grain_rounded;
      case MedicineType.other:
        return Icons.healing_rounded;
    }
  }

  static MedicineType fromString(String? value) {
    return MedicineType.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => MedicineType.tablet,
    );
  }
}
