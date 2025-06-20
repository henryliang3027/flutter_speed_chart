import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/value_pair.dart';

/// Represents a single data series in the [SpeedLineChart].
///
/// The [LineSeries] class encapsulates all the necessary information to plot a
/// line on the chart, including its name, color, data points, and optional
/// Y-axis value constraints.
///
/// This class is part of the public API of the `speed_chart` package and can
/// be used by user to define their own data series.
class LineSeries {
  /// Creates a constant instance of [LineSeries].
  ///
  /// All parameters marked as `required` must be provided.
  const LineSeries({
    required this.name,
    required this.dataList,
    required this.color,
    this.maxYAxisValue,
    this.minYAxisValue,
  });

  /// The display name of the series.
  ///
  /// This name is typically used in legends and trackball to identify the series.
  final String name;

  /// The color used to render the series on the chart.
  ///
  /// Determines the visual appearance of the line representing this series.
  final Color color;

  /// A list of [ValuePair] representing the data points of the series.
  ///
  /// Each [ValuePair] contains an X and Y value used to plot the points on
  /// the chart.
  final List<ValuePair> dataList;

  /// The maximum value displayed on the Y-axis for this series.
  ///
  /// If not provided, the chart will automatically determine the maximum
  /// value based on the data points.
  final double? maxYAxisValue;

  /// The minimum value displayed on the Y-axis for this series.
  ///
  /// If not provided, the chart will automatically determine the minimum
  /// value based on the data points.
  final double? minYAxisValue;
}
