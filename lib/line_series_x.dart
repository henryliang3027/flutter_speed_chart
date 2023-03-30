import 'package:flutter_speed_chart/line_series.dart';

class LineSeriesX {
  const LineSeriesX({
    required this.lineSeries,
    required this.dataMap,
    required this.startIndexes,
  });

  final LineSeries lineSeries;
  final Map<DateTime, double?> dataMap;
  final List<int> startIndexes;
}
