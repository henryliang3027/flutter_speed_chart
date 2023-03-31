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

Refer to my video on Youtube demo : https://www.youtube.com/shorts/kRZtj3cN9EQ.

<p align="center">
 <img src="https://cdn-images-1.medium.com/max/1600/1*yzVR8Yj3C0LKBJ_9mKvi4w.png" width="600" height="400">  
</p>
<p align="center">
 <img src="https://cdn-images-1.medium.com/max/1600/1*-jyZKMlJm81FYnCtYzy6BQ.png" width="600" height="400">  
</p>


## Usage

<h4 align="left">
create a single line chart
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
create a multiple line char
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
