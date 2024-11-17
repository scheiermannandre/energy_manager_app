import 'package:energy_manager_app/features/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PowerUnitStrategy', () {
    test('WattsStrategy converts correctly', () {
      final strategy = WattsStrategy();
      expect(strategy.convert(1000), equals(1000));
      expect(strategy.unit, equals(PowerUnit.watts));
      expect(strategy.unitLabel, equals('W'));
    });

    test('KilowattsStrategy converts correctly', () {
      final strategy = KilowattsStrategy();
      expect(strategy.convert(1000), equals(1));
      expect(strategy.unit, equals(PowerUnit.kilowatts));
      expect(strategy.unitLabel, equals('kW'));
    });

    test('PowerUnitStrategy.fromUnit returns correct strategy', () {
      final wattsStrategy = PowerUnitStrategy.fromUnit(PowerUnit.watts);
      expect(wattsStrategy, isA<WattsStrategy>());
      expect(wattsStrategy.convert(1000), equals(1000));
      expect(wattsStrategy.unit, equals(PowerUnit.watts));
      expect(wattsStrategy.unitLabel, equals('W'));

      final kilowattsStrategy = PowerUnitStrategy.fromUnit(PowerUnit.kilowatts);
      expect(kilowattsStrategy, isA<KilowattsStrategy>());
      expect(kilowattsStrategy.convert(1000), equals(1));
      expect(kilowattsStrategy.unit, equals(PowerUnit.kilowatts));
      expect(kilowattsStrategy.unitLabel, equals('kW'));
    });
  });
}
