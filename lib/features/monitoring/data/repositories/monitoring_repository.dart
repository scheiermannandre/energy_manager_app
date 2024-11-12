import 'dart:convert';

import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monitoring_repository.g.dart';

class MonitoringRepository {
  MonitoringRepository({required this.metricType});

  final MetricType metricType;

  Future<List<MonitoringDataModel>> loadDate({required DateTime date}) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse(
        'http://localhost:3000/monitoring?date=$dateStr&type=${metricType.name}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => MonitoringDataModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      return <MonitoringDataModel>[];
    }
  }
}

@riverpod
MonitoringRepository monitoringRepository(Ref ref, MetricType metricType) {
  return MonitoringRepository(metricType: metricType);
}
