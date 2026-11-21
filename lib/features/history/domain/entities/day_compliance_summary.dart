import '../../../dose_tracking/domain/entities/dose_log_entity.dart';

class DayComplianceSummary {
  final DateTime date;
  final int totalDoses;
  final int takenDoses;
  final int skippedDoses;
  final int snoozedDoses;
  final List<DoseLogEntity> logs;

  const DayComplianceSummary({
    required this.date,
    required this.totalDoses,
    required this.takenDoses,
    required this.skippedDoses,
    required this.snoozedDoses,
    required this.logs,
  });

  bool get isFullCompliance => totalDoses > 0 && takenDoses == totalDoses;
  bool get hasSkipped => skippedDoses > 0;
  bool get isPartial => takenDoses > 0 && takenDoses < totalDoses;
  bool get isEmpty => totalDoses == 0;
}
