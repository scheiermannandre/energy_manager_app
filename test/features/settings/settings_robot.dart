import 'package:energy_manager_app/features/features.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

class SettingsRobot {
  SettingsRobot(this.$);

  final PatrolTester $;

  void verifyIsOpen() {
    final finder = $(SettingsScreen);
    expect(finder, findsOneWidget);
  }

  Future<void> goBack() async {
    final backButton = $(Icons.arrow_back);
    expect(backButton, findsOneWidget);
    await $.tap(backButton);
  }

  Future<void> changePowerUnitTo(PowerUnit unit) async {
    final powerUnitDropDownButton = $(DropdownButton<PowerUnit>);
    expect(powerUnitDropDownButton, findsOneWidget);
    await $.tap(powerUnitDropDownButton);
    final unitDropDownItem = $(unit.label);
    expect(unitDropDownItem, findsOneWidget);
    await $.tap(unitDropDownItem);
  }

  Future<void> changeDownsampleAlgorithmTo(
    DownSamplingAlgorithm algorithm,
  ) async {
    final downSamplingDropDownButton = $(DropdownButton<DownSamplingAlgorithm>);
    expect(downSamplingDropDownButton, findsOneWidget);
    await $.tap(downSamplingDropDownButton);
    final downsamplingDropDownItem = $(algorithm.label);
    expect(downsamplingDropDownItem, findsOneWidget);
    await $.tap(downsamplingDropDownItem);
  }

  Future<void> changeThemeModeTo(ThemeMode mode) async {
    final themeModeDropDownButton =
        $(ListTile).containing('Theme mode').$(DropdownButton<String>);
    expect(themeModeDropDownButton, findsOneWidget);
    await $.tap(themeModeDropDownButton);
    final themeModeDropDownItem = $(ValueKey(mode.displayName));
    expect(themeModeDropDownItem, findsAtLeastNWidgets(1));
    await $.tap(themeModeDropDownItem.last);
  }

  void verifyThemeMode(ThemeMode expectedThemeMode) {
    final brightness =
        Theme.of($.tester.element(find.byType(MaterialApp))).brightness;
    final expectedBrightness = expectedThemeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    expect(brightness, expectedBrightness);
  }

  Future<void> clickClearCache() async {
    final clearCacheButton = $(ListTile).containing('Clear cache');
    expect(clearCacheButton, findsOneWidget);
    await $.tap(clearCacheButton);
  }
}
