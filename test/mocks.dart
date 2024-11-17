import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockMonitoringRepository extends Mock implements MonitoringRepository {}
