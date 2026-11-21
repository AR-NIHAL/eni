import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../domain/entities/medicine_entity.dart';

class FullScheduleBottomSheet extends StatelessWidget {
  final MedicineEntity medicine;
  final List<DoseLogEntity> logs;

  const FullScheduleBottomSheet({
    super.key,
    required this.medicine,
    required this.logs,
  });

  static Future<void> show(
    BuildContext context, {
    required MedicineEntity medicine,
    required List<DoseLogEntity> logs,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FullScheduleBottomSheet(
        medicine: medicine,
        logs: logs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = medicine.duration.daysCount ?? 14;
    final startDate = medicine.duration.startDate;

    final days = List.generate(totalDays, (index) => startDate.add(Duration(days: index)));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Course Schedule',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${medicine.name} • $totalDays-day course',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: days.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
              itemBuilder: (context, index) {
                final dayDate = days[index];
                final dayNum = index + 1;
                final isToday = dayDate.year == DateTime.now().year &&
                    dayDate.month == DateTime.now().month &&
                    dayDate.day == DateTime.now().day;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.primaryDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday ? AppColors.accentLime : AppColors.cardBorder,
                            width: isToday ? 1.2 : 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Day $dayNum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isToday ? AppColors.accentLime : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              DateFormat('d MMM').format(dayDate),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isToday ? AppColors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: medicine.schedule.times.map((t) {
                            final timeStr =
                                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                            final log = logs.where((l) =>
                                l.scheduledDate.year == dayDate.year &&
                                l.scheduledDate.month == dayDate.month &&
                                l.scheduledDate.day == dayDate.day &&
                                l.scheduledTime == timeStr).firstOrNull;

                            Color chipBg = AppColors.surfaceSubtle;
                            Color chipBorder = AppColors.cardBorder;
                            Color textColor = AppColors.primaryDark;
                            IconData icon = Icons.access_time_rounded;

                            if (log != null) {
                              if (log.status == DoseStatus.taken) {
                                chipBg = AppColors.success.withValues(alpha: 0.15);
                                chipBorder = AppColors.success;
                                textColor = AppColors.success;
                                icon = Icons.check_circle_rounded;
                              } else if (log.status == DoseStatus.skipped) {
                                chipBg = AppColors.surfaceSubtle;
                                chipBorder = AppColors.cardBorder;
                                textColor = AppColors.textMuted;
                                icon = Icons.cancel_outlined;
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: chipBg,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: chipBorder, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 12, color: textColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateTimeUtils.formatTime(t),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
