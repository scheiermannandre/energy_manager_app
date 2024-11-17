import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:energy_manager_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrol_finders/patrol_finders.dart';

import 'features/monitoring/monitoring_robot.dart';
import 'features/settings/settings_robot.dart';

class AppRobot {
  AppRobot(this.$) {
    monitoring = MonitoringRobot($, overrides: _overrides);
    settings = SettingsRobot($);
  }

  final PatrolTester $;
  late final MonitoringRobot monitoring;
  late final SettingsRobot settings;

  final List<Override> _overrides = [];

  Future<void> loadApp() async {
    final container = ProviderContainer(overrides: [..._overrides]);
    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
      timeout: 180.seconds,
    );
  }
}
