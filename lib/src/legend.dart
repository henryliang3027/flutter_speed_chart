import 'package:flutter/material.dart';
import 'package:speed_chart/src/speed_line_chart.dart';

class Legend extends StatelessWidget {
  const Legend({
    Key? key,
    required this.lineSeriesXCollection,

    /// custom legend textStyle
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 12,
    ),
  }) : super(key: key);

  final List<LineSeriesX> lineSeriesXCollection;

  /// custom legend textStyle
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    Widget buildTile({
      required String name,
      required Color color,
    }) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 10.0,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(
            width: 4.0,
          ),
          Text(
            name,

            /// add custom textStyle
            style: textStyle,
          ),
        ],
      );
    }

    Widget buildLegend() {
      return Wrap(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (LineSeriesX lineSeries in lineSeriesXCollection) ...[
            buildTile(
              name: lineSeries.name,
              color: lineSeries.color,
            )
          ],
        ],
      );
    }

    return buildLegend();
  }
}
