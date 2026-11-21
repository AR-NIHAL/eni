import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dose_tracking/domain/entities/dose_log_entity.dart';
import '../../domain/entities/adherence_stats_entity.dart';

class ExportReportSheet extends StatelessWidget {
  final DateTime selectedMonth;
  final AdherenceStatsEntity stats;
  final List<DoseLogEntity> logs;

  const ExportReportSheet({
    super.key,
    required this.selectedMonth,
    required this.stats,
    required this.logs,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime selectedMonth,
    required AdherenceStatsEntity stats,
    required List<DoseLogEntity> logs,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExportReportSheet(
        selectedMonth: selectedMonth,
        stats: stats,
        logs: logs,
      ),
    );
  }

  String _generatePlainTextReport() {
    final monthStr = DateFormat('MMMM yyyy').format(selectedMonth);
    final buffer = StringBuffer();
    buffer.writeln('=======================================');
    buffer.writeln('MEDICO - MEDICATION ADHERENCE REPORT');
    buffer.writeln('Period: $monthStr');
    buffer.writeln('Generated on: ${DateFormat('d MMM yyyy, h:mm a').format(DateTime.now())}');
    buffer.writeln('=======================================');
    buffer.writeln('');
    buffer.writeln('SUMMARY');
    buffer.writeln('• Overall Adherence: ${stats.adherencePercentage}% (${stats.tier.displayName})');
    buffer.writeln('• Total Doses Scheduled: ${stats.totalScheduled}');
    buffer.writeln('• Doses Taken: ${stats.takenCount}');
    buffer.writeln('• Doses Skipped: ${stats.skippedCount}');
    buffer.writeln('• Current Consecutive Streak: ${stats.currentStreakDays} days');
    buffer.writeln('');
    buffer.writeln('---------------------------------------');
    buffer.writeln('RECENT DOSE LOG ENTRIES');
    buffer.writeln('---------------------------------------');

    if (logs.isEmpty) {
      buffer.writeln('No dose entries recorded for this period.');
    } else {
      for (final log in logs.take(30)) {
        final dateStr = DateFormat('d MMM yyyy').format(log.scheduledDate);
        final statusStr = log.status.name.toUpperCase();
        buffer.writeln('[$statusStr] $dateStr • ${log.medicineName} (${log.doseQuantity} ${log.doseUnit})');
        buffer.writeln('  Scheduled: ${log.scheduledTime}');
        if (log.actualActionTime != null) {
          buffer.writeln('  Actual: ${DateFormat('h:mm a').format(log.actualActionTime!)}');
        }
        if (log.skipReason != null) {
          buffer.writeln('  Skip Reason: ${log.skipReason}');
        }
        buffer.writeln('');
      }
    }

    buffer.writeln('=======================================');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMMM yyyy').format(selectedMonth);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Physician Report',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Adherence Summary for $monthStr',
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
                  child: const Icon(Icons.close_rounded, size: 20, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Report Preview Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  _generatePlainTextReport(),
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Copy Action Button
          ElevatedButton.icon(
            onPressed: () async {
              final text = _generatePlainTextReport();
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Adherence report copied to clipboard!',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded, color: AppColors.white, size: 18),
            label: const Text(
              'Copy Report to Clipboard',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
