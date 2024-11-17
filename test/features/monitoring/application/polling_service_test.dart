import 'dart:async';

import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late MockMonitoringRepository mockMonitoringRepository;
  late PollingService pollingService;
  late StreamController<List<MonitoringDataModel>> streamController;

  setUp(() {
    mockMonitoringRepository = MockMonitoringRepository();
    streamController = StreamController<List<MonitoringDataModel>>.broadcast();
    pollingService = PollingService(
      monitoringRepository: mockMonitoringRepository,
      dateStr: '2024-11-17',
    );
  });

  tearDown(() {
    pollingService.onDispose();
    streamController.close();
  });

  test('PollingService starts and stops polling', () async {
    final testData = [
      MonitoringDataModel(
        value: 100,
        timestamp: DateTime.parse('2024-11-17T00:00:00Z'),
      ),
      MonitoringDataModel(
        value: 150,
        timestamp: DateTime.parse('2024-11-17T01:00:00Z'),
      ),
    ];

    when(() => mockMonitoringRepository.loadDate(date: '2024-11-17'))
        .thenAnswer((_) async => testData);

    pollingService.startPolling();

    await expectLater(
      pollingService.stream,
      emitsInOrder([
        testData,
      ]),
    );

    pollingService.onDispose();

    await expectLater(
      pollingService.stream,
      emitsDone,
    );
  });

  test('PollingService handles errors', () async {
    when(() => mockMonitoringRepository.loadDate(date: '2024-11-17'))
        .thenThrow(const AppException.pollingFailed());

    pollingService.startPolling();

    await expectLater(
      pollingService.stream,
      emitsError(isA<AppException>()),
    );

    pollingService.onDispose();
    await expectLater(
      pollingService.stream,
      emitsDone,
    );
  });
}
