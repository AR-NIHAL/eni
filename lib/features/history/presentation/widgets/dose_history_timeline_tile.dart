import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';

class DoseHistoryTimelineTile extends ConsumerWidget {
  final DoseLogEntity log;
  final VoidCallback? onUndo;

  const DoseHistoryTimelineTile({
    super.key,
    required this.log,
    this.onUndo,
  });

  String _formatScheduledTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2024, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return time24;
    }
  }

  void _showLogOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  log.medicineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${log.doseQuantity} ${log.doseUnit} • Scheduled ${_formatScheduledTime(log.scheduledTime)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9BA6),
                  ),
                ),
                const SizedBox(height: 18),
                if (log.status != DoseStatus.taken)
                  ListTile(
                    leading: const Icon(Icons.check_circle_rounded, color: AppColors.accentLime),
                    title: const Text('Mark as Taken', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final updated = log.copyWith(
                        status: DoseStatus.taken,
                        actualActionTime: DateTime.now(),
                      );
                      await ref.read(doseRepositoryProvider).saveDoseLog(updated);
                    },
                  ),
                if (log.status != DoseStatus.skipped)
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined, color: Color(0xFFFFB74D)),
                    title: const Text('Mark as Skipped', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final updated = log.copyWith(
                        status: DoseStatus.skipped,
                        skipReason: 'Marked from history',
                        actualActionTime: DateTime.now(),
                      );
                      await ref.read(doseRepositoryProvider).saveDoseLog(updated);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Delete this log', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(doseRepositoryProvider).deleteDoseLog(log.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTaken = log.status == DoseStatus.taken;
    final isSkipped = log.status == DoseStatus.skipped;
    final isSnoozed = log.status == DoseStatus.snoozed;

    String actionTimeStr = '';
    if (log.actualActionTime != null) {
      actionTimeStr = DateFormat('h:mm a').format(log.actualActionTime!);
    }

    final scheduledTimeFormatted = _formatScheduledTime(log.scheduledTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogOptions(context, ref),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status icon circle
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isTaken
                          ? AppColors.accentLime
                          : (isSkipped
                              ? AppColors.error.withValues(alpha: 0.15)
                              : (isSnoozed
                                  ? AppColors.warning.withValues(alpha: 0.2)
                                  : AppColors.surfaceSubtle)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isTaken
                            ? Icons.check_rounded
                            : (isSkipped ? Icons.close_rounded : Icons.alarm_rounded),
                        size: 20,
                        color: isTaken
                            ? AppColors.primaryDark
                            : (isSkipped ? AppColors.error : AppColors.warning),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Medicine details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.medicineName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${log.doseQuantity} ${log.doseUnit} • Scheduled $scheduledTimeFormatted',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Time badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isTaken
                              ? AppColors.accentLime.withValues(alpha: 0.3)
                              : (isSkipped
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.surfaceSubtle),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          isTaken ? 'Taken' : (isSkipped ? 'Skipped' : 'Snoozed'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isTaken
                                ? AppColors.primaryDark
                                : (isSkipped ? AppColors.error : AppColors.textPrimary),
                          ),
                        ),
                      ),
                      if (actionTimeStr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          actionTimeStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Skip Reason tag (if present)
              if (log.skipReason != null && log.skipReason!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.cardBorder, width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        'Reason: ${log.skipReason}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
