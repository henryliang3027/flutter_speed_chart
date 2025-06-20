import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/speed_line_chart.dart';

/// An internal widget used to display the legend for the [SpeedLineChart].
///
/// The [Legend] class constructs a visual representation of each data series
/// within the chart, showing the series' name and corresponding color.
/// This widget is **not** exposed to the end-users of the `speed_chart` package
/// and is intended for internal management of the chart's widget.
class Legend extends StatelessWidget {
  /// Creates a [Legend] widget.
  ///
  /// The [lineSeriesXCollection] parameter is required and must not be null.
  /// It represents the collection of [LineSeriesX] instances that the legend
  /// will display.
  const Legend({Key? key, required this.lineSeriesXCollection})
    : super(key: key);

  /// A collection of [LineSeriesX] instances used to build the legend.
  ///
  /// Each [LineSeriesX] contains the necessary data.
  final List<LineSeriesX> lineSeriesXCollection;

  @override
  Widget build(BuildContext context) {
    Widget buildTile({required String name, required Color color}) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(width: 10.0),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4.0),
          Text(name),
        ],
      );
    }

    Widget buildLegend() {
      return Wrap(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (LineSeriesX lineSeries in lineSeriesXCollection) ...[
            buildTile(name: lineSeries.name, color: lineSeries.color),
          ],
        ],
      );
    }

    return buildLegend();
  }
}
