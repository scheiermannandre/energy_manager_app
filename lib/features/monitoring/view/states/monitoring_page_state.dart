class MonitoringPageState {
  MonitoringPageState({
    required this.loadedDates,
  });

  final List<DateTime> loadedDates;
  DateTime get selectedDate => loadedDates[index];

  static const int daysToLoad = 5;
  static const int daysToPreload = daysToLoad ~/ 2;
  static const int index = daysToLoad ~/ 2;

  MonitoringPageState copyWith({
    List<DateTime>? loadedDates,
    int? selectedIndex,
  }) {
    return MonitoringPageState(
      loadedDates: loadedDates ?? this.loadedDates,
    );
  }
}
