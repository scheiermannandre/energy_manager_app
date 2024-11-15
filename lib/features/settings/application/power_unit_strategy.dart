import 'package:energy_manager_app/features/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'power_unit_strategy.g.dart';

abstract class PowerUnitStrategy {
  PowerUnitStrategy();
  factory PowerUnitStrategy.fromUnit(PowerUnit unit) {
    switch (unit) {
      case PowerUnit.watts:
        return WattsStrategy();
      case PowerUnit.kilowatts:
        return KilowattsStrategy();
    }
  }
  String get unitLabel => unit.label;
  PowerUnit get unit;
  double convert(double value);
}

class WattsStrategy extends PowerUnitStrategy {
  @override
  double convert(double value) {
    return value;
  }

  @override
  PowerUnit get unit => PowerUnit.watts;
}

class KilowattsStrategy extends PowerUnitStrategy {
  @override
  double convert(double value) {
    return value / 1000;
  }

  @override
  PowerUnit get unit => PowerUnit.kilowatts;
}

class PowerUnitContext {
  PowerUnitContext(this._strategy);
  final PowerUnitStrategy _strategy;

  String get unitLabel => _strategy.unitLabel;
  PowerUnit get unit => _strategy.unit;

  double convert(double value) => _strategy.convert(value);

  PowerUnitContext fromUnit(PowerUnit unit) {
    switch (unit) {
      case PowerUnit.watts:
        return PowerUnitContext(WattsStrategy());
      case PowerUnit.kilowatts:
        return PowerUnitContext(KilowattsStrategy());
    }
  }
}

@riverpod
class PowerUnitContextController extends _$PowerUnitContextController {
  @override
  PowerUnitContext build() => PowerUnitContext(WattsStrategy());
  void switchStrategy(PowerUnitStrategy strategy) =>
      state = PowerUnitContext(strategy);
}
