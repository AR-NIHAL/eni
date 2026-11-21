enum AdherenceTier {
  high, // >= 90%
  moderate, // 75% - 89%
  needsAttention; // < 75%

  String get displayName {
    switch (this) {
      case AdherenceTier.high:
        return 'High Adherence';
      case AdherenceTier.moderate:
        return 'Moderate Adherence';
      case AdherenceTier.needsAttention:
        return 'Needs Attention';
    }
  }
}

class AdherenceStatsEntity {
  final int totalScheduled;
  final int takenCount;
  final int skippedCount;
  final int snoozedCount;
  final double adherenceRate;
  final int currentStreakDays;
  final int longestStreakDays;

  const AdherenceStatsEntity({
    required this.totalScheduled,
    required this.takenCount,
    required this.skippedCount,
    required this.snoozedCount,
    required this.adherenceRate,
    required this.currentStreakDays,
    required this.longestStreakDays,
  });

  int get adherencePercentage => (adherenceRate * 100).round();

  AdherenceTier get tier {
    if (adherencePercentage >= 90) return AdherenceTier.high;
    if (adherencePercentage >= 75) return AdherenceTier.moderate;
    return AdherenceTier.needsAttention;
  }

  factory AdherenceStatsEntity.empty() {
    return const AdherenceStatsEntity(
      totalScheduled: 0,
      takenCount: 0,
      skippedCount: 0,
      snoozedCount: 0,
      adherenceRate: 1.0,
      currentStreakDays: 0,
      longestStreakDays: 0,
    );
  }
}
