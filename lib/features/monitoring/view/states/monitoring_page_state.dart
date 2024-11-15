class MonitoringPageState {
  MonitoringPageState({
    required this.loadedDates,
    required this.startDate,
    this.availableDates = const [],
  });

  final List<DateTime> loadedDates;
  final List<DateTime> availableDates;
  final DateTime startDate;

  static const int daysToLoad = 5;
  static const int daysToPreload = daysToLoad ~/ 2;
  static const int firstDateYear = 2020;

  MonitoringPageState copyWith({
    List<DateTime>? loadedDates,
    List<DateTime>? availableDates,
    DateTime? startDate,
  }) {
    return MonitoringPageState(
      loadedDates: loadedDates ?? this.loadedDates,
      availableDates: availableDates ?? this.availableDates,
      startDate: startDate ?? this.startDate,
    );
  }
}
