import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../domain/entities/course_duration_entity.dart';
import '../../domain/entities/medicine_entity.dart';

class UpcomingDoseSlot {
  final DateTime date;
  final String originalTime; // "HH:mm"
  final String dayLabel; // "Tonight", "Tomorrow", "Saturday"
  final String timeLabel; // "9:00 PM"
  final bool isImmediateNext;

  UpcomingDoseSlot({
    required this.date,
    required this.originalTime,
    required this.dayLabel,
    required this.timeLabel,
    required this.isImmediateNext,
  });
}

class UpcomingScheduleSection extends StatelessWidget {
  final MedicineEntity medicine;
  final List<DoseLogEntity> logs;
  final VoidCallback onViewFullSchedule;

  const UpcomingScheduleSection({
    super.key,
    required this.medicine,
    required this.logs,
    required this.onViewFullSchedule,
  });

  static List<UpcomingDoseSlot> computeUpcomingSlots(
    MedicineEntity medicine,
    List<DoseLogEntity> logs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nowMinutes = now.hour * 60 + now.minute;

    final List<UpcomingDoseSlot> slots = [];
    final maxSearchDays = (medicine.duration.daysCount ?? 14).clamp(1, 30);

    // Search upcoming days (from today up to remaining course days or next 30 days)
    for (int dayOffset = 0; dayOffset < maxSearchDays; dayOffset++) {
      final slotDate = today.add(Duration(days: dayOffset));

      // Sort times for the day
      final times = List<TimeOfDay>.from(medicine.schedule.times)
        ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

      for (final t in times) {
        final timeStr =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        final tMinutes = t.hour * 60 + t.minute;

        // If today and time has passed, check if taken or skipped
        final log = logs.where((l) =>
            l.scheduledDate.year == slotDate.year &&
            l.scheduledDate.month == slotDate.month &&
            l.scheduledDate.day == slotDate.day &&
            l.scheduledTime == timeStr).firstOrNull;

        if (log != null && (log.status == DoseStatus.taken || log.status == DoseStatus.skipped)) {
          continue; // Already finished
        }

        // If today and time has already passed by more than 2 hours without log, keep as pending slot
        if (dayOffset == 0 && tMinutes < nowMinutes && log?.status == DoseStatus.taken) {
          continue;
        }

        String dayLabel;
        if (dayOffset == 0) {
          if (t.hour >= 18) {
            dayLabel = 'Tonight';
          } else if (t.hour >= 12) {
            dayLabel = 'This afternoon';
          } else {
            dayLabel = 'Today';
          }
        } else if (dayOffset == 1) {
          dayLabel = 'Tomorrow';
        } else {
          dayLabel = DateFormat('EEEE').format(slotDate);
        }

        slots.add(UpcomingDoseSlot(
          date: slotDate,
          originalTime: timeStr,
          dayLabel: dayLabel,
          timeLabel: DateTimeUtils.formatTime(t),
          isImmediateNext: slots.isEmpty,
        ));

        // Limit to next 2 to 3 slots
        if (slots.length >= 3) return slots;
      }
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = computeUpcomingSlots(medicine, logs);
    final isFixedDays = medicine.duration.durationType == CourseDurationType.days &&
        medicine.duration.daysCount != null;
    final totalDays = medicine.duration.daysCount ?? 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder, width: 0.8),
          ),
          child: Column(
            children: [
              if (slots.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'All upcoming doses completed!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...slots.asMap().entries.map((entry) {
                  final index = entry.key;
                  final slot = entry.value;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Row(
                          children: [
                            // Indicator Dot
                            if (slot.isImmediateNext)
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.accentLime.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentLime,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textMuted,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 14),

                            // Day Label
                            Text(
                              slot.dayLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: slot.isImmediateNext ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),

                            // Time Label
                            Text(
                              slot.timeLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: slot.isImmediateNext ? FontWeight.w700 : FontWeight.w500,
                                color: slot.isImmediateNext ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < slots.length - 1)
                        const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.cardBorder),
                    ],
                  );
                }),
              ],

              // View Full Schedule Action
              const Divider(height: 1, color: AppColors.cardBorder),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onViewFullSchedule,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        isFixedDays
                            ? 'View full $totalDays-day schedule'
                            : 'View full schedule timeline',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
