import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_chart/speed_chart.dart';

void main() {
  testWidgets('LineChart renders multiple line series correctly',
      (WidgetTester tester) async {
    // Sample data
    List<ValuePair<DateTime>> data1 = [
      ValuePair(x: DateTime.parse("2022-09-16 00:51:38"), y: 300),
      ValuePair(x: DateTime.parse("2022-09-16 00:41:39"), y: 30),
      ValuePair(x: DateTime.parse("2022-09-16 01:01:38"), y: 22),
    ];

    List<ValuePair<DateTime>> data2 = [
      ValuePair(x: DateTime.parse("2022-09-16 00:52:28"), y: 20),
      ValuePair(x: DateTime.parse("2022-09-16 03:41:39"), y: 70),
      ValuePair(x: DateTime.parse("2022-09-16 01:03:38"), y: 62),
    ];

    LineSeries lineSeries1 = LineSeries(
      name: "Line1",
      dataList: data1,
      color: Colors.blue,
    );

    LineSeries lineSeries2 = LineSeries(
      name: "Line2",
      dataList: data2,
      color: Colors.red,
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpeedLineChart(
            lineSeriesCollection: [lineSeries1, lineSeries2],
          ),
        ),
      ),
    );

    // Verify that the LineChart renders both line series
    expect(find.text("Line1"), findsOneWidget);
    expect(find.text("Line2"), findsOneWidget);

    // Additional checks like checking for the rendered lines, points, or other elements
    // can be done here based on how your chart renders.
  });
}
