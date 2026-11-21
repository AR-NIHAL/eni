import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/medico_button.dart';
import '../../../../core/widgets/medico_chip.dart';

class SkipBottomSheet extends StatefulWidget {
  final String medicineName;
  final ValueChanged<String> onSkipConfirmed;

  const SkipBottomSheet({
    super.key,
    required this.medicineName,
    required this.onSkipConfirmed,
  });

  static Future<String?> show(BuildContext context, String medicineName) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SkipBottomSheet(
        medicineName: medicineName,
        onSkipConfirmed: (reason) => Navigator.pop(ctx, reason),
      ),
    );
  }

  @override
  State<SkipBottomSheet> createState() => _SkipBottomSheetState();
}

class _SkipBottomSheetState extends State<SkipBottomSheet> {
  String _selectedReason = 'Forgot / missed';

  final List<String> _reasons = [
    'Forgot / missed',
    'Doctor advised',
    'Out of stock',
    'Felt sick / Side effects',
    'Fast / Not eating',
    'Other reason',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.skip_next_rounded, color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Skip This Dose',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Stock will remain untouched for ${widget.medicineName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Reason for skipping:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map((reason) {
              final isSelected = reason == _selectedReason;
              return MedicoChip(
                label: reason,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedReason = reason),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          MedicoButton(
            label: 'Confirm Skip',
            onPressed: () => widget.onSkipConfirmed(_selectedReason),
          ),
        ],
      ),
    );
  }
}
