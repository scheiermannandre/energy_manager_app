import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:energy_manager_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MonitoringScreen extends HookConsumerWidget {
  const MonitoringScreen({super.key});

  static const _tabs = <String>[
    'Solar Generation',
    'House Consumption',
    'Battery Consumption',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartUpProvider);

    final selectedIndex = useState<int>(0);

    return appStartupState.customWhen(
      loading: () => const AppStartUpLoadingWidget(),
      error: (e, st) => AppStartUpLoadingErrorWidget(
        error: e,
        stackTrace: st,
        onReload: () => ref.refresh(appStartUpProvider),
      ),
      data: (_) => Scaffold(
        body: IndexedStack(
          index: selectedIndex.value,
          children: <Widget>[
            MonitoringPage(
              title: _tabs[0].hardCoded,
              metricType: MetricType.solar,
            ),
            MonitoringPage(
              title: _tabs[1].hardCoded,
              metricType: MetricType.house,
            ),
            MonitoringPage(
              title: _tabs[2].hardCoded,
              metricType: MetricType.battery,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.wb_sunny),
              label: _tabs[0].hardCoded,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: _tabs[1].hardCoded,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.battery_full),
              label: _tabs[2].hardCoded,
            ),
          ],
          currentIndex: selectedIndex.value,
          onTap: (value) => selectedIndex.value = value,
        ),
      ),
    );
  }
}
