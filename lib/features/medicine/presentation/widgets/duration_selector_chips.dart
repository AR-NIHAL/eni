import 'package:flutter/material.dart';
import '../../domain/entities/course_duration_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/medico_chip.dart';

class DurationSelectorChips extends StatelessWidget {
  final CourseDurationType durationType;
  final int daysCount;
  final ValueChanged<CourseDurationType> onTypeChanged;
  final ValueChanged<int> onDaysChanged;

  const DurationSelectorChips({
    super.key,
    required this.durationType,
    required this.daysCount,
    required this.onTypeChanged,
    required this.onDaysChanged,
  });

  Future<void> _showCustomDaysDialog(BuildContext context) async {
    final controller = TextEditingController(text: daysCount > 0 ? '$daysCount' : '7');

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int selected = daysCount > 0 ? daysCount : 7;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Set Course Duration',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How many days will you take this medicine?',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [3, 5, 7, 10, 14, 30].map((d) {
                      final isSelected = selected == d;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selected = d;
                            controller.text = '$d';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryDark : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryDark : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            '$d days',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Custom number of days',
                      hintText: 'e.g. 5',
                      suffixText: 'days',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setDialogState(() => selected = parsed);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  onPressed: () {
                    final days = int.tryParse(controller.text.trim()) ?? selected;
                    Navigator.pop(ctx, days > 0 ? days : 7);
                  },
                  child: const Text('Set Duration'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result > 0) {
      onTypeChanged(CourseDurationType.days);
      onDaysChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MedicoChip(
          label: 'Ongoing',
          isSelected: durationType == CourseDurationType.ongoing,
          onTap: () => onTypeChanged(CourseDurationType.ongoing),
        ),
        if (durationType == CourseDurationType.days)
          MedicoChip(
            label: '$daysCount-day course',
            isSelected: true,
            icon: Icons.calendar_today_rounded,
            trailing: GestureDetector(
              onTap: () => onTypeChanged(CourseDurationType.ongoing),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: AppColors.white),
              ),
            ),
            onTap: () => _showCustomDaysDialog(context),
          ),
        GestureDetector(
          onTap: () => _showCustomDaysDialog(context),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  durationType == CourseDurationType.days ? 'Change days' : 'Add days',
                  style: const TextStyle(
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
