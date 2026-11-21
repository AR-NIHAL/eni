import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/entities/course_duration_entity.dart';

class CourseProgressCard extends StatelessWidget {
  final MedicineEntity medicine;

  const CourseProgressCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final isFixedDays = medicine.duration.durationType == CourseDurationType.days &&
        medicine.duration.daysCount != null;

    final progressRatio = medicine.courseProgressRatio ?? 0.0;
    final totalDays = medicine.duration.daysCount ?? 0;
    final elapsedDays = medicine.daysElapsed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_circle_outlined, size: 18, color: AppColors.primaryDark),
                  SizedBox(width: 8),
                  Text(
                    'Course progress',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFixedDays ? AppColors.accentLime : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isFixedDays ? 'Day $elapsedDays of $totalDays' : 'Ongoing treatment',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isFixedDays) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 10,
                backgroundColor: AppColors.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started ${DateTimeUtils.formatDate(medicine.duration.startDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(progressRatio * 100).toInt()}% completed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.all_inclusive_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Continuous medication started on ${DateTimeUtils.formatDate(medicine.duration.startDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
