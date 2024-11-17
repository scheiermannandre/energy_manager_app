import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_repository.g.dart';

class MonitoringRepository {
  MonitoringRepository({
    required this.metricType,
    required http.Client client,
  }) : _client = client;

  final MetricType metricType;
  final http.Client _client;

  Future<List<MonitoringDataModel>> loadDate({required String date}) async {
    try {
      final response = await _client.get(
        Uri.parse(
          'http://localhost:3000/monitoring?date=$date&type=${metricType.name}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((e) => MonitoringDataModel.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        // since we are only expecting a 200 status code,
        // any other status code should be treated as an error which we should
        // somehow log, so it can be evaluated later.
        // Sentry might be an optiion.
        throw const AppException.unexpected();
      }
    } on SocketException {
      throw const AppException.network();
    } on TimeoutException {
      throw const AppException.timeout();
    } on http.ClientException {
      throw const AppException.unexpected();
    } on FormatException {
      // this error technically should never happen, as we are in control of the
      // server response, meaning we should always get a valid JSON response
      // fitting the expected format based on version. If there might be
      // version outdates, this should handled on a higher level, by for rxample
      // passing the version to the server and let the server decide if the
      // version is outdated or not.
      throw const AppException.versionOutdated();
    } on Exception {
      throw const AppException.unexpected();
    }
  }
}

@riverpod
MonitoringRepository monitoringRepository(Ref ref, MetricType metricType) {
  final client = ref.watch(httpClientProvider);
  return MonitoringRepository(metricType: metricType, client: client);
}
