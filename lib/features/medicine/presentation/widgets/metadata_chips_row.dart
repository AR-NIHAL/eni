import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/medicine_entity.dart';

class MetadataChipsRow extends StatelessWidget {
  final MedicineEntity medicine;

  const MetadataChipsRow({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> tags = [];

    // Tag 1: Strength + Dose Unit / Form (e.g. "50 mg capsule")
    final strengthPart = medicine.strength != null && medicine.strength!.isNotEmpty
        ? medicine.strength!
        : '${medicine.doseQuantity}';
    tags.add('$strengthPart ${medicine.doseUnit}');

    // Tag 2: Condition / Purpose (e.g. "Lower back pain")
    if (medicine.purpose != null && medicine.purpose!.trim().isNotEmpty) {
      tags.add(medicine.purpose!.trim());
    }

    // Tag 3+: Intake instructions (e.g. "After meal", "With water")
    tags.addAll(medicine.instructions);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tags.map((tag) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
