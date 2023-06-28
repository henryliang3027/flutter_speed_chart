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
```_minDate //最早的日期時間```   
```_maxDate //最晚的日期時間```  
```_minValue //最小值```  
```_maxValue //最大值```  
```_xRange = _maxDate.difference(_minDate).inSeconds.toDouble();```  
```_yRange = _maxValue - _minValue;```  


1. Draw Y-axis labels and horizontal grid lines  
固定畫5個刻度在y軸上: ```yScalePoints = 5```  
算出y軸的每一個單位的長度： ```double yStep = size.height / yRange;```  
算出資料點的取直間隔： ```double yInterval = yRange / yScalePoints;```  

用迴圈一個一個畫：  
```dart
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

/* example
Suppose the canvas’s size.width = 300, size.height = 200 , yRange = 50 , minValue = 10 , maxValue = 60 leftOffset = 10 ,rightOffset = 30
The 5 horizontal grid lines and labels will be:
grid line #0 (10, 200) to (280, 200), label #0 = 10
grid line #1 (10, 160) to (280, 160), label #1 = 20
grid line #2 (10, 120) to (280, 120), label #2 = 30
grid line #3 (10, 80) to (280, 80), label #3 = 40
grid line #4 (10, 40) to (280, 40), label #4 = 50
*/
```
<p align="center">
 <img src="https://miro.medium.com/v2/resize:fit:1400/format:webp/1*BLpS_2KGnl5FGwczeCBD_A.png" width="600" height="400">  
</p>
<br>
<br>
2. Draw a Y-axis  
<br>
<br>
3. Draw a X-axis  
<br>
<br>
4. Draw X-axis labels and vertical grid lines  

使用clipRect框出折線圖中呈現線段的範圍, 這樣子在縮放或平移時, 超出邊界的範圍就會遮住, 不會看起來是畫到邊界外, 但實際上還是有畫只是被遮住  
canvas.translate的目的在於定義原點(0,0)位置, 把(leftOffset + offset, 0)的位置定義為(0,0)。  
```
canvas.clipRect(Rect.fromPoints(Offset(leftOffset, 0),
    Offset(size.width + leftOffset - rightOffset + 1, size.height + 40)));
canvas.translate(leftOffset + offset, 0);
```


算出x軸的每一個單位的長度： ```double xStep = (size.width * scale - rightOffset) / xRange;```  
決定要畫幾個刻度在x軸上： ```int xScalePoints = size.width * scale ~/ 80;```  
算出資料點的取直間隔： ```double xInterval = (longestLineSeriesX.dataList.length - 1) / xScalePoints;```  
使用迴圈畫出所有刻度：  
```dart
for (int i = 0; i < xScalePoints; i++) {
  double scaleX = (longestLineSeriesX
          .dataList[(i * xInterval).round()].dateTime
          .difference(minDate)
          .inSeconds
          .toDouble() *
      xStep);

  // Draw vertical grid line
  canvas.drawLine(
      Offset(scaleX, 0), Offset(scaleX, size.height), _gridPaint);

  // Draw X-Axis scale points
  DateTime dateTime =
      longestLineSeriesX.dataList[(i * xInterval).round()].dateTime;
  String date = DateFormat('yy-MM-dd').format(dateTime);

  String time = DateFormat('HH:mm:ss').format(dateTime);

  _axisLabelPainter.text = TextSpan(
    text: '$date\n$time',
    style: const TextStyle(
      fontSize: 12,
      color: Colors.black,
    ),
  );
  _axisLabelPainter.layout();
  _axisLabelPainter.paint(canvas, Offset(scaleX, size.height));
}

/* example
Suppose the canvas’s size.width = 390, size.height = 200, xRange = 200, yRange = 50, leftOffset = 10 ,rightOffset = 30
xStep = 400 * 1 / 200 = 2  
xScalePoints = 390 * 1 ~/ 80 = 4
xInterval = (200 - 1) / 4 = 49.75  
The 5 vertical grid lines and date time labels will be:
grid line #0 (scaleX0, 0) to (scaleX0, 200), label #0 = dataList[0].dateTime
grid line #1 (scaleX1, 0) to (scaleX1, 200), label #1 = dataList[50].dateTime
grid line #2 (scaleX2, 0) to (scaleX2, 200), label #2 = dataList[100].dateTime
grid line #3 (scaleX3, 0) to (scaleX3, 200), label #3 = dataList[149].dateTime
*/
```
<p align="center">
 <img src="https://miro.medium.com/v2/resize:fit:4800/format:webp/1*fcdK1MqyvNTabrWjSaGpBA.png" width="600" height="400">  
</p>
<br>
<br>

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
