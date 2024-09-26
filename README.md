<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

## Features

<h4 align="left">
1. Draw more than one group of line series in a line chart.
</h4>
<h4 align="left">
2. Horizontal scaling (pinch in / pinch out)
</h4>
<h4 align="left">
3. Horizontal panning
</h4>
<h4 align="left">
4. Draw a trackball containing a vertical line and corresponding data point on a long press event.
</h4>

Check my demo video : https://youtu.be/Bh4sUhu9UCM.

<p align="center">
 <img src="https://cdn-images-1.medium.com/max/1600/1*yzVR8Yj3C0LKBJ_9mKvi4w.png" width="600" height="400">  
</p>
<p align="center">
 <img src="https://cdn-images-1.medium.com/max/1600/1*-jyZKMlJm81FYnCtYzy6BQ.png" width="600" height="400">  
</p>

## Supported Platforms

- Android
- iOS
- macOS
- Windows

## Usage

<h4 align="left">
Prepare data points: DateTime format X-Axis
</h4>

```dart
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
```

<h4 align="left">
Prepare data points: number format X-Axis
</h4>

```dart
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
```

<h4 align="left">
Data structure of the LineSeries

</h4>

The ```maxYAxisValue```, ```minYAxisValue``` are optional, If provided, the y-axis range will be displayed based on the given values. If not provided, the y-axis range will automatically adjust based on the data points."

```
class LineSeries {
  const LineSeries({
    required this.name,
    required this.dataList,
    required this.color,
    this.maxYAxisValue,
    this.minYAxisValue,
  });

  final String name;
  final List<ValuePair> dataList;
  final Color color;
  final double? maxYAxisValue;
  final double? minYAxisValue;
}
```

```showLegend``` displays each line series's name and color to identify the corresponding line series in the chart.  
```showMultipleYAxises``` displays multiple Y-axes.  
```showScaleThumbs``` displays a scale thumb on the chart, used for scaling and panning the line series. It is recommended for use on desktop platforms as an alternative to hand gestures.  

<h4 align="left">
Create a single line chart
</h4>


```dart
List<LineSeries> lineSeriesCollection = [
    _getChartData(
        data: [
            {"time": "2022-09-16 00:41:38", "value": "12.0"},
            {"time": "2022-09-16 00:51:39", "value": "23.0"},
            {"time": "2022-09-16 01:01:38", "value": "65.6"},
        ],
        color: Colors.red,
        name: 'Line0',
        ),
    ]

SpeedLineChart(
    lineSeriesCollection: _lineSeriesCollection0,
    title: _lineSeriesCollection0[0].name,
    showLegend: false,
),
```


<h4 align="left">
Create a multiple line chart
</h4>

```dart

List<LineSeries> lineSeriesCollection1 = [
    _getChartData(
        data: [
            {"time": "2022-09-16 00:41:38", "value": "12.0"},
            {"time": "2022-09-16 00:51:39", "value": "23.0"},
            {"time": "2022-09-16 01:01:38", "value": "65.6"},
        ],
        color: Colors.red,
        name: 'Line0',
        ),
    _getChartData(
        data: [
            {"time": "2022-09-16 00:41:38", "value": "12.0"},
            {"time": "2022-09-16 00:51:39", "value": "23.0"},
            {"time": "2022-09-16 01:01:38", "value": "65.6"},
        ],
        color: Colors.orange,
        name: 'Line1',
        ),
    ]

SpeedLineChart(
    lineSeriesCollection: _lineSeriesCollection1,
    title: _lineSeriesCollection0[0].name,
    showLegend: false,
),
```

## Additional information

For more implement detail, refer to my Medium articles:

[Create your professional widget in Flutter — Multiple Line Chart (Part.1)](https://medium.com/@henryliang3027/create-your-professional-widget-in-flutter-multiple-line-chart-part-1-7ad201c76899)

[Create your professional widget in Flutter — Multiple Line Chart (Part.2)](https://medium.com/@henryliang3027/create-your-professional-widget-in-flutter-multiple-line-chart-part-2-8590dd683ccf)
