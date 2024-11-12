import 'dart:async';

import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_page_controller.g.dart';

@riverpod
class DayPageController extends _$DayPageController {
  @override
  FutureOr<List<MonitoringDataModel>> build(
    MetricType metricType,
    DateTime date,
  ) async {
    final link = ref.keepAlive();
    Timer? timer;
    ref
      ..onDispose(() =>  timer?.cancel() )
      ..onCancel(() => timer = Timer(5.minutes, link.close))
      ..onResume(() => timer?.cancel());

    final data = await ref
        .read(monitoringRepositoryProvider(metricType))
        .loadDate(date: date);
    return data;
  }
}
