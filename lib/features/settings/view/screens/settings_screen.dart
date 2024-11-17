import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/features/settings/settings.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final powerUnitControllerProvider = powerUnitContextControllerProvider;
    final powerUnitContext = ref.watch(powerUnitControllerProvider);
    final powerUnitController = ref.read(powerUnitControllerProvider.notifier);

    final downsampleContextControllerProvider =
        downsamplingContextControllerProvider;
    final downsampleContext = ref.watch(downsampleContextControllerProvider);
    final downsampleController =
        ref.read(downsampleContextControllerProvider.notifier);

    final themeMode = ref.watch(themeModeControllerProvider);
    final themeController = ref.read(themeModeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.hardCoded),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: Text('Power unit'.hardCoded),
            trailing: DropdownButton<PowerUnit>(
              value: powerUnitContext.unit,
              onChanged: (PowerUnit? newValue) {
                if (newValue == null) return;
                powerUnitController
                    .switchStrategy(PowerUnitStrategy.fromUnit(newValue));
              },
              items: [
                DropdownMenuItem<PowerUnit>(
                  value: PowerUnit.watts,
                  child: Text(PowerUnit.watts.label),
                ),
                DropdownMenuItem<PowerUnit>(
                  value: PowerUnit.kilowatts,
                  child: Text(PowerUnit.kilowatts.label),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.functions),
            title: Text('Sample algorithm'.hardCoded),
            trailing: DropdownButton<DownSamplingAlgorithm>(
              value: downsampleContext.algorithm,
              onChanged: (DownSamplingAlgorithm? newValue) {
                if (newValue == null) return;
                downsampleController.switchStrategy(
                  DownsamplingStrategy.fromAlgorithm(newValue),
                );
              },
              items: [
                DropdownMenuItem<DownSamplingAlgorithm>(
                  value: DownSamplingAlgorithm.none,
                  child: Text(DownSamplingAlgorithm.none.label),
                ),
                DropdownMenuItem<DownSamplingAlgorithm>(
                  value: DownSamplingAlgorithm.lttb,
                  child: Text(DownSamplingAlgorithm.lttb.label),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Theme mode'.hardCoded),
            leading: const Icon(Icons.brightness_6),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeController.setTheme = newValue;
                }
              },
              items: ThemeMode.values.map((ThemeMode mode) {
                return DropdownMenuItem<ThemeMode>(
                  value: mode,
                  child: Text(mode.displayName),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: Text('Clear cache'.hardCoded),
            onTap: () {
              ref
                  .read(
                    monitoringPageControllerProvider(MetricType.solar).notifier,
                  )
                  .clearCache();
              ref
                  .read(
                    monitoringPageControllerProvider(MetricType.house).notifier,
                  )
                  .clearCache();
              ref
                  .read(
                    monitoringPageControllerProvider(MetricType.battery)
                        .notifier,
                  )
                  .clearCache();
            },
          ),
        ],
      ),
    );
  }
}
