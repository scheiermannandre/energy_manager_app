import 'dart:async';

import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'polling_service.g.dart';

class PollingService {
  PollingService({
    required MonitoringRepository monitoringRepository,
    required this.dateStr,
  }) : _monitoringRepository = monitoringRepository;
  final MonitoringRepository _monitoringRepository;
  final String dateStr;

  final StreamController<List<MonitoringDataModel>> _controller =
      StreamController<List<MonitoringDataModel>>.broadcast();
  Timer? _timer;
  Stream<List<MonitoringDataModel>> get stream => _controller.stream;

  void startPolling() {
    // polling interval needs to be adjusted based on the use case
    _timer = Timer.periodic(5.seconds, (timer) async {
      try {
        final monitoringData =
            await _monitoringRepository.loadDate(date: dateStr);
        _controller.add(monitoringData);
      } catch (e) {
        // somewhy the client is throwing a ClientException, due to time
        // constraints, I will just throw a generic error here. Until there
        // is time to investigate the issue.
        _controller.addError(const AppException.pollingFailed());
      }
    });
  }

  void _stopPolling() {
    _timer?.cancel();
    _controller.close();
    _timer = null;
  }

  void onDispose() => _stopPolling();
}

@riverpod
PollingService pollingService(Ref ref, MetricType metricType, String dateStr) {
  final service = PollingService(
    monitoringRepository: ref.read(monitoringRepositoryProvider(metricType)),
    dateStr: dateStr,
  )..startPolling();
  ref.onDispose(service.onDispose);
  return service;
}
