import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownsamplingStrategy', () {
    late List<MonitoringDataModel> data;

    setUp(() {
      data = List.generate(
        100,
        (index) => MonitoringDataModel(
          value: index.toDouble(),
          timestamp: DateTime(2024, 11, 17).add(index.minutes),
        ),
      );
    });

    test('NoDownsamplingStrategy returns the same data', () {
      final strategy = NoDownsamplingStrategy();
      final downsampledData = strategy.downsample(data, 50);

      expect(downsampledData, equals(data));
    });

    test('LTTBDownsamplingStrategy reduces the data size', () {
      final strategy = LTTBDownsamplingStrategy();
      final downsampledData = strategy.downsample(data, 50);

      expect(downsampledData.length, lessThanOrEqualTo(50));
    });

    test('DownsamplingContext uses the correct strategy', () {
      final context = DownsamplingContext(NoDownsamplingStrategy());
      expect(context.algorithm, equals(DownSamplingAlgorithm.none));

      context.strategy = LTTBDownsamplingStrategy();
      expect(context.algorithm, equals(DownSamplingAlgorithm.lttb));
    });

    test('DownsamplingContext downsample method works correctly', () {
      final context = DownsamplingContext(LTTBDownsamplingStrategy());
      final downsampledData = context.downsample(data, 50);

      expect(downsampledData.length, lessThanOrEqualTo(50));
    });
  });
}
