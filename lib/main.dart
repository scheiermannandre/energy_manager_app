import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ToDo extract sizes into constants
void main() {
  runApp(
    const ProviderScope(
      child: MonitoringScreen(),
    ),
  );
}
