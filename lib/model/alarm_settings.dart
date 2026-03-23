class AlarmAppSettings {
  final bool isActivated;
  final int minutesBefore;

  const AlarmAppSettings({
    this.isActivated = false,
    this.minutesBefore = 30,
  });

  AlarmAppSettings copyWith({bool? isActivated, int? minutesBefore}) {
    return AlarmAppSettings(
      isActivated: isActivated ?? this.isActivated,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }
}