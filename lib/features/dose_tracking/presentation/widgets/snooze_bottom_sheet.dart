import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/medico_button.dart';
import '../../../../core/widgets/medico_chip.dart';

class SnoozeBottomSheet extends StatefulWidget {
  final String medicineName;
  final ValueChanged<Duration> onSnoozeSelected;

  const SnoozeBottomSheet({
    super.key,
    required this.medicineName,
    required this.onSnoozeSelected,
  });

  static Future<Duration?> show(BuildContext context, String medicineName) {
    return showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SnoozeBottomSheet(
        medicineName: medicineName,
        onSnoozeSelected: (dur) => Navigator.pop(ctx, dur),
      ),
    );
  }

  @override
  State<SnoozeBottomSheet> createState() => _SnoozeBottomSheetState();
}

class _SnoozeBottomSheetState extends State<SnoozeBottomSheet> {
  int _selectedMinutes = 15;

  final List<int> _presetOptions = [10, 15, 30, 60];

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
                  color: AppColors.accentLime.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.snooze_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Snooze Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Delay dose for ${widget.medicineName}',
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
            'Remind me again in:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetOptions.map((mins) {
              final isSelected = mins == _selectedMinutes;
              final label = mins == 60 ? '1 hour' : '$mins min';
              return MedicoChip(
                label: label,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedMinutes = mins),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          MedicoButton(
            label: 'Confirm Snooze ($_selectedMinutes min)',
            onPressed: () => widget.onSnoozeSelected(Duration(minutes: _selectedMinutes)),
          ),
        ],
      ),
    );
  }
}
