import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/medico_chip.dart';

class TimeChipsSelector extends StatelessWidget {
  final List<TimeOfDay> times;
  final ValueChanged<TimeOfDay> onTimeAdded;
  final ValueChanged<TimeOfDay> onTimeRemoved;

  const TimeChipsSelector({
    super.key,
    required this.times,
    required this.onTimeAdded,
    required this.onTimeRemoved,
  });

  Future<void> _pickCustomTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeAdded(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...times.map((time) {
          return MedicoChip(
            label: DateTimeUtils.formatTime(time),
            isSelected: true,
            icon: Icons.access_time_rounded,
            trailing: GestureDetector(
              onTap: () => onTimeRemoved(time),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
            ),
            onTap: () {},
          );
        }),
        GestureDetector(
          onTap: () => _pickCustomTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.cardBorder,
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: 6),
                Text(
                  'Add time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
