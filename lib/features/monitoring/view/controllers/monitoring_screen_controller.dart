import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/features/monitoring/view/controllers/day_page_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_screen_controller.g.dart';

class MonitoringScreenState {
  MonitoringScreenState({
    required this.loadedDates,
    required this.selectedIndex,
  });

  final List<DateTime> loadedDates;
  final int selectedIndex;
  DateTime get selectedDate => loadedDates[selectedIndex];

  MonitoringScreenState copyWith({
    List<DateTime>? loadedDates,
    int? selectedIndex,
  }) {
    return MonitoringScreenState(
      loadedDates: loadedDates ?? this.loadedDates,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

@riverpod
class MonitoringScreenController extends _$MonitoringScreenController {
  @override
  FutureOr<MonitoringScreenState> build(MetricType metricType) async {
    final now = DateTime.now();
    // Load data for the last 5 days
    final dates =
        List.generate(5, (index) => now.subtract(Duration(days: index)))
          ..sort();
    final results = await Future.wait(dates.map(_fetchDatesMonitoringData));

    // Check if all results are successful
    if (results.every((result) => result is AsyncData)) {
      return MonitoringScreenState(
        loadedDates: dates,
        selectedIndex: dates.length - 1,
      );
    } else {
      throw Exception('Failed to load data for the last 5 days');
    }
  }

  Future<void> loadNextDatesMonitoringData() async {
    await loadDatesMonitoringData(
      state.value!.loadedDates.lastOrNull!.add(const Duration(days: 1)),
    );
  }

  Future<void> loadPreviousDatesMonitoringData() async {}

  Future<List<MonitoringDataModel>> _fetchDatesMonitoringData(
    DateTime date,
  ) async =>
      ref.read(dayPageControllerProvider(metricType, date).future);

  Future<void> loadDatesMonitoringData(DateTime date) async {
    state = const AsyncLoading();

    final result =
        await AsyncValue.guard(() => _fetchDatesMonitoringData(date));

    if (result is AsyncData) {
      state = AsyncData(
        state.value!.copyWith(
          loadedDates: [...state.value!.loadedDates, date],
          selectedIndex: state.value!.loadedDates.length,
        ),
      );
    } else if (result is AsyncError) {
      state = AsyncError(result.error!, result.stackTrace!);
    }
  }
}
