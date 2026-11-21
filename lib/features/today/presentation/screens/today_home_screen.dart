import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';
import '../../../dose_tracking/presentation/widgets/skip_bottom_sheet.dart';
import '../../../dose_tracking/presentation/widgets/snooze_bottom_sheet.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import '../../../medicine/presentation/providers/medicine_providers.dart';
import '../widgets/week_day_strip.dart';
import '../widgets/next_dose_card.dart';
import '../widgets/today_medicine_card.dart';

class TodayHomeScreen extends ConsumerStatefulWidget {
  const TodayHomeScreen({super.key});

  @override
  ConsumerState<TodayHomeScreen> createState() => _TodayHomeScreenState();
}

class _TodayHomeScreenState extends ConsumerState<TodayHomeScreen> {
  DateTime _selectedDate = DateTime.now();

  void _onAddMedicine() {
    context.push(AppRoutes.addNew);
  }

  void _confirmDelete(BuildContext context, MedicineEntity medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Medicine', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to remove "${medicine.name}" from your tracker?'),
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
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(deleteMedicineUseCaseProvider)(medicine.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTaken(ScheduledDoseItem item) async {
    final log = await ref.read(markDoseTakenUseCaseProvider)(
      medicine: item.medicine,
      date: _selectedDate,
      scheduledTime: item.originalTime,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Taken ${item.medicine.doseQuantity} ${item.medicine.doseUnit} of ${item.medicine.name}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.accentLime,
          onPressed: () async {
            await ref.read(undoDoseUseCaseProvider)(
              log: log,
              medicine: item.medicine,
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSnooze(ScheduledDoseItem item) async {
    final duration = await SnoozeBottomSheet.show(context, item.medicine.name);
    if (duration != null) {
      await ref.read(snoozeDoseUseCaseProvider)(
        medicine: item.medicine,
        date: _selectedDate,
        scheduledTime: item.originalTime,
        duration: duration,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Snoozed ${item.medicine.name} for ${duration.inMinutes} minutes.',
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSkip(ScheduledDoseItem item) async {
    final reason = await SkipBottomSheet.show(context, item.medicine.name);
    if (reason != null) {
      final log = await ref.read(skipDoseUseCaseProvider)(
        medicine: item.medicine,
        date: _selectedDate,
        scheduledTime: item.originalTime,
        reason: reason,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Skipped ${item.medicine.name} ($reason)'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.accentLime,
            onPressed: () async {
              await ref.read(undoDoseUseCaseProvider)(
                log: log,
                medicine: item.medicine,
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleToggleMute(ScheduledDoseItem item) async {
    final updated = await ref.read(toggleDoseMuteUseCaseProvider)(
      medicine: item.medicine,
      date: _selectedDate,
      scheduledTime: item.originalTime,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.isAlarmMuted
              ? 'Reminder muted for ${item.medicine.name}'
              : 'Sound alarm enabled for ${item.medicine.name}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEditTime(ScheduledDoseItem item) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: item.effectiveTime,
    );

    if (picked != null) {
      final newTime24 = DateTimeUtils.formatTime24(picked);
      await ref.read(updateDoseTimeForTodayUseCaseProvider)(
        medicine: item.medicine,
        date: _selectedDate,
        originalScheduledTime: item.originalTime,
        newTime24: newTime24,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated time to ${DateTimeUtils.formatTime(picked)} for today!'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicinesAsync = ref.watch(medicinesStreamProvider);
    final dailyLogsAsync = ref.watch(dailyDoseLogsProvider(_selectedDate));
    final nextDoseItem = ref.watch(nextDoseItemProvider(_selectedDate));

    final todayLogs = dailyLogsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Medico Brand Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medication_rounded, size: 16, color: AppColors.accentLime),
                          SizedBox(width: 6),
                          Text(
                            'Medico',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right actions: History button & Today badge
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.history),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.cardBorder, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.insights_rounded, size: 15, color: AppColors.primaryDark),
                                SizedBox(width: 5),
                                Text(
                                  'History',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentLime,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Date & Weekday Strip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateTimeUtils.formatDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    WeekDayStrip(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Content body from Riverpod Stream
            medicinesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryDark),
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading schedule: $err'),
                ),
              ),
              data: (medicines) {
                if (medicines.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.medication_liquid_outlined,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No medicines added yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your medicines to track daily doses, schedules, and refill reminders.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            onPressed: _onAddMedicine,
                            icon: const Icon(Icons.add, color: AppColors.primaryDark),
                            label: const Text(
                              'Add your first medicine',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentLime,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Next dose prominent card or "All caught up" card
                      if (nextDoseItem != null) ...[
                        NextDoseCard(
                          medicine: nextDoseItem.medicine,
                          doseTime: nextDoseItem.effectiveTime,
                          isSnoozed: nextDoseItem.isSnoozed,
                          snoozeUntil: nextDoseItem.snoozedUntil,
                          isMuted: nextDoseItem.isMuted,
                          onTap: () {
                            context.push(
                              AppRoutes.medicineDetailsPath(nextDoseItem.medicine.id),
                            );
                          },
                          onTaken: () => _handleTaken(nextDoseItem),
                          onSnooze: () => _handleSnooze(nextDoseItem),
                          onSkip: () => _handleSkip(nextDoseItem),
                          onToggleMute: () => _handleToggleMute(nextDoseItem),
                          onEditTime: () => _handleEditTime(nextDoseItem),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.cardBorder, width: 0.8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'All caught up for today!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'All scheduled doses for today have been completed or skipped.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Low-Stock Refill Warning Banner (alerts patient before running out)
                      if (medicines.any((m) => m.isLowStock)) ...[
                        ...medicines.where((m) => m.isLowStock).take(2).map((lowMed) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () => context.push(AppRoutes.medicineDetailsPath(lowMed.id)),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1B24),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 18,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'Refill needed',
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '• ${lowMed.name}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFF59E0B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            lowMed.stockRemaining == 0
                                                ? '0 ${lowMed.doseUnit}s left • Out of stock'
                                                : 'Only ${lowMed.stockRemaining} ${lowMed.doseUnit}s remaining',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9E9BA6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentLime,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: const Text(
                                        'Refill',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],

                      // Today's schedule / Later today section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your medicines',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${medicines.length} total',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...medicines.map((med) {
                        final medLogs = todayLogs.where((l) => l.medicineId == med.id).toList();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TodayMedicineCard(
                            medicine: med,
                            logs: medLogs,
                            onTap: () {
                              context.push(
                                AppRoutes.medicineDetailsPath(med.id),
                              );
                            },
                            onDelete: () => _confirmDelete(context, med),
                            onQuickTake: (time) {
                              final timeStr =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              final item = ScheduledDoseItem(
                                medicine: med,
                                originalTime: timeStr,
                                effectiveTime: time,
                              );
                              _handleTaken(item);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 96),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
