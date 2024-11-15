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

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.hardCoded),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Units'.hardCoded),
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
                  child: Text('Watts'.hardCoded),
                ),
                DropdownMenuItem<PowerUnit>(
                  value: PowerUnit.kilowatts,
                  child: Text('Kilowatts'.hardCoded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
