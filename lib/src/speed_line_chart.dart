import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/constants.dart';
import 'package:flutter_speed_chart/src/legend.dart';
import 'package:flutter_speed_chart/src/line_chart_painter.dart';
import 'package:flutter_speed_chart/src/line_series.dart';
import 'package:flutter_speed_chart/src/value_pair.dart';

class LineSeriesX {
  const LineSeriesX({
    required this.name,
    required this.color,
    required this.dataList,
    required this.dataMap,
    required this.startIndexes,
    this.maxYAxisValue,
    this.minYAxisValue,
  });

  final String name;
  final Color color;
  final List<ValuePair> dataList;
  final Map<dynamic, double?> dataMap;
  final List<int> startIndexes;
  final double? maxYAxisValue;
  final double? minYAxisValue;
}

class SpeedLineChart extends StatefulWidget {
  final List<LineSeries> lineSeriesCollection;
  final String title;
  final bool showLegend;
  final bool showMultipleYAxises;
  final bool showScaleThumbs;

  const SpeedLineChart({
    Key? key,
    required this.lineSeriesCollection,
    this.title = '',
    this.showLegend = true,
    this.showMultipleYAxises = false,
    this.showScaleThumbs = false,
  }) : super(key: key);

  @override
  _SpeedLineChartState createState() => _SpeedLineChartState();
}

class _SpeedLineChartState extends State<SpeedLineChart> {
  bool _showTrackball = false;

  double _longPressX = 0.0;
  double _leftOffset = 0;
  final double _rightOffset = 8;

  double _offset = 0.0;
  double _scale = 1.0;
  double _lastScaleValue = 1.0;

  double _minValue = 0.0;
  double _maxValue = 0.0;
  double _xRange = 0.0;
  double _yRange = 0.0;

  // multiple Y-axis
  final List<double> _yRanges = [];
  final List<double> _minValues = [];
  final List<double> _maxValues = [];

  double _focalPointX = 0.0;
  double _lastUpdateFocalPointX = 0.0;
  double _deltaFocalPointX = 0.0;
  late final LineSeriesX _longestLineSeriesX;
  late final List<LineSeriesX> _lineSeriesXCollection;

  // ==== 缩放滑钮
  double _leftSlidingBtnLeft = 0.0;
  double _lastLeftSlidingBtnLeft = 0.0;
  double _rightSlidingBtnRight = 0.0;
  double _lastRightSlidingBtnRight = 0.0;
  double _lastSlidingBarPosition = 0.0;

  Timer? _onPressTimer;

  Size? _currentSize;
  Size? _previousSize;

  List<LineSeriesX> _getLineSeriesXCollection() {
    List<LineSeriesX> lineSeriesXCollection = [];

    for (LineSeries lineSeries in widget.lineSeriesCollection) {
      Map<dynamic, double?> dataMap = {};
      List<int> startIndexes = [];

      for (int i = 0; i < lineSeries.dataList.length; i++) {
        dynamic x = lineSeries.dataList[i].x;
        double? y = lineSeries.dataList[i].y;
        dataMap[x] = y;

        if (i > 0) {
          if (y != null && lineSeries.dataList[i - 1].y == null) {
            startIndexes.add(i);
          }
        }
      }

      lineSeriesXCollection.add(LineSeriesX(
        name: lineSeries.name,
        color: lineSeries.color,
        dataList: lineSeries.dataList, // reference
        dataMap: dataMap,
        startIndexes: startIndexes,
        minYAxisValue: lineSeries.minYAxisValue,
        maxYAxisValue: lineSeries.maxYAxisValue,
      ));
    }
    return lineSeriesXCollection;
  }

  double getMaximumYAxisValue(
      {required double tempMaxValue, required double tempMinValue}) {
    double maximumYAxisValue = 0.0;

    // in case of negative value
    // -2 is to remove decimal point and any following digit
    int factor = tempMaxValue.toString().replaceFirst('-', '').length - 2;

    if ((tempMaxValue - tempMinValue).abs() >= 1000) {
      maximumYAxisValue = tempMaxValue + 100 * (factor + 10);
    } else if ((tempMaxValue - tempMinValue).abs() >= 100) {
      maximumYAxisValue = tempMaxValue + 100 * (factor + 2);
    } else if ((tempMaxValue - tempMinValue).abs() >= 10) {
      maximumYAxisValue = tempMaxValue + 10 * factor;
    } else {
      maximumYAxisValue = tempMaxValue + (factor + 1);
    }

    return maximumYAxisValue;
  }

  double getMinimumYAxisValue(
      {required double tempMaxValue, required double tempMinValue}) {
    double minimumYAxisValue = 0.0;

    // in case of negative values
    // -2 is to remove decimal point and any following digit
    int factor = tempMinValue.toString().replaceFirst('-', '').length - 2;

    if ((tempMaxValue - tempMinValue).abs() >= 1000) {
      minimumYAxisValue = tempMinValue - 100 * (factor + 10);
    } else if ((tempMaxValue - tempMinValue).abs() >= 100) {
      minimumYAxisValue = tempMinValue - 100 * (factor + 2);
    } else if ((tempMaxValue - tempMinValue).abs() >= 10) {
      minimumYAxisValue = tempMinValue - 10 * factor;
    } else {
      minimumYAxisValue = tempMinValue - (factor + 1);
    }

    return minimumYAxisValue;
  }

  void setMinValueAndMaxValue() {
    List<double?> allValues = _lineSeriesXCollection
        .expand((lineSeries) => lineSeries.dataMap.values)
        .toList();

    List<double> allMaxYAxisValues = [];
    List<double> allMinYAxisValues = [];

    for (LineSeriesX lineSeriesX in _lineSeriesXCollection) {
      if (lineSeriesX.maxYAxisValue != null) {
        allMaxYAxisValues.add(lineSeriesX.maxYAxisValue!);
      }
      if (lineSeriesX.minYAxisValue != null) {
        allMinYAxisValues.add(lineSeriesX.minYAxisValue!);
      }
    }

    allValues.removeWhere((element) => element == null);

    List<double?> allNonNullValues = [];
    allNonNullValues.addAll(allValues);

    if (allNonNullValues.isNotEmpty) {
      double tempMinValue = 0.0;
      double tempMaxValue = 0.0;

      tempMinValue = allNonNullValues
          .map((value) => value)
          .reduce((value, element) => value! < element! ? value : element)!;

      tempMaxValue = allNonNullValues
          .map((value) => value)
          .reduce((value, element) => value! > element! ? value : element)!;

      // 如果 lineseries 中有設定 MinYAxisValues
      if (allMinYAxisValues.isNotEmpty) {
        _minValue = allMinYAxisValues
            .map((value) => value)
            .reduce((value, element) => value < element ? value : element);
      } else {
        _minValue = getMinimumYAxisValue(
          tempMaxValue: tempMaxValue,
          tempMinValue: tempMinValue,
        );
      }

      // 如果 lineseries 中有設定 MaxYAxisValues
      if (allMaxYAxisValues.isNotEmpty) {
        _maxValue = allMaxYAxisValues
            .map((value) => value)
            .reduce((value, element) => value > element ? value : element);
      } else {
        _maxValue = getMaximumYAxisValue(
          tempMaxValue: tempMaxValue,
          tempMinValue: tempMinValue,
        );
      }
    } else {
      // 如果沒有資料點, 就看有沒有給 MaxYAxisValues 或 MinYAxisValues
      if (allMinYAxisValues.isNotEmpty) {
        _minValue = allMinYAxisValues
            .map((value) => value)
            .reduce((value, element) => value < element ? value : element);
      } else {
        _minValue = 0.0;
      }

      if (allMaxYAxisValues.isNotEmpty) {
        _maxValue = allMaxYAxisValues
            .map((value) => value)
            .reduce((value, element) => value > element ? value : element);
      } else {
        _maxValue = 10.0;
      }
    }
  }

  void setMinValueAndMaxValueForMultipleYAxis() {
    List allValues = _lineSeriesXCollection
        .expand((lineSeries) => lineSeries.dataMap.values)
        .toList();

    allValues.removeWhere((element) => element == null);

    List allNonNullValues = [];
    allNonNullValues.addAll(allValues);

    // 如果有資料點
    if (allNonNullValues.isNotEmpty) {
      for (LineSeriesX lineSeries in _lineSeriesXCollection) {
        List values = lineSeries.dataMap.values.toList();

        values.removeWhere((element) => element == null);

        List nonNullValues = [];
        nonNullValues.addAll(values);

        double tempMinValue = 0.0;
        double tempMaxValue = 0.0;

        if (nonNullValues.isNotEmpty) {
          tempMinValue = nonNullValues
              .map((value) => value)
              .reduce((value, element) => value! < element! ? value : element)!;

          tempMaxValue = nonNullValues
              .map((value) => value)
              .reduce((value, element) => value! > element! ? value : element)!;
        }

        // 如果 for loop 跑到的 lineSeries 有給 MinYAxisValue
        if (lineSeries.minYAxisValue != null) {
          _minValues.add(lineSeries.minYAxisValue!);
        } else {
          double minValue = getMinimumYAxisValue(
            tempMaxValue: tempMaxValue,
            tempMinValue: tempMinValue,
          );
          _minValues.add(minValue);
        }

        // 如果 for loop 跑到的 lineSeries 有給 MaxYAxisValue
        if (lineSeries.maxYAxisValue != null) {
          _maxValues.add(lineSeries.maxYAxisValue!);
        } else {
          double maxValue = getMaximumYAxisValue(
            tempMaxValue: tempMaxValue,
            tempMinValue: tempMinValue,
          );
          _maxValues.add(maxValue);
        }
      }
    } else {
      // 如果沒有資料點, 就用 for loop 一個個看有沒有給 MaxYAxisValues 或 MinYAxisValues
      for (LineSeriesX lineSeries in _lineSeriesXCollection) {
        // 如果 for loop 跑到的 lineSeries 有給 MinYAxisValue
        if (lineSeries.minYAxisValue != null) {
          _minValues.add(lineSeries.minYAxisValue!);
        } else {
          _minValues.add(0.0);
        }

        // 如果 for loop 跑到的 lineSeries 有給 MaxYAxisValue
        if (lineSeries.maxYAxisValue != null) {
          _maxValues.add(lineSeries.maxYAxisValue!);
        } else {
          _maxValues.add(10.0);
        }
      }
    }
  }

  void setXRangeAndYRange() {
    _xRange = _longestLineSeriesX.dataList.length * 1.0;
    _yRange = _maxValue - _minValue;
  }

  void setXRangeAndYRangeForMultipleYAxis() {
    _xRange = _longestLineSeriesX.dataList.length * 1.0;

    for (int i = 0; i < _lineSeriesXCollection.length; i++) {
      double yRanges = _maxValues[i] - _minValues[i];
      _yRanges.add(yRanges);
    }
  }

  @override
  void initState() {
    super.initState();
    _lineSeriesXCollection = _getLineSeriesXCollection();

    _longestLineSeriesX = _lineSeriesXCollection
        .map((lineSeriesX) => lineSeriesX)
        .reduce((value, element) =>
            value.dataList.length > element.dataList.length ? value : element);

    if (widget.showMultipleYAxises) {
      setMinValueAndMaxValueForMultipleYAxis();
      setXRangeAndYRangeForMultipleYAxis();
    } else {
      setMinValueAndMaxValue();
      setXRangeAndYRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    double widgetWidth = MediaQuery.of(context).size.width;
    double widgetHeight = 200;

    final Paint axisPaint = Paint()
      ..color = Theme.of(context).colorScheme.onSurface
      ..strokeWidth = 1;

    final Paint verticalLinePaint = Paint()
      ..color = Theme.of(context).colorScheme.onSurface
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double getLineSeriesLeftOffset() {
      return widget.showMultipleYAxises
          ? 40.0 * widget.lineSeriesCollection.length
          : _leftOffset;
    }

    double getMaxScale() {
      double maxScale = 1;
      double lineSeriesLeftOffset = getLineSeriesLeftOffset();

      double xStep =
          (widgetWidth - lineSeriesLeftOffset - _rightOffset - 1) / 3;

      if (_xRange == 0) {
        maxScale = (xStep + lineSeriesLeftOffset + _rightOffset) / widgetWidth;
      } else {
        maxScale = (xStep * _xRange + lineSeriesLeftOffset + _rightOffset) /
            widgetWidth;
      }

      return maxScale;
    }

    double calculateOffsetX(
      double newScale,
      double focusOnScreen,
    ) {
      // original position : original total width = new position x : new total width
      // solve x
      double originalTotalWidth = _scale * widgetWidth;
      double newTotalWidth = newScale * widgetWidth;

      double originalRatioInGraph =
          (_offset.abs() + focusOnScreen) / originalTotalWidth;

      double newLocationInGraph = originalRatioInGraph * newTotalWidth;

      return focusOnScreen - newLocationInGraph;
    }

    updateScaleAndScrolling(double newScale, double focusX,
        {double extraX = 0.0}) {
      double widgetWidth = context.size!.width;

      // 根據縮放焦點算出圖的起始點
      double left = calculateOffsetX(newScale, focusX);
      print('left: $left');

      // 加上額外的水平偏移量
      left += extraX;

      // 將範圍限制在圖表寬度內
      double newOffsetX = left.clamp((newScale - 1) * -widgetWidth, 0.0);

      // 根据缩放,同步缩略滑钮的状态
      // 同步缩略滑钮的状态
      double lineSeriesLeftOffset = getLineSeriesLeftOffset();
      double maxViewportWidth = widgetWidth -
          slidingButtonWidth * 2 -
          lineSeriesLeftOffset -
          _rightOffset;
      double lOffsetX = -newOffsetX / _scale;
      double rOffsetX = ((_scale - 1) * widgetWidth + newOffsetX) / _scale;

      double r = maxViewportWidth / widgetWidth;
      lOffsetX *= r;
      rOffsetX *= r;

      // 避免在某些scale情形下出現負數
      lOffsetX = lOffsetX < 0 ? 0 : lOffsetX;
      rOffsetX = rOffsetX < 0 ? 0 : rOffsetX;

      print('_scale: $_scale');

      setState(() {
        _scale = newScale;
        _offset = newOffsetX;
        _leftSlidingBtnLeft = lOffsetX;
        _rightSlidingBtnRight = rOffsetX;
      });
    }

    // 滑鈕中間的空白區域的拖曳操作
    _onSlidingBarHorizontalDragStart(DragStartDetails details) {
      // _lastSlidingBarPosition = details.globalPosition.dx;
    }

    _onSlidingBarHorizontalDragUpdate(DragUpdateDetails details) {
      double widgetWidth = context.size!.width;
      print('widgetWidth: ${widgetWidth}');

      // 得到本次滑动的偏移量, 乘倍数后和之前的偏移量相减等于新的偏移量

      double deltaX = (details.delta.dx) * 1.1;
      // _lastSlidingBarPosition = details.globalPosition.dx;
      double left = _offset - deltaX * _scale;

      // 将x范围限制图表宽度内
      double newOffsetX = left.clamp((_scale - 1) * -widgetWidth, 0.0);

      // 同步缩略滑钮的状态
      double thumbControllerLeftOffset = getLineSeriesLeftOffset();
      double maxViewportWidth = widgetWidth -
          slidingButtonWidth * 2 -
          thumbControllerLeftOffset -
          _rightOffset;
      double lOffsetX = -newOffsetX / _scale;
      double rOffsetX = ((_scale - 1) * widgetWidth + newOffsetX) / _scale;

      print('maxViewportWidth: ${maxViewportWidth}');

      double r = maxViewportWidth / widgetWidth;
      lOffsetX *= r;
      rOffsetX *= r;

      print(
          'maxViewportWidth: ${maxViewportWidth}, widgetWidth: ${widgetWidth}, lOffsetX: ${lOffsetX}, rOffsetX: ${rOffsetX}');

      setState(() {
        _offset = newOffsetX;
        _leftSlidingBtnLeft = lOffsetX;
        _rightSlidingBtnRight = rOffsetX;
      });
    }

    _onWindowResize(BoxConstraints constraints) {
      _currentSize = Size(constraints.maxWidth, constraints.maxHeight);
      double widgetWidth = _currentSize!.width;
      double widthDiff = 0.0;

      if (_previousSize != null) {
        widthDiff = _currentSize!.width / _previousSize!.width;
      }

      double left = _offset * widthDiff;
      print("left: $left, widthDiff: $widthDiff");

      _previousSize = _currentSize;

      // 将x范围限制图表宽度内
      double newOffsetX = left.clamp((_scale - 1) * -widgetWidth, 0.0);

      // 同步缩略滑钮的状态
      double thumbControllerLeftOffset = getLineSeriesLeftOffset();
      double maxViewportWidth = widgetWidth -
          slidingButtonWidth * 2 -
          thumbControllerLeftOffset -
          _rightOffset;
      double lOffsetX = -newOffsetX / _scale;
      double rOffsetX = ((_scale - 1) * widgetWidth + newOffsetX) / _scale;

      double r = maxViewportWidth / widgetWidth;
      lOffsetX *= r;
      rOffsetX *= r;

      // setState(() {
      _offset = newOffsetX;
      _leftSlidingBtnLeft = lOffsetX;
      _rightSlidingBtnRight = rOffsetX;
      // });
    }

    _onSlidingBarHorizontalDragEnd(DragEndDetails details) {}

    // 左邊按鈕的滑動操作
    _onLBHorizontalDragDown(DragStartDetails details) {
      // 按鈕的左側的x (起點) = 觸控的x軸座標 - 前一次按鈕的左側到左邊起點的滑動距離
      _lastLeftSlidingBtnLeft = details.globalPosition.dx - _leftSlidingBtnLeft;

      print('_leftSlidingBtnLeft: ${_leftSlidingBtnLeft}');
    }

    _onLBHorizontalDragUpdate(DragUpdateDetails details) {
      double widgetWidth = context.size!.width;

      double lineSeriesLeftOffseet = getLineSeriesLeftOffset();
      double maxViewportWidth = widgetWidth -
          slidingButtonWidth * 2 -
          lineSeriesLeftOffseet -
          _rightOffset;

      // 按鈕新的offset = 觸控的x軸座標 - 按鈕的左側的x (起點)
      double newLOffsetX = details.globalPosition.dx - _lastLeftSlidingBtnLeft;

      // 根據最大縮放倍數, 限制滑動的最大距離
      // Viewport: 視窗指的是兩個滑桿(不含滑桿本身)中間的內容, 即左滑鈕的右邊到右滑鈕的左邊的距離.
      // 最大視窗寬 / 最大倍數 = 最小的視窗寬
      double minViewportWidth = maxViewportWidth / getMaxScale();

      // 最大視窗寬 - 最小視窗寬 - 目前右邊的偏移量 = 目前左邊的最大偏移量
      double maxLeft =
          maxViewportWidth - minViewportWidth - _rightSlidingBtnRight;
      newLOffsetX = newLOffsetX.clamp(0.0, maxLeft);

      // 得到目前的視窗大小
      double viewportWidth =
          maxViewportWidth - newLOffsetX - _rightSlidingBtnRight;

      print(
          'maxViewportWidth: $maxViewportWidth, viewportWidth: $viewportWidth');

      // 最大視窗大小 / 目前視窗大小 = 應該縮放的倍數
      double newScale = maxViewportWidth / viewportWidth;
      // 計算縮放後的左偏移量
      double newOffsetX = calculateOffsetX(newScale, widgetWidth);

      setState(() {
        _leftSlidingBtnLeft = newLOffsetX;
        _scale = newScale;
        _offset = newOffsetX;
      });
    }

    _onLBHorizontalDragEnd(DragEndDetails details) {}

    // 右邊按鈕的滑動操作
    _onRBHorizontalDragDown(DragStartDetails details) {
      // 按鈕的右側的x (起點) = 觸控的x軸座標 + 前一次按鈕的右側到右邊起點的滑動距離
      _lastRightSlidingBtnRight =
          details.globalPosition.dx + _rightSlidingBtnRight;
      print('details.globalPosition.dx: ${details.globalPosition.dx}');
      print('_rightSlidingBtnRight: ${_rightSlidingBtnRight}');
    }

    _onRBHorizontalDragUpdate(DragUpdateDetails details) {
      double widgetWidth = context.size!.width;

      double lineSeriesLeftOffseet = getLineSeriesLeftOffset();
      double maxViewportWidth = widgetWidth -
          slidingButtonWidth * 2 -
          lineSeriesLeftOffseet -
          _rightOffset;

      // 按鈕新的offset = 按鈕的右側的x (起點) - 觸控的x軸座標
      double newROffsetX =
          _lastRightSlidingBtnRight - details.globalPosition.dx;

      double minViewportWidth = maxViewportWidth / getMaxScale();

      double maxLeft =
          maxViewportWidth - minViewportWidth - _leftSlidingBtnLeft;
      newROffsetX = newROffsetX.clamp(0.0, maxLeft);

      double viewportWidth =
          maxViewportWidth - _leftSlidingBtnLeft - newROffsetX;

      print(
          'maxViewportWidth: $maxViewportWidth, viewportWidth: $viewportWidth');

      // 最大窗口大小 / 当前窗口大小 = 应该缩放的倍数
      double newScale = maxViewportWidth / viewportWidth;

      print('newScale: $newScale');
      // 计算缩放后的左偏移量
      double newOffsetX = calculateOffsetX(newScale, 0.0);

      setState(() {
        _rightSlidingBtnRight = newROffsetX;
        _scale = newScale;
        _offset = newOffsetX;
      });
    }

    _onRBHorizontalDragEnd(DragEndDetails details) {}

    Widget _buildThumbController() {
      return Padding(
        padding: EdgeInsets.only(
            left: getLineSeriesLeftOffset(), right: _rightOffset),
        child: SizedBox(
          width: double.infinity,
          height: 48.0,
          child: Stack(
            children: <Widget>[
              // blank space and drag to scrolling the graph
              Center(
                child: Container(
                  width: double.infinity,
                  height: 16,
                  margin: EdgeInsets.only(
                    left: slidingButtonWidth / 2 + _leftSlidingBtnLeft,
                    right: slidingButtonWidth / 2 + _rightSlidingBtnRight,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: GestureDetector(
                    onHorizontalDragStart: _onSlidingBarHorizontalDragStart,
                    onHorizontalDragUpdate: _onSlidingBarHorizontalDragUpdate,
                    onHorizontalDragEnd: _onSlidingBarHorizontalDragEnd,
                  ),
                ),
              ),

              // left sliding button
              Container(
                width: slidingButtonWidth + _leftSlidingBtnLeft,
                height: double.infinity,
                padding: EdgeInsets.only(left: _leftSlidingBtnLeft),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: GestureDetector(
                  onHorizontalDragStart: _onLBHorizontalDragDown,
                  onHorizontalDragUpdate: _onLBHorizontalDragUpdate,
                  onHorizontalDragEnd: _onLBHorizontalDragEnd,
                  child: Container(
                    height: double.infinity,
                    width: slidingButtonWidth,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)
                        // borderRadius: BorderRadius.only(
                        //     topRight: Radius.circular(40.0),
                        //     bottomRight: Radius.circular(40.0),
                        //     topLeft: Radius.circular(40.0),
                        //     bottomLeft: Radius.circular(40.0)),
                        ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // right sliding button
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: slidingButtonWidth + _rightSlidingBtnRight,
                  padding: EdgeInsets.only(right: _rightSlidingBtnRight),
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onHorizontalDragStart: _onRBHorizontalDragDown,
                    onHorizontalDragUpdate: _onRBHorizontalDragUpdate,
                    onHorizontalDragEnd: _onRBHorizontalDragEnd,
                    child: Container(
                      height: double.infinity,
                      width: slidingButtonWidth,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white)),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!widget.showMultipleYAxises) {
      String maxValueStr = _maxValue.toStringAsFixed(0);
      String minValueStr = _minValue.toStringAsFixed(0);

      // ex: 300 >= -30, 參考 300 的字串長度來決定 _leftOffset
      String maxLengthStr =
          maxValueStr.length >= minValueStr.length ? maxValueStr : minValueStr;

      final TextPainter _textWidthPainter = TextPainter(
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.ltr,
      );

      _textWidthPainter.text = TextSpan(
        text: maxLengthStr,
        style: TextStyle(
          fontSize: 12,
          color: axisPaint.color,
        ),
      );

      // Draw label
      _textWidthPainter.layout();

      _leftOffset = _textWidthPainter.width + 10;
    } else {
      _leftOffset = 40;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _onWindowResize(constraints);

        return Column(
          children: [
            widget.title.isNotEmpty
                ? Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : Container(),
            widget.showScaleThumbs ? _buildThumbController() : Container(),
            SizedBox(
              height: widget.showScaleThumbs ? 16 : 0,
            ),
            GestureDetector(
              onScaleStart: (details) {
                print('Scale start');

                // 當兩隻手指點擊縮放時取消 trackball
                if (details.pointerCount == 2) {
                  setState(() {
                    if (_onPressTimer != null) {
                      print('cancel timer');
                      _onPressTimer!.cancel();
                      _onPressTimer = null;
                    }

                    _showTrackball = false;

                    _deltaFocalPointX = 0;
                  });
                }

                // 紀錄按下去的點
                _focalPointX = details.focalPoint.dx;

                // 紀錄目前的scale
                _lastScaleValue = _scale;

                // 紀錄按下去的點, 用在計算縮放時焦點的偏移量
                _lastUpdateFocalPointX = details.focalPoint.dx;
              },
              onScaleUpdate: (details) {
                // newScale >= 1.0, 否則計算 left.clamp((newScale - 1) * -widgetWidth, 0.0) 時範圍會錯誤
                print(
                    'Scale update ${details.focalPoint.dx}, ${_lastUpdateFocalPointX}');

                if (_showTrackball) {
                  setState(() {
                    _longPressX = details.focalPoint.dx - _leftOffset;
                  });
                } else {
                  double newScale = (_lastScaleValue * details.scale) >= 1.0
                      ? (_lastScaleValue * details.scale)
                      : 1.0;
                  double xStep = 0.0;

                  _deltaFocalPointX =
                      (details.focalPoint.dx - _lastUpdateFocalPointX);
                  _lastUpdateFocalPointX = details.focalPoint.dx;

                  // 跟 line series 的 left offset 一樣, 所以兩者是對齊的
                  double lineSeriesLeftOffseet = getLineSeriesLeftOffset();

                  if (_xRange == 0) {
                    xStep = (widgetWidth * newScale -
                            lineSeriesLeftOffseet -
                            _rightOffset) /
                        1;
                  } else {
                    xStep = (widgetWidth * newScale -
                            lineSeriesLeftOffseet -
                            _rightOffset) /
                        (_xRange - 1);
                  }

                  print('xStep: ${xStep}, newScale: ${newScale}');
                  // 最大 scale 為畫面上至少要有一個點
                  // xStep 要小於整個 chart 的寬度
                  if (xStep <
                      widgetWidth - lineSeriesLeftOffseet - _rightOffset) {
                    updateScaleAndScrolling(newScale, _focalPointX,
                        extraX: _deltaFocalPointX);
                  }
                }
              },
              onScaleEnd: (details) {
                print('Scale end');
                setState(() {
                  if (_onPressTimer != null) {
                    print('cancel timer');
                    _onPressTimer!.cancel();
                    _onPressTimer = null;
                  }

                  _showTrackball = false;

                  _deltaFocalPointX = 0;
                });
              },
              onTapDown: (details) {
                print('onTapDown');
                _onPressTimer ??= Timer(Duration(milliseconds: 200), () {
                  // 時間到的時候判斷按下是否有移動, 如果沒有則顯示 trackball
                  print('timer ${_deltaFocalPointX}');
                  if (_deltaFocalPointX == 0) {
                    setState(() {
                      _showTrackball = true;
                      _longPressX = details.localPosition.dx - _leftOffset;
                    });
                  }
                });
              },
              onTapUp: (details) {
                // 只有按下和不按,沒有任何移動時會觸發
                // 不按時 _showTrackball = false
                print('onTapUp');
                setState(() {
                  if (_onPressTimer != null) {
                    print('cancel timer');
                    _onPressTimer!.cancel();
                    _onPressTimer = null;
                  }

                  _showTrackball = false;

                  _deltaFocalPointX = 0;
                });
              },
              onVerticalDragUpdate: (details) {
                // 按下時往垂直方向移動(或不是水平移動)就會觸發這裡的update 事件而不會觸發 onScaleUpdate, 所以在這裡也更新長按的點
                print('onVerticalDragUpdate ${details.localPosition.dx}');

                if (_showTrackball) {
                  setState(() {
                    _longPressX = details.localPosition.dx - _leftOffset;
                  });
                }
              },
              onVerticalDragEnd: (details) {
                print('onVerticalDragEnd');
                setState(() {
                  if (_onPressTimer != null) {
                    print('cancel timer');
                    _onPressTimer!.cancel();
                    _onPressTimer = null;
                  }

                  _showTrackball = false;

                  _deltaFocalPointX = 0;
                });
              },
              onVerticalDragCancel: () {
                // 按下時直接往水平方向移動會觸發
                // 也會觸發onScaleUpdate
                print('onVerticalDragCancel');
              },
              child: CustomPaint(
                size: Size(
                  widgetWidth,
                  widgetHeight,
                ),
                painter: LineChartPainter(
                  lineSeriesXCollection: _lineSeriesXCollection,
                  longestLineSeriesX: _longestLineSeriesX,
                  showTrackball: _showTrackball,
                  longPressX: _longPressX,
                  leftOffset: _leftOffset,
                  rightOffset: _rightOffset,
                  offset: _offset,
                  scale: _scale,
                  minValue: _minValue,
                  maxValue: _maxValue,
                  xRange: _xRange,
                  yRange: _yRange,
                  showMultipleYAxises: widget.showMultipleYAxises,
                  minValues: _minValues,
                  maxValues: _maxValues,
                  yRanges: _yRanges,
                  axisPaint: axisPaint,
                  verticalLinePaint: verticalLinePaint,
                ),
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            widget.showLegend
                ? Legend(
                    lineSeriesXCollection: _lineSeriesXCollection,
                  )
                : Container(),
          ],
        );
      },
    );
  }
}
