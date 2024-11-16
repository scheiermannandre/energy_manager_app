// ignore_for_file: lines_longer_than_80_chars

import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// DONE
// Graph and Data Visualization
// each with own Tab and user can switch between them
// as line chart
// include Data Preloading
// date filtering
// support Unit Switching
// support Data Downsampling
// support Data Caching
// add option to clear cache
// Pull-to-refresh functionality.

// TODO:
// TODO: Implement user-friendly error messages for connectivity issues or request failures.

// TODO: Include unit tests for core business logic.
// TODO: Add widget tests to validate UI components and interactions
// TODO: Instructions for running the application.
// TODO: Ensure to include detailed documentation for the solution.
// TODO: A short description of trade-offs or design choices made due to time constraints.

// Functional Requirements Compliance: Does the solution meet thefunctional requirements?
// • CodeQuality & Structure: Is the code readable, and modular? Are architecture and statemanagemen twell-applied?
// • Testing: Quality and coverage of unit and widget tests.
// • ErrorHandling: Are error smanaged with user-friendly feedback?
// • Performance: Effective caching and preloading of data.
// • Bonus: Implementation of nice-to-have features like pull-to-refresh, dark mode, and data polling.

// TODO: Optionals
// TODO: Dark mode support.
// TODO: Datapolling to automatically refresh data

void main() {
  runApp(
    ProviderScope(
      child: AppStartupWidget(
        onLoaded: (context) => const MaterialApp(home: MonitoringScreen()),
      ),
    ),
  );
}

class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({required this.onLoaded, super.key});
  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);
    return appStartupState.when(
      loading: () => const AppStartUpLoadingWidget(),
      error: (e, st) => AppStartUpLoadingErrorWidget(
        error: e,
        stackTrace: st,
        onReload: () => ref.invalidate(appStartupProvider),
      ),
      data: (_) => onLoaded(context),
    );
  }
}

@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  final solar = monitoringPageControllerProvider(MetricType.solar);
  final house = monitoringPageControllerProvider(MetricType.house);
  final battery = monitoringPageControllerProvider(MetricType.battery);
  ref.onDispose(() {
    ref
      ..invalidate(solar)
      ..invalidate(house)
      ..invalidate(battery);
  });
  await Future.wait<void>([
    ref.read(solar.future),
    ref.read(house.future),
    ref.read(battery.future),
  ]);
}
