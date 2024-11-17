import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MonitoringWidget extends HookConsumerWidget {
  const MonitoringWidget({
    required this.date,
    required this.metricType,
    super.key,
  });
  final DateTime date;
  final MetricType metricType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshIndicatorKey = useState(GlobalKey<RefreshIndicatorState>());
    final monitoringDataProvider =
        monitoringWidgetControllerProvider(metricType, date);
    final monitoringData = ref.watch(monitoringDataProvider);
    ref.listen(monitoringDataProvider, (_, newState) {
      newState.showAlertDialogOnError(context);
    });
    return RefreshIndicator(
      key: refreshIndicatorKey.value,
      onRefresh: () async => ref
          .refresh(monitoringWidgetControllerProvider(metricType, date).future)
          .then((_) {})
          .catchError((_) {}),
      child: monitoringData.when(
        data: (data) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (data.isEmpty)
                Center(
                  child: NoDataAvailableWidget(
                    onRefresh: () async =>
                        await refreshIndicatorKey.value.currentState?.show(),
                  ),
                )
              else
                CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: EnergyChart(
                            data: data,
                            config: EnergyChartConfig.fromMetrics(metricType),
                            date: date.formattedDate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
        loading: LoadingWidget.new,
        error: (error, st) => LoadingErrorWidget(
          onReload: () async =>
              await refreshIndicatorKey.value.currentState?.show(),
          error: error,
          stackTrace: st,
        ),
      ),
    );
  }
}
