import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';

class NextDoseCard extends StatelessWidget {
  final MedicineEntity medicine;
  final TimeOfDay doseTime;
  final bool isSnoozed;
  final DateTime? snoozeUntil;
  final bool isMuted;
  final VoidCallback onTaken;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;
  final VoidCallback? onToggleMute;
  final VoidCallback? onEditTime;
  final VoidCallback? onTap;

  const NextDoseCard({
    super.key,
    required this.medicine,
    required this.doseTime,
    this.isSnoozed = false,
    this.snoozeUntil,
    this.isMuted = false,
    required this.onTaken,
    required this.onSnooze,
    required this.onSkip,
    this.onToggleMute,
    this.onEditTime,
    this.onTap,
  });

  String _getTimeOfDayPeriod(TimeOfDay time) {
    if (time.hour < 12) return 'Morning';
    if (time.hour < 17) return 'Afternoon';
    if (time.hour < 21) return 'Evening';
    return 'Night';
  }

  String _getMedicineSubtitle(MedicineEntity medicine) {
    final unit = medicine.doseUnit.isNotEmpty ? medicine.doseUnit : medicine.type.defaultUnit;
    final qty = medicine.doseQuantity;
    final doseStr = qty == 1 ? '1 dose' : '$qty doses';
    return '${medicine.name} • $doseStr ($unit)';
  }

  String _getInstructionAndPeriod(MedicineEntity medicine, TimeOfDay time) {
    final period = _getTimeOfDayPeriod(time);
    String instruction = 'With water';
    if (medicine.instructions.isNotEmpty) {
      instruction = medicine.instructions.first;
    } else if (medicine.purpose != null && medicine.purpose!.trim().isNotEmpty) {
      instruction = medicine.purpose!.trim();
    }
    return '$instruction - $period';
  }

  String _computeCountdown(TimeOfDay time, bool isSnoozed, DateTime? snoozeUntil) {
    if (isSnoozed && snoozeUntil != null) {
      final diff = snoozeUntil.difference(DateTime.now());
      if (diff.isNegative) return 'Due now';
      if (diff.inMinutes < 60) {
        return 'in ${diff.inMinutes} min';
      }
      final hours = diff.inHours;
      final mins = diff.inMinutes % 60;
      return mins > 0 ? 'in ${hours}h ${mins}m' : 'in ${hours}h';
    }

    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final diff = target.difference(now);
    if (diff.isNegative) {
      return 'Due now';
    }
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return 'in ${mins <= 0 ? 1 : mins} min';
    }
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    return mins > 0 ? 'in ${hours}h ${mins}m' : 'in ${hours}h';
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFF222226),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTime = isSnoozed && snoozeUntil != null
        ? TimeOfDay.fromDateTime(snoozeUntil!)
        : doseTime;

    final hour = effectiveTime.hourOfPeriod == 0 ? 12 : effectiveTime.hourOfPeriod;
    final minute = effectiveTime.minute.toString().padLeft(2, '0');
    final period = effectiveTime.period == DayPeriod.am ? 'AM' : 'PM';
    final timeNumberStr = '$hour:$minute';

    final countdownStr = _computeCountdown(doseTime, isSnoozed, snoozeUntil);
    final instructionPeriodStr = _getInstructionAndPeriod(medicine, effectiveTime);
    final subtitleStr = _getMedicineSubtitle(medicine);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Bar: NEXT DOSE Pill Badge (Left) & Bell Button (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSnoozed ? const Color(0xFFFFB74D) : AppColors.accentLime,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSnoozed) ...[
                      const Icon(Icons.snooze_rounded, size: 13, color: Colors.black),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isSnoozed ? 'SNOOZED' : 'NEXT DOSE',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              if (onToggleMute != null)
                GestureDetector(
                  onTap: onToggleMute,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFF222226),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMuted
                          ? Icons.notifications_off_rounded
                          : Icons.notifications_active_rounded,
                      size: 18,
                      color: isMuted ? AppColors.textMuted : AppColors.accentLime,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Medicine Name & Dose Description (Centered)
          GestureDetector(
            onTap: onTap,
            child: Text(
              subtitleStr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9BA6),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Giant Centered Clock: 10:25 AM
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                timeNumberStr,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pill Chips: in 45 min & With water - Morning
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // Countdown Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF222226),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentLime,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      countdownStr,
                      style: const TextStyle(
                        color: AppColors.accentLime,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Instruction & Period Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF222226),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📌', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      instructionPeriodStr,
                      style: const TextStyle(
                        color: Color(0xFFE4E4E7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Big Full-Width Lime Button: [ ✓ Taken ]
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onTaken,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentLime,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 22, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Taken',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Bottom Row of 3 Secondary Buttons: Snooze, Skip, Edit
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.alarm_rounded,
                  label: 'Snooze',
                  onTap: onSnooze,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Skip',
                  onTap: onSkip,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: onEditTime ?? onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
