import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MedicoStepper extends StatelessWidget {
  final num value;
  final String unit;
  final ValueChanged<num> onChanged;
  final num min;
  final num max;
  final num step;

  const MedicoStepper({
    super.key,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.step = 1,
  });

  void _decrement() {
    if (value - step >= min) {
      onChanged(value - step);
    }
  }

  void _increment() {
    if (value + step <= max) {
      onChanged(value + step);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = value - step >= min;
    final canIncrement = value + step <= max;

    final displayValue = value % 1 == 0 ? value.toInt().toString() : value.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dose',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$displayValue $unit',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildCircleButton(
              icon: Icons.remove,
              onPressed: canDecrement ? _decrement : null,
              enabled: canDecrement,
              isFilled: false,
            ),
            const SizedBox(width: 12),
            _buildCircleButton(
              icon: Icons.add,
              onPressed: canIncrement ? _increment : null,
              enabled: canIncrement,
              isFilled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
    required bool isFilled,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isFilled
              ? (enabled ? AppColors.primaryDark : AppColors.cardBorder)
              : (enabled ? AppColors.cardBorder.withValues(alpha: 0.5) : AppColors.surfaceSubtle),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isFilled
              ? (enabled ? AppColors.white : AppColors.textMuted)
              : (enabled ? AppColors.primaryDark : AppColors.textMuted),
        ),
      ),
    );
  }
}
