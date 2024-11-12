import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:flutter/material.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(title),
      ),
      body: const Center(
        child: EnergyChart(),
      ),
    );
  }
}
