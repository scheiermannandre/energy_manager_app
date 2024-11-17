import 'dart:async';
import 'package:clock/clock.dart';
import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_page_controller.g.dart';

// * due to time constraints this controller is implemented as singleton
// * this is not the desired behaviour, but there was not enough time to figure
// * out why the approach with fake_async and simulating time did not work
// * out as planned. The whole idea is to eagerly load on app start up, but
// * since is not instantly watched it would be disposed,
// * thus the data would be lost.
@Riverpod(keepAlive: true)
// @riverpod
class MonitoringPageController extends _$MonitoringPageController {
  @override
  FutureOr<MonitoringPageState> build(MetricType metricType) async {
    // the keep alive on that controller is necessary to keep the link alive,
    // after it was eagerly initialized, otherwise the controller would be
    // disposed after the first build, thus all data would be lost
    // final link = ref.keepAlive();
    // Timer? timer;
    //  ref
    //   ..onDispose(() => timer?.cancel())
    //   ..onCancel(() => timer = Timer(30.seconds, link.close))
    //   ..onResume(() => timer?.cancel());
    return _init();
  }

  Future<MonitoringPageState> _init() async {
    final now = clock.now().date;
    final loadedDates = await _generateAndPreloadListAsync(now);
    return MonitoringPageState(
      startDate: now,
      loadedDates: loadedDates,
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
    // error happening here should NOT be caught, as this is the initial load
    // since the users have not yet interacted with the app, we only let them
    // pass, if data ia aactually available. Errors will be displayed at the
    // app start up level.
    await _preloadManyDatesMonitoringData(dates);
    return dates;
  }

  List<DateTime> _generateList(DateTime date) {
    if (date.formattedDate == clock.now().formattedDate) {
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

  Future<void> _preloadManyDatesMonitoringData(
    List<DateTime> dates, {
    bool catchErrors = false,
  }) async {
    if (catchErrors) {
      return Future.wait(dates.map(_preloadDatesMonitoringData))
          .then((_) {})
          .catchError((e) {});
    } else {
      return Future.wait(dates.map(_preloadDatesMonitoringData)).then((_) {});
    }
  }

  Future<List<MonitoringDataModel>> _preloadDatesMonitoringData(
    DateTime date,
  ) async =>
      ref.refresh(monitoringWidgetControllerProvider(metricType, date).future);

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
    // catch errors because at this point in time we are not in the startup
    // phase and the user once fetched data, so its likely he experiences just a
    // temporary issue, which should be displayed at the widget level
    // rather than here.
    unawaited(_preloadManyDatesMonitoringData(missingDates, catchErrors: true));
  }
}
