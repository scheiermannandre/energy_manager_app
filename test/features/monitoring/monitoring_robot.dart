import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/features/settings/settings.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_finders/patrol_finders.dart';

import '../../mocks.dart';

class MonitoringRobot {
  MonitoringRobot(this.$, {List<Override> overrides = const []})
      : _overrides = overrides;

  final PatrolTester $;
  final List<Override> _overrides;

  void mockBasicNavigationTestDateSet({num value = 100}) {
    final mockHttpClient = MockHttpClient();

    final json = jsonEncode([
      MonitoringDataModel(value: value, timestamp: clock.now()).toMap(),
    ]);
    when(() => mockHttpClient.get(any())).thenAnswer(
      (_) async {
        return http.Response(json, 200);
      },
    );
    _overrides.addAll([
      httpClientProvider.overrideWithValue(mockHttpClient),
    ]);
  }

  void mockErrorInitalLoadingData() {
    final mockHttpClient = MockHttpClient();
    final json = jsonEncode([
      MonitoringDataModel(value: 100, timestamp: clock.now()).toMap(),
    ]);
    var counter = 0;
    when(() => mockHttpClient.get(any())).thenAnswer(
      (_) async {
        if (counter == 0) {
          counter++;
          return http.Response('Error', 500);
        }
        return http.Response(json, 200);
      },
    );
    _overrides.addAll([
      httpClientProvider.overrideWithValue(mockHttpClient),
    ]);
  }

  void mockNavigatingPageViewDateSet() {
    final mockHttpClient = MockHttpClient();

    void makeOkDataSet(DateTime startTime, int days, MetricType type) {
      final datasets = <String, String>{};
      for (var i = 0; i < days; i++) {
        final date = startTime.subtract(i.days);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        final data = [
          MonitoringDataModel(value: 100, timestamp: date).toMap(),
          MonitoringDataModel(value: 150, timestamp: date.add(1.hours)).toMap(),
        ];
        datasets[
                'http://localhost:3000/monitoring?date=$dateStr&type=${type.name}'] =
            jsonEncode(data);
      }

      for (final entry in datasets.entries) {
        when(() => mockHttpClient.get(Uri.parse(entry.key))).thenAnswer(
          (_) async {
            return http.Response(entry.value, 200);
          },
        );
      }
    }

    makeOkDataSet(clock.now(), 5, MetricType.solar);
    makeOkDataSet(clock.now(), 5, MetricType.house);
    makeOkDataSet(clock.now(), 5, MetricType.battery);
    _overrides.addAll([
      httpClientProvider.overrideWithValue(mockHttpClient),
    ]);
  }

  void verifyIsOpen() {
    final finder = $(MonitoringScreen);
    expect(finder, findsOneWidget);
  }

  void verifyTabIsSelected(int index) {
    final finder = $(BottomNavigationBar);
    expect(finder, findsOneWidget);

    final bottomNavigationBar =
        finder.evaluate().single.widget as BottomNavigationBar;
    expect(bottomNavigationBar.currentIndex, index);
  }

  Future<void> clickIcon(IconData icon) async {
    final finder = $(icon);
    expect(finder, findsOneWidget);
    await $.tap(finder);
  }

  Future<void> clickSolarGenerationTab() async => clickIcon(Icons.wb_sunny);

  Future<void> clickHouseConsumptionTab() async => clickIcon(Icons.home);

  Future<void> clickBatteryConsumptionTab() async =>
      clickIcon(Icons.battery_full);

  Future<void> goToSettings() async {
    await clickIcon(Icons.settings_outlined);
  }

  Future<void> verifyDateAndChart(DateTime date) async {
    final chartFinder = $(EnergyChart).$(ValueKey(date.formattedDate));
    expect(chartFinder, findsOneWidget);
    final dateFinder = $(date.formattedDate);
    expect(dateFinder, findsOneWidget);
  }

  Future<void> clickGoPreviousDateButton() async =>
      clickIcon(Icons.keyboard_arrow_left_rounded);

  Future<void> clickGoNextDateButton() async =>
      clickIcon(Icons.keyboard_arrow_right_rounded);

  Future<void> verifyStartUpErroWidget() async {
    final finder = $(AppStartUpLoadingErrorWidget);
    expect(finder, findsOneWidget);
  }

  Future<void> verifyErrorDialogAndClickOk() async {
    final finder = $(AlertDialog).$('OK');
    expect(finder, findsOneWidget);
    await $.tap(finder);
    expect(finder, findsNothing);
  }

  Future<void> clickTryAgain() async {
    final finder = $('Try again');
    expect(finder, findsOneWidget);
    await $.tap(finder);
  }

  Future<void> verifyYAxisLabel(PowerUnit unit) async {
    final finder = $(EnergyChart).$('Power in ${unit.label}');
    expect(finder, findsOneWidget);
  }

  Future<void> verifyCorrectPowerValue(String powerValue) async {
    final finder = $(EnergyChart).$(powerValue);
    expect(finder, findsOneWidget);
  }

  Future<void> verifyNoDataWidget() async {
    final finder = $(NoDataAvailableWidget);
    expect(finder, findsOneWidget);
  }

  Future<void> verifyNoDataWidgetAndTryRefresh() async {
    await verifyNoDataWidget();
    await clickTryAgain();
  }
}
