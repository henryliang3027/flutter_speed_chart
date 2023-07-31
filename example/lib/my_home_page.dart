import 'package:example/data_1_1.dart';
import 'package:example/data_3.dart';
import 'package:example/data_3_3.dart';
import 'package:example/data_3_3_3.dart';
import 'package:example/data_3_3_3_3.dart';
import 'package:example/data_dsim_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/speed_chart.dart';

import 'data_dsim_2.dart';

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
  List<LineSeries> _lineSeriesCollection0 = [];
  List<LineSeries> _lineSeriesCollection1 = [];
  List<LineSeries> _lineSeriesCollection2 = [];
  List<LineSeries> _lineSeriesCollection3 = [];
  List<LineSeries> _lineSeriesCollection4 = [];
  List<LineSeries> _lineSeriesCollectionDsimAPT = [];
  List<LineSeries> _lineSeriesCollectionDsimVoltage = [];

  LineSeries _getChartData({
    required List data,
    required Color color,
    required String name,
    double? maxYAxisValue,
    double? minYAxisValue,
  }) {
    List<DateValuePair> dataList = [];
    for (int i = 0; i < data.length; i++) {
      var d = data[i];
      DateTime dateTime = DateTime.parse(d['time'].toString());
      double? value =
          d['value'] == 'null' ? null : double.parse(d['value'].toString());

      dataList.add(DateValuePair(dateTime: dateTime, value: value));
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

    _lineSeriesCollection0 = [
      _getChartData(
        data: [
          // {"time": "2022-09-16 00:41:38", "value": "20"},
          // {"time": "2022-09-16 00:51:39", "value": "30"},
          {"time": "2022-09-16 01:01:38", "value": "null"},
        ],
        color: Colors.red,
        name: 'Line0',
        maxYAxisValue: 4000,
        minYAxisValue: 0,
      ),
      _getChartData(
        data: [
          // {"time": "2022-09-16 00:41:38", "value": "null"},
          {"time": "2022-09-16 00:51:39", "value": "56"},
          // {"time": "2022-09-16 01:01:38", "value": "null"},
        ],
        color: Colors.orange,
        name: 'Line1',
      ),
    ];

    _lineSeriesCollection1 = [
      _getChartData(
        data: jsonData1_1,
        color: Colors.red,
        name: 'Line1',
      ),
    ];

    _lineSeriesCollection2 = [
      _getChartData(
        data: jsonData1_1,
        color: Colors.red,
        name: 'Line1',
      ),
      _getChartData(
        data: jsonData3_3,
        color: Colors.orange,
        name: 'Line2',
      ),
    ];

    _lineSeriesCollection3 = [
      _getChartData(
        data: jsonData1_1,
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
    ];

    _lineSeriesCollection4 = [
      _getChartData(
        data: jsonData1_1,
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

    _lineSeriesCollectionDsimAPT = [
      _getChartData(
        data: jsonData_att2,
        color: Colors.red,
        name: 'Attenuator',
      ),
      _getChartData(
        data: jsonData_temp2,
        color: Colors.orange,
        name: 'Temperature',
      ),
      _getChartData(
        data: jsonData_pilot2,
        color: Colors.green,
        name: 'Pilot',
      ),
    ];

    _lineSeriesCollectionDsimVoltage = [
      _getChartData(
        data: jsonData_voltage2,
        color: Colors.red,
        name: 'Attenuator',
      ),
      _getChartData(
        data: jsonData_voltage_ripple2,
        color: Colors.orange,
        name: 'Temperature',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Counter(
              lineSeriesCollection: _lineSeriesCollectionDsimAPT,
            ),
            SpeedLineChart(
              lineSeriesCollection: _lineSeriesCollectionDsimAPT,
              showLegend: true,
              showMultipleYAxises: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollectionDsimVoltage,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollectionDsimVoltage,
            //   showLegend: true,
            //   showMultipleYAxises: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection0,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection0,
            //   title: _lineSeriesCollection0[0].name,
            //   showLegend: false,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection0,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection0,
            //   title: _lineSeriesCollection0[0].name,
            //   showLegend: true,
            //   showMultipleYAxises: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection1,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection1,
            //   showLegend: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection2,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection2,
            //   showLegend: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection3,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection3,
            //   showLegend: true,
            // ),
            // const SizedBox(
            //   height: 30.0,
            // ),
            // _Counter(
            //   lineSeriesCollection: _lineSeriesCollection4,
            // ),
            // SpeedLineChart(
            //   lineSeriesCollection: _lineSeriesCollection4,
            //   showLegend: true,
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
