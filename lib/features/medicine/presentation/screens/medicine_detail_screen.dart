import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicine_providers.dart';
import '../widgets/course_hero_card.dart';
import '../widgets/edit_medicine_bottom_sheet.dart';
import '../widgets/full_schedule_bottom_sheet.dart';
import '../widgets/metadata_chips_row.dart';
import '../widgets/stock_refill_card.dart';
import '../widgets/upcoming_schedule_section.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final String medicineId;

  const MedicineDetailScreen({
    super.key,
    required this.medicineId,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref, MedicineEntity medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Medicine', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to permanently delete "${medicine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(deleteMedicineUseCaseProvider)(medicine.id);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${medicine.name}"'),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markDoseTaken(
    BuildContext context,
    WidgetRef ref,
    MedicineEntity medicine,
    UpcomingDoseSlot slot,
  ) async {
    final doseLog = await ref.read(markDoseTakenUseCaseProvider)(
      medicine: medicine,
      date: slot.date,
      scheduledTime: slot.originalTime,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Marked ${slot.dayLabel.toLowerCase()}\'s dose as taken',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.accentLime,
            onPressed: () async {
              await ref.read(undoDoseUseCaseProvider)(
                log: doseLog,
                medicine: medicine,
              );
            },
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = ref.watch(medicineByIdProvider(medicineId));
    final logsAsync = ref.watch(medicineDoseLogsProvider(medicineId));
    final logs = logsAsync.value ?? <DoseLogEntity>[];

    if (medicine == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Medicine Details')),
        body: const Center(child: Text('Medicine not found or has been removed.')),
      );
    }

    final upcomingSlots = UpcomingScheduleSection.computeUpcomingSlots(medicine, logs);
    final nextPendingSlot = upcomingSlots.isNotEmpty ? upcomingSlots.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.primaryDark),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          medicine.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Edit Button (pencil icon)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => EditMedicineBottomSheet.show(context, medicine),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryDark),
              ),
            ),
          ),
          // More options (Delete)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primaryDark),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context, ref, medicine);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Course Hero Card
                    CourseHeroCard(medicine: medicine),
                    const SizedBox(height: 18),

                    // 2. Metadata Chips Row
                    MetadataChipsRow(medicine: medicine),
                    const SizedBox(height: 18),

                    // 2b. Supply & Refill Card
                    StockRefillCard(medicine: medicine),
                    const SizedBox(height: 24),

                    // 3. Upcoming Schedule Section
                    UpcomingScheduleSection(
                      medicine: medicine,
                      logs: logs,
                      onViewFullSchedule: () {
                        FullScheduleBottomSheet.show(
                          context,
                          medicine: medicine,
                          logs: logs,
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 4. Sticky Bottom Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: nextPendingSlot != null
                  ? Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(100),
                      elevation: 2,
                      shadowColor: AppColors.primaryDark.withValues(alpha: 0.12),
                      child: InkWell(
                        onTap: () => _markDoseTaken(context, ref, medicine, nextPendingSlot),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Mark ${nextPendingSlot.dayLabel.toLowerCase()}\'s dose as taken',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentLime,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 22,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                          SizedBox(width: 10),
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
            ),
          ],
        ),
      ),
    );
  }
}
