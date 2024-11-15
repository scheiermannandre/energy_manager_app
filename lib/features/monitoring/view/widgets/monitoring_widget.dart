import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonitoringWidget extends ConsumerWidget {
  const MonitoringWidget({
    required this.date,
    required this.metricType,
    super.key,
  });
  final DateTime date;
  final MetricType metricType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoringData =
        ref.watch(monitoringWidgetControllerProvider(metricType, date));

    return monitoringData.customWhen(
      data: (data) {
        if (data.isEmpty) {
          return NoDataAvailableWidget(
            onRefresh: () async => ref.invalidate(
              monitoringWidgetControllerProvider(metricType, date),
            ),
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: EnergyChart(
              data: data,
              config: EnergyChartConfig.fromMetrics(metricType),
              date: date.formattedDate,
            ),
          ),
        );
      },
      loading: LoadingWidget.new,
      error: (error, st) => LoadingErrorWidget(
        onReload: () async => ref
            .invalidate(monitoringWidgetControllerProvider(metricType, date)),
        error: error,
        stackTrace: st,
      ),
    );
  }
}
