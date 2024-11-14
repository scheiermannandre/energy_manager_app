import 'dart:async';
import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_page_controller.g.dart';

@riverpod
class MonitoringPageController extends _$MonitoringPageController {
  @override
  FutureOr<MonitoringPageState> build(MetricType metricType) async {
    final now = DateTime.now();
    return MonitoringPageState(
      loadedDates: await _generateAndPreloadListAsync(now),
    );
  }

  List<DateTime> _generateList(DateTime date) {
    return List.generate(
      MonitoringPageState.daysToLoad,
      (index) => date.add((index - MonitoringPageState.index).days),
    );
  }

  Future<List<DateTime>> _generateAndPreloadListAsync(DateTime date) async {
    final dates = _generateList(date);
    await _preloadManyDatesMonitoringData(dates);
    return dates;
  }

  List<DateTime> _generateAndPreloadList(DateTime date) {
    final dates = _generateList(date);
    unawaited(_preloadManyDatesMonitoringData(dates));
    return dates;
  }

  void next() {
    final newDate = state.value!.loadedDates.last.add(1.days);
    final additionalDates = List.generate(
      MonitoringPageState.daysToPreload - 1,
      (index) => newDate.add((index + 1).days),
    );
    unawaited(_preloadManyDatesMonitoringData([newDate, ...additionalDates]));
    state = AsyncValue.data(
      state.value!.copyWith(
        loadedDates: [
          ...state.value!.loadedDates.skip(1),
          newDate,
        ],
      ),
    );
  }

  void prev() {
    final newDate = state.value!.loadedDates.first.subtract(1.days);
    final additionalDates = List.generate(
      MonitoringPageState.daysToPreload - 1,
      (index) => newDate.subtract((index + 1).days),
    );
    unawaited(_preloadManyDatesMonitoringData([newDate, ...additionalDates]));
    state = AsyncValue.data(
      state.value!.copyWith(
        loadedDates: [
          newDate,
          ...state.value!.loadedDates.take(state.value!.loadedDates.length - 1),
        ],
      ),
    );
  }

  void setDate(DateTime date) {
    state = AsyncValue.data(
      MonitoringPageState(loadedDates: _generateAndPreloadList(date)),
    );
  }

  Future<void> _preloadManyDatesMonitoringData(List<DateTime> dates) async {
    // error can be ignored here, since this call is only there to preload the
    // data error handling is done in the Widget actually working with the data
    return Future.wait(dates.map(_preloadDatesMonitoringData))
        .then((data) {})
        .catchError((e) {});
  }

  Future<List<MonitoringDataModel>> _preloadDatesMonitoringData(
    DateTime date,
  ) async =>
      ref.read(monitoringWidgetControllerProvider(metricType, date).future);
}
