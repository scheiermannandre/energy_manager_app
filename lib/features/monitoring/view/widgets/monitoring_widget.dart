import 'package:energy_manager_app/features/monitoring/monitoring.dart';
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
    return monitoringData.when(
      data: (data) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: EnergyChart(data: data, config: EnergyChartConfig()),
          ),
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        return Center(child: Text('Error: $error'));
      },
    );
  }
}
