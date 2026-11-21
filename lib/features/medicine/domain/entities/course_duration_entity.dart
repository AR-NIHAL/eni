enum CourseDurationType {
  ongoing,
  days,
  untilDate;

  String get displayName {
    switch (this) {
      case CourseDurationType.ongoing:
        return 'Ongoing / Long-term';
      case CourseDurationType.days:
        return 'Fixed days';
      case CourseDurationType.untilDate:
        return 'Until specific date';
    }
  }

  static CourseDurationType fromString(String? value) {
    return CourseDurationType.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => CourseDurationType.ongoing,
    );
  }
}

class CourseDurationEntity {
  final CourseDurationType durationType;
  final int? daysCount; // e.g. 10
  final DateTime startDate;
  final DateTime? endDate;

  CourseDurationEntity({
    this.durationType = CourseDurationType.ongoing,
    this.daysCount,
    DateTime? startDate,
    this.endDate,
  }) : startDate = startDate ?? DateTime.now();

  String get displayLabel {
    switch (durationType) {
      case CourseDurationType.ongoing:
        return 'Ongoing';
      case CourseDurationType.days:
        return '${daysCount ?? 7}-day course';
      case CourseDurationType.untilDate:
        if (endDate != null) {
          return 'Until ${endDate!.day}/${endDate!.month}/${endDate!.year}';
        }
        return 'Ongoing';
    }
  }

  CourseDurationEntity copyWith({
    CourseDurationType? durationType,
    int? daysCount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CourseDurationEntity(
      durationType: durationType ?? this.durationType,
      daysCount: daysCount ?? this.daysCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
