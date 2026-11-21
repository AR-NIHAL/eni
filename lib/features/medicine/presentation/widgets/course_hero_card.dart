import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_duration_entity.dart';
import '../../domain/entities/medicine_entity.dart';
import 'hero_capsule_graphic.dart';

class CourseHeroCard extends StatelessWidget {
  final MedicineEntity medicine;

  const CourseHeroCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final isFixedDays = medicine.duration.durationType == CourseDurationType.days &&
        medicine.duration.daysCount != null;

    final totalDays = medicine.duration.daysCount ?? 14;
    final elapsedDays = medicine.daysElapsed.clamp(1, totalDays);
    final remainingDays = (totalDays - elapsedDays) < 0 ? 0 : (totalDays - elapsedDays);

    final startDate = medicine.duration.startDate;
    final endDate = medicine.duration.endDate ?? startDate.add(Duration(days: totalDays));

    final progressRatio = isFixedDays
        ? (elapsedDays / totalDays).clamp(0.0, 1.0)
        : 1.0;

    final startStr = DateFormat('d MMM').format(startDate);
    final endStr = DateFormat('d MMM').format(endDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Course fraction & Days left pill on left, 3D Capsule on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isFixedDays) ...[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$elapsedDays',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: ' / $totalDays days',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Pill Badge: "8 days left"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.cardBorder, width: 0.8),
                        ),
                        child: Text(
                          '$remainingDays days left',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Day $elapsedDays',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.cardBorder, width: 0.8),
                        ),
                        child: const Text(
                          'Ongoing treatment',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const HeroCapsuleGraphic(size: 130),
            ],
          ),
          const SizedBox(height: 24),

          // Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentLime),
            ),
          ),
          const SizedBox(height: 8),

          // Start & End dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Started $startStr',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                isFixedDays ? 'Ends $endStr' : 'Continuous',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (medicine.isLowStock) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    'Low stock: ${medicine.stockRemaining ?? 0} ${medicine.doseUnit}s left',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
