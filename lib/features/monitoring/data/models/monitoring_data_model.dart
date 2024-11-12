import 'dart:convert';

class MonitoringDataModel {
  MonitoringDataModel({required this.timestamp, required this.value});

  factory MonitoringDataModel.fromJson(String source) =>
      MonitoringDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory MonitoringDataModel.fromMap(Map<String, dynamic> map) {
    return MonitoringDataModel(
      timestamp: DateTime.parse(map['timestamp'] as String),
      value: map['value'] as num,
    );
  }

  final DateTime timestamp;
  final num value;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'value': value,
    };
  }

  String toJson() => json.encode(toMap());
}
