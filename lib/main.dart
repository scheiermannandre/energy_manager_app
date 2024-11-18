// ignore_for_file: lines_longer_than_80_chars

import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

void main() {
  runApp(
    const ProviderScope(child: App()),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: const MonitoringScreen(),
    );
  }
}

// * currently not used, due to difficulties testing with simulating time via fake_async
// * with enough time the desired behaviour would be to eagerly load the data on app
// * start up, but since the monitoring page controller would be disposed after the first build,
// * since it is not instantly watched
//
// class AppStartupWidget extends ConsumerWidget {
//   const AppStartupWidget({required this.onLoaded, super.key});
//   final WidgetBuilder onLoaded;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appStartupState = ref.watch(appStartUpProvider);
//     return appStartupState.customWhen(
//       loading: () => const AppStartUpLoadingWidget(),
//       error: (e, st) => AppStartUpLoadingErrorWidget(
//         error: e,
//         stackTrace: st,
//         onReload: () => ref.refresh(appStartUpProvider),
//       ),
//       data: (_) => onLoaded(context),
//     );
//   }
// }

// * this is supposed to be the eagerly loaded data on app start up
// * currently it is used in the startup of the monitoring screen
@Riverpod(keepAlive: true)
FutureOr<void> appStartUp(Ref ref) async {
  final solar = monitoringPageControllerProvider(MetricType.solar);
  final house = monitoringPageControllerProvider(MetricType.house);
  final battery = monitoringPageControllerProvider(MetricType.battery);
  await Future.wait<void>([
    ref.refresh(solar.future),
    ref.refresh(house.future),
    ref.refresh(battery.future),
  ]);
}
