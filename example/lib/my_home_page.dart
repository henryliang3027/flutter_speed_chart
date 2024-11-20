import 'package:example/data_with_null.dart';
import 'package:example/data_3.dart';
import 'package:example/data_3_3.dart';
import 'package:example/data_3_3_3.dart';
import 'package:example/data_3_3_3_3.dart';
import 'package:example/full_screen_chart.dart';
import 'package:example/rf_data_1.dart';
import 'package:flutter/material.dart';
import 'package:speed_chart/speed_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<LineSeries> _lineSeriesCollectionEmpty = [];
  List<LineSeries> _lineSeriesCollectionWithNull = [];
  // List<LineSeries> _lineSeriesCollection0 = [];
  List<LineSeries> _lineSeriesCollection4 = [];
  List<LineSeries> _lineSeriesCollectionRF = [];

  LineSeries _getChartData({
    required List data,
    required Color color,
    required String name,
    double? maxYAxisValue,
    double? minYAxisValue,
  }) {
    List<ValuePair> dataList = [];
    for (int i = 0; i < data.length; i++) {
      var d = data[i];
      DateTime dateTime = DateTime.parse(d['time'].toString());
      double? value =
          d['value'] == 'null' ? null : double.parse(d['value'].toString());

      dataList.add(ValuePair(x: dateTime, y: value));
    }

    LineSeries lineSeries = LineSeries(
      name: name,
      dataList: dataList,
      color: color,
      maxYAxisValue: maxYAxisValue,
      minYAxisValue: minYAxisValue,
    );

    return lineSeries;
  }

  LineSeries _getGenericTypeChartData({
    required List data,
    required Color color,
    required String name,
    double? maxYAxisValue,
    double? minYAxisValue,
  }) {
    List<ValuePair> dataList = [];
    for (int i = 0; i < data.length; i++) {
      var d = data[i];
      int freq = int.parse(d['freq'].toString());
      double? level =
          d['level'] == 'null' ? null : double.parse(d['level'].toString());

      dataList.add(ValuePair(x: freq, y: level));
    }

    LineSeries lineSeries = LineSeries(
      name: name,
      dataList: dataList,
      color: color,
      maxYAxisValue: maxYAxisValue,
      minYAxisValue: minYAxisValue,
    );

    return lineSeries;
  }

  @override
  void initState() {
    super.initState();

    // _lineSeriesCollectionEmpty = [
    //   _getChartData(
    //     data: [],
    //     color: Colors.red,
    //     name: 'LineEmpty',
    //     maxYAxisValue: 4000,
    //     minYAxisValue: 0,
    //   ),
    // ];

    _lineSeriesCollectionWithNull = [
      _getChartData(
        data: jsonDataWithNull,
        color: Colors.red,
        name: 'Line',
        maxYAxisValue: 60,
        minYAxisValue: 0,
      ),
    ];

    // _lineSeriesCollection0 = [
    //   _getChartData(
    //     data: [
    //       {"time": "2022-09-16 00:51:38", "value": "300"},
    //       {"time": "2022-09-16 00:41:39", "value": "30"},
    //       {"time": "2022-09-16 01:01:38", "value": "22"},
    //       {"time": "2022-09-16 00:52:28", "value": "20"},
    //       {"time": "2022-09-16 03:41:39", "value": "70"},
    //       {"time": "2022-09-16 01:03:38", "value": "62"},
    //       {"time": "2022-09-16 02:51:38", "value": "-100"},
    //       {"time": "2022-09-16 04:43:39", "value": "40"},
    //       {"time": "2022-09-16 07:07:38", "value": "-30"},
    //     ],
    //     color: Colors.red,
    //     name: 'Line0',
    //     maxYAxisValue: 300,
    //     minYAxisValue: -30,
    //   ),
    //   _getChartData(
    //     data: [
    //       {"time": "2022-09-16 00:51:38", "value": "100"},
    //       {"time": "2022-09-16 00:41:39", "value": "23"},
    //       {"time": "2022-09-16 01:01:38", "value": "45"},
    //       {"time": "2022-09-16 00:52:28", "value": "87"},
    //       {"time": "2022-09-16 03:41:39", "value": "67"},
    //       {"time": "2022-09-16 01:03:38", "value": "78"},
    //       {"time": "2022-09-16 02:51:38", "value": "-99"},
    //       {"time": "2022-09-16 04:43:39", "value": "12"},
    //       {"time": "2022-09-16 07:07:38", "value": "-24"},
    //     ],
    //     color: Colors.orange,
    //     name: 'Line1',
    //   ),
    // ];

    _lineSeriesCollection4 = [
      _getChartData(
        data: jsonData3,
        color: Colors.red,
        name: 'Line1',
      ),
      _getChartData(
        data: jsonData3_3,
        color: Colors.orange,
        name: 'Line2',
      ),
      _getChartData(
        data: jsonData3_3_3,
        color: Colors.green,
        name: 'Line3',
      ),
      _getChartData(
        data: jsonData3_3_3_3,
        color: Colors.blue,
        name: 'Line4',
      ),
    ];

    _lineSeriesCollectionRF = [
      _getGenericTypeChartData(
        data: rfOutputs,
        color: Colors.blue,
        name: 'RFLevel',
      ),
    ];
  }

  Widget fullScreen({required List<LineSeries> lineSeriesCollection}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            FullScreenChartForm.route(
              title: 'Monitoring Chart',
              lineSeriesCollection: lineSeriesCollection,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(0.0),
          visualDensity: const VisualDensity(horizontal: -4.0, vertical: -3.0),
        ),
        child: const Icon(
          Icons.fullscreen_outlined,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _Counter(
              lineSeriesCollection: _lineSeriesCollectionRF,
            ),
            fullScreen(lineSeriesCollection: _lineSeriesCollectionRF),
            SpeedLineChart(
              lineSeriesCollection: _lineSeriesCollectionRF,
              title: _lineSeriesCollectionRF[0].name,
              showLegend: false,
              showScaleThumbs: true,
              legendTextStyle: const TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
              axisTextStyle: const TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
              scaleThumbsColor: Colors.green,
            ),
            const SizedBox(
              height: 30.0,
            ),
            _Counter(
              lineSeriesCollection: _lineSeriesCollection4,
            ),
            fullScreen(lineSeriesCollection: _lineSeriesCollection4),
            SpeedLineChart(
              lineSeriesCollection: _lineSeriesCollection4,
              showLegend: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            _Counter(
              lineSeriesCollection: _lineSeriesCollectionWithNull,
            ),
            fullScreen(lineSeriesCollection: _lineSeriesCollectionWithNull),
            SpeedLineChart(
              lineSeriesCollection: _lineSeriesCollectionWithNull,
              showLegend: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection0,
            // ),
            // fullScreen(lineSeriesCollection: _lineSeriesCollection0),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection0,
            //   title: _lineSeriesCollection0[0].name,
            //   showLegend: true,
            //   showMultipleYAxises: false,
            //   showScaleThumbs: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection1p8G1,
            // ),
            // fullScreen(lineSeriesCollection: _lineSeriesCollection1p8G1),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection1p8G1,
            //   showLegend: true,
            //   showScaleThumbs: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    Key? key,
    required this.lineSeriesCollection,
  }) : super(key: key);

  final List<LineSeries> lineSeriesCollection;

  @override
  Widget build(BuildContext context) {
    int getPointsCount(List<LineSeries> lineSeriesCollection) {
      int count = 0;
      for (LineSeries lineSeries in lineSeriesCollection) {
        count += lineSeries.dataList.length;
      }
      return count;
    }

    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: <TextSpan>[
            const TextSpan(
              text: 'The number of points is: ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: getPointsCount(lineSeriesCollection).toString(),
              style: const TextStyle(color: Colors.red, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
