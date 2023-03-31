import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/speed_line_chart.dart';

class Legend extends StatelessWidget {
  const Legend({Key? key, required this.lineSeriesXCollection})
      : super(key: key);

  final List<LineSeriesX> lineSeriesXCollection;

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
