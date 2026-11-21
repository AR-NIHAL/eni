import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import 'medicine_avatar_badge.dart';

class TodayMedicineCard extends StatelessWidget {
  final MedicineEntity medicine;
  final List<DoseLogEntity> logs;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final void Function(TimeOfDay time)? onQuickTake;

  const TodayMedicineCard({
    super.key,
    required this.medicine,
    this.logs = const [],
    required this.onDelete,
    this.onTap,
    this.onQuickTake,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  int get _takenCount {
    int count = 0;
    for (final t in medicine.schedule.times) {
      final timeStr =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      final log = logs.where((l) => l.scheduledTime == timeStr).firstOrNull;
      if (log != null && log.status == DoseStatus.taken) {
        count++;
      }
    }
    return count;
  }

  bool get _isAllTaken =>
      medicine.schedule.times.isNotEmpty && _takenCount == medicine.schedule.times.length;

  TimeOfDay? _getDisplayTime() {
    if (medicine.schedule.times.isEmpty) return null;
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // Find the next upcoming untaken time today
    for (final t in medicine.schedule.times) {
      final timeStr =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      final log = logs.where((l) => l.scheduledTime == timeStr).firstOrNull;
      final isTaken = log != null && log.status == DoseStatus.taken;

      final tMinutes = t.hour * 60 + t.minute;
      if (!isTaken && tMinutes >= nowMinutes) {
        return t;
      }
    }

    // Next, check any untaken time earlier today
    for (final t in medicine.schedule.times) {
      final timeStr =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      final log = logs.where((l) => l.scheduledTime == timeStr).firstOrNull;
      final isTaken = log != null && log.status == DoseStatus.taken;
      if (!isTaken) {
        return t;
      }
    }

    // If all taken or past, show the last scheduled time
    return medicine.schedule.times.last;
  }

  bool get _isCurrentDoseTaken {
    final displayTime = _getDisplayTime();
    if (displayTime == null) return false;
    final timeStr =
        '${displayTime.hour.toString().padLeft(2, '0')}:${displayTime.minute.toString().padLeft(2, '0')}';
    final log = logs.where((l) => l.scheduledTime == timeStr).firstOrNull;
    return log != null && log.status == DoseStatus.taken;
  }

  String get _subtitleText {
    final qtyUnit = '${medicine.doseQuantity} ${medicine.doseUnit}';
    String? secondary;

    if (medicine.instructions.isNotEmpty) {
      secondary = medicine.instructions.first;
    } else if (medicine.purpose != null && medicine.purpose!.trim().isNotEmpty) {
      secondary = medicine.purpose!.trim();
    } else if (medicine.strength != null && medicine.strength!.trim().isNotEmpty) {
      secondary = medicine.strength!.trim();
    }

    if (secondary != null && secondary.isNotEmpty) {
      return '$qtyUnit · ${secondary.toLowerCase()}';
    }
    return qtyUnit;
  }

  void _showActionSheet(BuildContext context) {
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
                  medicine.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitleText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9BA6),
                  ),
                ),
                const SizedBox(height: 18),

                // Scheduled times quick logging
                const Text(
                  "Today's Doses",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9BA6),
                  ),
                ),
                const SizedBox(height: 8),

                ...medicine.schedule.times.map((t) {
                  final timeStr =
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                  final log = logs.where((l) => l.scheduledTime == timeStr).firstOrNull;
                  final isDoseTaken = log != null && log.status == DoseStatus.taken;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDoseTaken ? Icons.check_circle_rounded : Icons.access_time_rounded,
                              size: 18,
                              color: isDoseTaken ? AppColors.accentLime : Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _formatTime(t),
                              style: TextStyle(
                                color: isDoseTaken ? AppColors.accentLime : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (isDoseTaken)
                          const Row(
                            children: [
                              Icon(Icons.check_rounded, size: 14, color: AppColors.accentLime),
                              SizedBox(width: 4),
                              Text(
                                'Taken',
                                style: TextStyle(
                                  color: AppColors.accentLime,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        else if (onQuickTake != null)
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              onQuickTake!(t);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accentLime,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                'Mark Taken',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),
                if (onTap != null)
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Colors.white),
                    title: const Text('View full details', style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(ctx);
                      onTap!();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Delete medicine', style: TextStyle(color: AppColors.error)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    onDelete();
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
  Widget build(BuildContext context) {
    final displayTime = _getDisplayTime();
    final timeStr = displayTime != null ? _formatTime(displayTime) : null;
    final isTaken = _isCurrentDoseTaken || _isAllTaken;
    final isMultiDose = medicine.schedule.times.length > 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showActionSheet(context),
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1922),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isTaken
                  ? AppColors.accentLime.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 3D Medicine Graphic Avatar Badge
              MedicineAvatarBadge(
                medicine: medicine,
                size: 46,
              ),

              const SizedBox(width: 14),

              // Medicine Name and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitleText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9BA6),
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (timeStr != null) ...[
                const SizedBox(width: 12),
                // Outlined Pill Badge for Dose Time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24202C).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isTaken
                          ? AppColors.accentLime.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTaken) ...[
                        const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: AppColors.accentLime,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _isAllTaken ? 'Done' : timeStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isTaken ? AppColors.accentLime : Colors.white,
                        ),
                      ),
                      if (isMultiDose && !_isAllTaken && _takenCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '($_takenCount/${medicine.schedule.times.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentLime.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
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
