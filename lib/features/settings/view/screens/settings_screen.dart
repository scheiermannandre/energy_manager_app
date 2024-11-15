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

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.hardCoded),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Power Unit'.hardCoded),
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
            title: Text('Down Sample Algorithm'.hardCoded),
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
        ],
      ),
    );
  }
}
