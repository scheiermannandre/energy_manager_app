import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'down_sampling_strategy.g.dart';

class DownsamplingContext {
  DownsamplingContext(this._strategy);
  DownsamplingStrategy _strategy;

  // ignore: avoid_setters_without_getters
  set strategy(DownsamplingStrategy strategy) => _strategy = strategy;
  DownSamplingAlgorithm get algorithm => _strategy.algorithm;
  List<MonitoringDataModel> downsample(
    List<MonitoringDataModel> data,
    int threshold,
  ) {
    return _strategy.downsample(data, threshold);
  }
}

// ignore: one_member_abstracts
abstract class DownsamplingStrategy {
  factory DownsamplingStrategy.fromAlgorithm(DownSamplingAlgorithm unit) {
    switch (unit) {
      case DownSamplingAlgorithm.none:
        return NoDownsamplingStrategy();
      case DownSamplingAlgorithm.lttb:
        return LTTBDownsamplingStrategy();
    }
  }

  DownSamplingAlgorithm get algorithm;

  List<MonitoringDataModel> downsample(
    List<MonitoringDataModel> data,
    int threshold,
  );
}

class NoDownsamplingStrategy implements DownsamplingStrategy {
  @override
  DownSamplingAlgorithm get algorithm => DownSamplingAlgorithm.none;

  @override
  List<MonitoringDataModel> downsample(
    List<MonitoringDataModel> data,
    int threshold,
  ) {
    return data;
  }
}

class LTTBDownsamplingStrategy implements DownsamplingStrategy {
  @override
  DownSamplingAlgorithm get algorithm => DownSamplingAlgorithm.lttb;

  @override
  List<MonitoringDataModel> downsample(
    List<MonitoringDataModel> data,
    int threshold,
  ) {
    if (threshold >= data.length || threshold == 0) {
      return data;
    }

    final sampled = <MonitoringDataModel>[];
    final every = (data.length - 2) / (threshold - 2);
    var a = 0;
    var nextA = 0;

    sampled.add(data[a]);

    for (var i = 0; i < threshold - 2; i++) {
      final avgRangeStart = ((i + 1) * every).floor() + 1;
      final avgRangeEnd = ((i + 2) * every).floor() + 1;
      final avgRangeLength = avgRangeEnd - avgRangeStart;

      var avgX = 0.0;
      var avgY = 0.0;
      for (var j = avgRangeStart; j < avgRangeEnd && j < data.length; j++) {
        avgX += data[j].timestamp.millisecondsSinceEpoch.toDouble();
        avgY += data[j].value;
      }
      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      final rangeOffs = ((i + 0) * every).floor() + 1;
      final rangeTo = ((i + 1) * every).floor() + 1;

      final pointAX = data[a].timestamp.millisecondsSinceEpoch.toDouble();
      final pointAY = data[a].value;
      var maxArea = -1.0;
      for (var j = rangeOffs; j < rangeTo && j < data.length; j++) {
        var area = (pointAX - avgX) * (data[j].value - pointAY) -
            (pointAX - data[j].timestamp.millisecondsSinceEpoch.toDouble()) *
                (avgY - pointAY);
        area = area.abs() * 0.5;
        if (area > maxArea) {
          maxArea = area;
          nextA = j;
        }
      }

      sampled.add(data[nextA]);
      a = nextA;
    }

    sampled.add(data[data.length - 1]);

    return sampled;
  }
}

@riverpod
class DownsamplingContextController extends _$DownsamplingContextController {
  @override
  DownsamplingContext build() =>
      DownsamplingContext(LTTBDownsamplingStrategy());
  void switchStrategy(DownsamplingStrategy strategy) =>
      state = DownsamplingContext(strategy);
}
