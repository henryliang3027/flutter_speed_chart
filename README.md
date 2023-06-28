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

Check my demo video : https://youtube.com/shorts/UTT7L59P158.

<p align="center">
 <img src="https://cdn-images-1.medium.com/max/1600/1*yzVR8Yj3C0LKBJ_9mKvi4w.png" width="600" height="400">  
</p>
<p align="center">
 <img src="https://cdn-images-1.medium.com/max/1600/1*-jyZKMlJm81FYnCtYzy6BQ.png" width="600" height="400">  
</p>


## Usage

<h4 align="left">
Prepare data points
</h4>

```dart
LineSeries _getChartData({
    required List data,
    required Color color,
    required String name,
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
    );

    return lineSeries;
}
```

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

## Knowledge

一些需要的數值：
原始資料點(x,y) : (DateTime, Value)
_minDate // 最早的日期時間
_maxDate // 最晚的日期時間
_minValue // 最小值
_maxValue // 最大值
_xRange = _maxDate.difference(_minDate).inSeconds.toDouble();
_yRange = _maxValue - _minValue;


1. Draw Y-axis labels and horizontal grid lines
畫5個刻度: yScalePoints = 5
先算出y軸的每一個單位的長度：
 ```double yStep = size.height / yRange;```

算出刻度之間的間距：
```double yInterval = yRange / yScalePoints;```

用迴圈一個一個畫
```
for (int i = 0; i < yScalePoints; i++) {
    double scaleY = size.height - i * yInterval * yStep;

    // Draw horizontal grid line
    canvas.drawLine(Offset(leftOffset, scaleY),
        Offse(size.width - rightOffset + leftOffset, scaleY), _gridPaint);

    // Draw Y-axis scale points
    String label = (i * yInterval + minValue).toStringAsFixed(1);
    _axisLabelPainter.text = TextSpan(
    text: label,
    style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
    ),
    );
    _axisLabelPainter.layout();
    _axisLabelPainter.paint(
        canvas,
        Offset(leftOffset - _axisLabelPainter.width - 4,
            scaleY - _axisLabelPainter.height));
}
```
<p align="center">
 <img src="https://miro.medium.com/v2/resize:fit:1400/format:webp/1*BLpS_2KGnl5FGwczeCBD_A.png" width="600" height="400">  
</p>


## Additional information

For more implement detail, refer to my Medium articles:

[Create your professional widget in Flutter — Multiple Line Chart (Part.1)](https://medium.com/@henryliang3027/create-your-professional-widget-in-flutter-multiple-line-chart-part-1-7ad201c76899)

[Create your professional widget in Flutter — Multiple Line Chart (Part.2)](https://medium.com/@henryliang3027/create-your-professional-widget-in-flutter-multiple-line-chart-part-2-8590dd683ccf)
