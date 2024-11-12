import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends HookWidget {
  const MainApp({super.key});

  static const _tabs = <String>[
    'Solar Generation',
    'House Consumption',
    'Battery Consumption',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState<int>(0);
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: selectedIndex.value,
          children: <Widget>[
            MonitoringScreen(
              title: _tabs[0].hardCoded,
              metricType: MetricType.solar,
            ),
            MonitoringScreen(
              title: _tabs[1].hardCoded,
              metricType: MetricType.house,
            ),
            MonitoringScreen(
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
