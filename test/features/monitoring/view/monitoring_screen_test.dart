import 'package:clock/clock.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_finders/patrol_finders.dart';

import '../../../test.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('''Screen Navigation''', () {
    Future<AppRobot> loadApp(PatrolTester $) async {
      final robot = AppRobot($);
      robot.monitoring.mockBasicNavigationTestDateSet();
      await robot.loadApp();
      return robot;
    }

    patrolWidgetTest(
      '''
      GIVEN data can be loaded
      WHEN the app is started
      THEN the monitoring screen is shown and the Solar Generation tab is selected
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          robot.monitoring.verifyIsOpen();
          robot.monitoring.verifyTabIsSelected(0);
        });
      },
      timeout: Timeout(10.seconds),
    );
    patrolWidgetTest(
      '''
      GIVEN the app has started
      WHEN the house consumption tab is clicked
      THEN the house consumption tab is selected
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.clickHouseConsumptionTab();
          robot.monitoring.verifyTabIsSelected(1);
        });
      },
      timeout: Timeout(10.seconds),
    );

    patrolWidgetTest(
      '''
      GIVEN the app has started
      WHEN the battery consumption tab is clicked
      THEN the battery consumption tab is selected
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.clickBatteryConsumptionTab();
          robot.monitoring.verifyTabIsSelected(2);
        });
      },
      timeout: Timeout(10.seconds),
    );

    patrolWidgetTest(
      '''
      GIVEN the app has started
      AND the battery consumption tab is clicked
      WHEN the solar generation tab is clicked
      THEN the solar generation tab is selected
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.clickBatteryConsumptionTab();
          await robot.monitoring.clickSolarGenerationTab();
          robot.monitoring.verifyTabIsSelected(0);
        });
      },
      timeout: Timeout(10.seconds),
    );

    patrolWidgetTest(
      '''
      GIVEN the app has started
      AND the Monitoring screen is shown
      WHEN the settings icon in the app bar is clicked
      THEN the settings screen is shown
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.goToSettings();
          robot.settings.verifyIsOpen();
          await robot.settings.goBack();
          robot.monitoring.verifyIsOpen();
        });
      },
      timeout: Timeout(10.seconds),
    );
  });

  group('''Navigating through dates''', () {
    final fakeClock = Clock(() => DateTime(2024, 11, 17, 17, 17));

    Future<AppRobot> loadApp(PatrolTester $) async {
      final robot = AppRobot($);
      robot.monitoring.mockNavigatingPageViewDateSet();
      await robot.loadApp();
      return robot;
    }

    patrolWidgetTest(
      '''
      GIVEN data can be loaded
      WHEN the app is started
      THEN the monitoring screen is shown and the Solar Generation tab is selected
      AND the current date is shown
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          await withClock(fakeClock, () async {
            final robot = await loadApp($);
            await robot.monitoring.verifyDateAndChart(clock.now());
          });
        });
      },
      timeout: Timeout(10.seconds),
    );
    patrolWidgetTest(
      '''
      GIVEN the Solar Generation tab is open
      AND the current date is shown
      WHEN the user clicks on the left arrow
      THEN the previous day is shown
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          await withClock(fakeClock, () async {
            final robot = await loadApp($);
            await robot.monitoring.clickGoPreviousDateButton();
            await robot.monitoring
                .verifyDateAndChart(clock.now().subtract(1.days));
          });
        });
      },
      timeout: Timeout(10.seconds),
    );

    patrolWidgetTest(
      '''
      GIVEN the Solar Generation tab is open
      AND the yesterdays date is shown
      WHEN the clicks on the right arrow
      THEN the next day is shown
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          await withClock(fakeClock, () async {
            final robot = await loadApp($);
            await robot.monitoring.clickGoPreviousDateButton();
            await robot.monitoring.clickGoNextDateButton();
            await robot.monitoring.verifyDateAndChart(clock.now());
          });
        });
      },
      timeout: Timeout(10.seconds),
    );
  });

  group('''Error Handling''', () {
    Future<AppRobot> loadApp(PatrolTester $) async {
      final robot = AppRobot($);
      robot.monitoring.mockErrorInitalLoadingData();
      await robot.loadApp();
      return robot;
    }

    patrolWidgetTest(
      '''
      GIVEN the app has been started
      AND the monitoring screen is loading
      WHEN an error occurs
      THEN the user is shown an error
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.verifyStartUpErroWidget();
          await robot.monitoring.verifyErrorDialogAndClickOk();
        });
      },
      timeout: Timeout(10.seconds),
    );

    patrolWidgetTest(
      '''
      GIVEN the user has seen an inital loading error
      WHEN the user has clicked on the try again button
      THEN the energy chart for the current date is visible
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.verifyErrorDialogAndClickOk();
          await robot.monitoring.clickTryAgain();
          await robot.monitoring.verifyDateAndChart(clock.now());
        });
      },
      timeout: Timeout(10.seconds),
    );
  });

  group('''Caching''', () {
    Future<AppRobot> loadApp(PatrolTester $) async {
      final robot = AppRobot($);
      robot.monitoring.mockNavigatingPageViewDateSet();
      await robot.loadApp();
      return robot;
    }

    patrolWidgetTest(
      '''
      GIVEN the app has been started
      AND the data was loaded
      WHEN the user goes to settings
      AND clicks clear cache
      AND goes back
      THEN the no data screen is shown
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.clickGoPreviousDateButton();
          await robot.monitoring.goToSettings();
          await robot.settings.clickClearCache();
          await robot.settings.goBack();
          await robot.monitoring.verifyNoDataWidget();
        });
      },
      timeout: Timeout(10.seconds),
    );

    patrolWidgetTest(
      '''
      GIVEN the the data for yesterdays date was cleared
      WHEN clicks try again
      THEN the data for yesterdays date is shown again
      ''',
      ($) async {
        await $.tester.runAsync(() async {
          final robot = await loadApp($);
          await robot.monitoring.clickGoPreviousDateButton();
          await robot.monitoring.goToSettings();
          await robot.settings.clickClearCache();
          await robot.settings.goBack();
          await robot.monitoring.verifyNoDataWidgetAndTryRefresh();
          await robot.monitoring
              .verifyDateAndChart(clock.now().subtract(1.days));
        });
      },
      timeout: Timeout(10.seconds),
    );
  });
}
