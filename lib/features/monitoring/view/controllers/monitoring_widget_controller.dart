import 'dart:async';

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
    if (date.date == DateTime.now().date) {
      ref
          .read(pollingServiceProvider(metricType, dateStr))
          .stream
          .listen(streamOnData, onError: streamOnError);
    }
    final link = ref.keepAlive();
    Timer? timer;
    ref
      ..onDispose(() => timer?.cancel())
      ..onCancel(() => timer = Timer(5.minutes, link.close))
      ..onResume(() => timer?.cancel());
    return await ref
        .read(monitoringRepositoryProvider(metricType))
        .loadDate(date: dateStr);
  }

  void clearData() => state = const AsyncValue.data([]);

  void streamOnData(List<MonitoringDataModel> data) => state = AsyncData(data);
  void streamOnError(Object error) =>
      state = AsyncError(error, StackTrace.current);
}
