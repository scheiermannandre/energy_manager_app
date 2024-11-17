import 'package:clock/clock.dart';
import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_widget_controller.g.dart';

@riverpod
class MonitoringWidgetController extends _$MonitoringWidgetController {
  @override
  FutureOr<List<MonitoringDataModel>> build(
    MetricType metricType,
    DateTime date,
  ) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (date.date == clock.now().date) {
      ref
          .read(pollingServiceProvider(metricType, dateStr))
          .stream
          .listen(streamOnData, onError: streamOnError);
    }
    // * currently turned off for testing purposes
    // * this is a way to keep the controller alive, even if the widget is not
    // * visible, so that the data is not lost, which is the desired behaviour
    // * in the planned architecture, due to time constraints, it could not be
    // * tested with simulating time via fake_async
    //
    // final link = ref.keepAlive();
    // Timer? timer;
    // ref
    //   ..onDispose(() => timer?.cancel())
    //   ..onCancel(() => timer = Timer(5.minutes, link.close))
    //   ..onResume(() => timer?.cancel());
    final data = await ref
        .read(monitoringRepositoryProvider(metricType))
        .loadDate(date: dateStr);

    return data;
  }

  void clearData() => state = const AsyncValue.data([]);

  void streamOnData(List<MonitoringDataModel> data) => state = AsyncData(data);
  void streamOnError(Object error) =>
      state = AsyncError(error, StackTrace.current);
}
