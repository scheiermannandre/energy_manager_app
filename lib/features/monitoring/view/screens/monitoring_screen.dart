import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({
    required this.title,
    required this.metricType,
    super.key,
  });

  final String title;
  final MetricType metricType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState =
        ref.watch(monitoringScreenControllerProvider(metricType));
    final controller =
        ref.read(monitoringScreenControllerProvider(metricType).notifier);
    return asyncState.when(
      data: (state) => Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(title),
        ),
        body: Column(
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Center(
                child: Text(state.selectedDate.toIso8601String()),
              ),
            ),
            const Center(
              child: EnergyChart(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.loadNextDatesMonitoringData,
        ),
      ),
      error: (e, st) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
