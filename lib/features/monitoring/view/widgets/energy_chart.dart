import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EnergyChart extends StatelessWidget {
  const EnergyChart({
    required this.data,
    required this.config,
    required this.date,
    super.key,
  });
  final List<MonitoringDataModel> data;
  final String date;
  final EnergyChartConfig config;

  static DownsamplingContext downsamplingContext = DownsamplingContext(
    LTTBDownsamplingStrategy(),
  );
  static const minutes = 60.0;
  @override
  Widget build(BuildContext context) {
    final downsampledData =
        downsamplingContext.downsample(data, config.downsampleThreshold);

    const maxXValue = 24 * minutes;
    var maxYValue = downsampledData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .ceilToDouble();
    final interval = maxYValue /
        config.horizontalGridLineCount; // Calculate interval to have 4 titles
    maxYValue += interval; // Add interval to have padding at the top

    return LineChart(
      key: ValueKey(date),
      LineChartData(
        gridData: const FlGridData(
          drawVerticalLine: false,
          drawHorizontalLine: false, // Disable default horizontal lines
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(''.hardCoded),
          ),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: config.bottomTitleInterval,
              getTitlesWidget: (value, meta) =>
                  bottomTitleWidgets(context, value, meta, config.xAxisStyle),
            ),
          ),
          rightTitles: AxisTitles(
            axisNameWidget: Text('Leistung (W)'.hardCoded),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(bottom: BorderSide(color: config.gridLineColor)),
        ),
        maxX: maxXValue,
        maxY: maxYValue,
        lineBarsData: [
          LineChartBarData(
            spots: downsampledData.map((model) {
              // Convert time to minutes since midnight
              final x = model.timestamp.hour * minutes + model.timestamp.minute;
              final y = model.value;
              return FlSpot(x, y.toDouble());
            }).toList(),
            isCurved: true,
            color: config.lineColor,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: config.barAreaColor),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: getHorizontalLines(interval),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) =>
                getTooltipItems(context, touchedSpots, config.toolTipStyle),
          ),
        ),
      ),
    );
  }

  List<HorizontalLine> getHorizontalLines(
    double interval,
  ) {
    return List.generate(config.horizontalGridLineCount + 1, (index) {
      final skipIndex = index + 1;
      final y = skipIndex * interval;
      return HorizontalLine(
        y: y,
        color: config.gridLineColor,
        strokeWidth: config.horizontalLineStrokeWidth,
        dashArray: config.horizontalLineDashArray,
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.centerRight,
          style: config.yAxisStyle,
          labelResolver: (line) => y.toInt().toString(),
        ),
      );
    });
  }

  List<LineTooltipItem?> getTooltipItems(
    BuildContext context,
    List<LineBarSpot> touchedSpots,
    TextStyle style,
  ) {
    return touchedSpots.map((spot) {
      final flSpot = spot;
      final timeOfDay = _getTimeOfDay(flSpot.x);
      final formattedTime = timeOfDay.format(context);
      return LineTooltipItem(
        '$formattedTime\n${flSpot.y} W'.hardCoded,
        style,
      );
    }).toList();
  }

  Widget bottomTitleWidgets(
    BuildContext context,
    double value,
    TitleMeta meta,
    TextStyle style,
  ) {
    var text = '';
    if (value % 240 == 0) {
      final time = _getTimeOfDay(value);
      text = time.format(context);
      if (value == 1440) {
        text = const TimeOfDay(hour: 23, minute: 59).format(context);
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  TimeOfDay _getTimeOfDay(double value) {
    return TimeOfDay(
      hour: (value / minutes).floor(),
      minute: (value % minutes).toInt(),
    );
  }
}

class EnergyChartConfig {
  EnergyChartConfig({
    this.downsampleThreshold = 24,
    this.horizontalGridLineCount = 4,
    this.bottomTitleInterval = 240.0,
    this.horizontalLineDashArray = const [3, 5],
    this.horizontalLineStrokeWidth = 1.0,
    this.lineColor = const Color.fromARGB(255, 237, 233, 34),
    this.gridLineColor = const Color.fromARGB(255, 188, 190, 192),
    this.tooltipTextColor = Colors.white,
    this.titleTextColor = const Color(0xff68737d),
    Color? areaBewlowBarColor,
    TextStyle? xAxisTextStyle,
    TextStyle? yAxisTextStyle,
    TextStyle? tooltipTextStyle,
  })  : barAreaColor = areaBewlowBarColor ?? lineColor.withOpacity(0.3),
        xAxisStyle = xAxisTextStyle ??
            TextStyle(color: titleTextColor, fontSize: titleFontSize),
        yAxisStyle = yAxisTextStyle ??
            TextStyle(
              color: titleTextColor,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
        toolTipStyle = tooltipTextStyle ??
            TextStyle(
              color: tooltipTextColor,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            );
  static const double titleFontSize = 12;
  final int downsampleThreshold;
  final int horizontalGridLineCount;
  final double bottomTitleInterval;
  final List<int> horizontalLineDashArray;
  final double horizontalLineStrokeWidth;

  final Color lineColor;
  final Color barAreaColor;
  final Color gridLineColor;
  final Color tooltipTextColor;
  final Color titleTextColor;
  final TextStyle xAxisStyle;
  final TextStyle yAxisStyle;

  final TextStyle toolTipStyle;

  EnergyChartConfig copyWith({
    int? downsampleThreshold,
    int? horizontalGridLineCount,
    double? bottomTitleInterval,
    double? fontSize,
    List<int>? horizontalLineDashArray,
    double? horizontalLineStrokeWidth,
    Color? lineColor,
    Color? barAreaColor,
    Color? gridLineColor,
    Color? tooltipTextColor,
    Color? titleTextColor,
    TextStyle? xAxisStyle,
    TextStyle? yAxisStyle,
    TextStyle? toolTipStyle,
  }) {
    return EnergyChartConfig(
      downsampleThreshold: downsampleThreshold ?? this.downsampleThreshold,
      horizontalGridLineCount:
          horizontalGridLineCount ?? this.horizontalGridLineCount,
      bottomTitleInterval: bottomTitleInterval ?? this.bottomTitleInterval,
      horizontalLineDashArray:
          horizontalLineDashArray ?? this.horizontalLineDashArray,
      horizontalLineStrokeWidth:
          horizontalLineStrokeWidth ?? this.horizontalLineStrokeWidth,
      lineColor: lineColor ?? this.lineColor,
      areaBewlowBarColor: barAreaColor ?? this.barAreaColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      tooltipTextColor: tooltipTextColor ?? this.tooltipTextColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      xAxisTextStyle: xAxisStyle ?? this.xAxisStyle,
      yAxisTextStyle: yAxisStyle ?? this.yAxisStyle,
      tooltipTextStyle: toolTipStyle ?? this.toolTipStyle,
    );
  }
}
