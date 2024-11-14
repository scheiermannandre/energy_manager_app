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
}
