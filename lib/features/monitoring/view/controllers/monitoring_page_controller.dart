import 'dart:async';
import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_page_controller.g.dart';

@riverpod
class MonitoringPageController extends _$MonitoringPageController {
  @override
  FutureOr<MonitoringPageState> build(MetricType metricType) async {
    // the keep alive on that controller is necessary to keep the link alive,
    // after it was eagerly initialized, otherwise the controller would be
    // disposed after the first build, thus all data would be lost
    final link = ref.keepAlive();
    Timer? timer;
    ref
      ..onDispose(() => timer?.cancel())
      ..onCancel(() => timer = Timer(30.seconds, link.close))
      ..onResume(() => timer?.cancel());
    final now = DateTime.now().date;
    return MonitoringPageState(
      startDate: now,
      loadedDates: await _generateAndPreloadListAsync(now),
      availableDates: List.generate(
        now.difference(DateTime(MonitoringPageState.firstDateYear)).inDays,
        (index) => now.subtract(index.days).date,
      )..sort(),
    );
  }

  void clearCache() {
    state.value?.loadedDates.forEach(
      (date) => ref
          .read(monitoringWidgetControllerProvider(metricType, date).notifier)
          .clearData(),
    );
  }

  Future<List<DateTime>> _generateAndPreloadListAsync(DateTime date) async {
    final dates = _generateList(date);
    await _preloadManyDatesMonitoringData(dates);
    return dates;
  }

  List<DateTime> _generateList(DateTime date) {
    if (date.formattedDate == DateTime.now().formattedDate) {
      return List.generate(
        MonitoringPageState.daysToPreload + 1,
        (index) => date.subtract(index.days).date,
      );
    } else {
      return List.generate(
        MonitoringPageState.daysToLoad,
        (index) =>
            date.add((index - MonitoringPageState.daysToPreload).days).date,
      );
    }
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

  void preloadData(DateTime date) {
    final neededDates = _generateList(date);
    final missingDates = neededDates
        .where((element) => !state.value!.loadedDates.contains(element))
        .toList();
    state = AsyncValue.data(
      state.value!.copyWith(
        loadedDates: [
          ...missingDates,
          ...state.value!.loadedDates,
        ]..sort(),
      ),
    );
    unawaited(_preloadManyDatesMonitoringData(missingDates));
  }
}
