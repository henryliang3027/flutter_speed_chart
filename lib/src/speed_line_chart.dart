import 'package:flutter/material.dart';

import 'line_series.dart';
import 'line_chart_painter.dart';

class LineSeriesX {
  const LineSeriesX({
    required this.lineSeries,
    required this.dataMap,
    required this.startIndexes,
  });

  final LineSeries lineSeries;
  final Map<DateTime, double?> dataMap;
  final List<int> startIndexes;
}

class SpeedLineChart extends StatefulWidget {
  final List<LineSeries> lineSeriesCollection;

  const SpeedLineChart({
    Key? key,
    required this.lineSeriesCollection,
  }) : super(key: key);

  @override
  SpeedLineChartState createState() => SpeedLineChartState();
}

class SpeedLineChartState extends State<SpeedLineChart> {
  bool _showTooltip = false;

  double _longPressX = 0.0;
  final double _leftOffset = 40;
  final double _rightOffset = 60;

  double _offset = 0.0;
  double _scale = 1.0;
  double _lastScaleValue = 1.0;

  double _minValue = 0.0;
  double _maxValue = 0.0;
  DateTime _minDate = DateTime.now();
  DateTime _maxDate = DateTime.now();
  double _xRange = 0.0;
  double _yRange = 0.0;

  double _focalPointX = 0.0;
  double _lastUpdateFocalPointX = 0.0;
  double _deltaFocalPointX = 0.0;
  late final LineSeriesX _longestLineSeriesX;
  late final List<LineSeriesX> _lineSeriesXCollection;

  List<LineSeriesX> _getLineSeriesXCollection() {
    List<LineSeriesX> lineSeriesXCollection = [];
    for (LineSeries lineSeries in widget.lineSeriesCollection) {
      Map<DateTime, double?> dataMap = {};
      List<int> startIndexes = [];

      for (int i = 0; i < lineSeries.dataList.length; i++) {
        DateTime dateTime = lineSeries.dataList[i].dateTime;
        double? value = lineSeries.dataList[i].value;
        dataMap[dateTime] = value;

        if (i > 0) {
          if (value != null && lineSeries.dataList[i - 1].value == null) {
            startIndexes.add(i);
          }
        }
      }

      lineSeriesXCollection.add(LineSeriesX(
        lineSeries: lineSeries,
        dataMap: dataMap,
        startIndexes: startIndexes,
      ));
    }
    return lineSeriesXCollection;
  }

  @override
  void initState() {
    super.initState();
    _lineSeriesXCollection = _getLineSeriesXCollection();

    List<double?> allValues = _lineSeriesXCollection
        .expand((lineSeries) => lineSeries.dataMap.values)
        .toList();

    allValues.removeWhere((element) => element == null);

    List<double?> allNonNullValues = [];
    allNonNullValues.addAll(allValues);

    List<DateTime> allDateTimes = _lineSeriesXCollection
        .expand((lineSeries) => lineSeries.dataMap.keys)
        .toList();

    _minValue = allNonNullValues
            .map((value) => value)
            .reduce((value, element) => value! < element! ? value : element)! -
        10;
    _maxValue = allNonNullValues
            .map((value) => value)
            .reduce((value, element) => value! > element! ? value : element)! +
        10;

    _minDate = allDateTimes
        .map((dateTime) => dateTime)
        .reduce((value, element) => value.isBefore(element) ? value : element);
    _maxDate = allDateTimes
        .map((dateTime) => dateTime)
        .reduce((value, element) => value.isAfter(element) ? value : element);

    _xRange = _maxDate.difference(_minDate).inSeconds.toDouble();
    _yRange = _maxValue - _minValue;

    _longestLineSeriesX = _lineSeriesXCollection
        .map((lineSeriesX) => lineSeriesX)
        .reduce((value, element) =>
            value.dataMap.length > element.dataMap.length ? value : element);
  }

  @override
  Widget build(BuildContext context) {
    double widgetWidth = MediaQuery.of(context).size.width;
    double widgetHeight = 200;

    double calculateOffsetX(
      double newScale,
      double focusOnScreen,
    ) {
      double ratioInGraph =
          (_offset.abs() + focusOnScreen) / (_scale * widgetWidth);

      double newTotalWidth = newScale * widgetWidth;

      double newLocationInGraph = ratioInGraph * newTotalWidth;

      return focusOnScreen - newLocationInGraph;
    }

    updateScaleAndScrolling(double newScale, double focusX,
        {double extraX = 0.0}) {
      var widgetWidth = context.size!.width;

      newScale = newScale.clamp(1.0, 30.0);

      // 根据缩放焦点计算出left
      double left = calculateOffsetX(newScale, focusX);

      // 加上额外的水平偏移量
      left += extraX;

      // 将x范围限制图表宽度内
      double newOffsetX = left.clamp((newScale - 1) * -widgetWidth, 0.0);

      setState(() {
        _scale = newScale;
        _offset = newOffsetX;
      });
    }

    return GestureDetector(
      onScaleStart: (details) {
        _focalPointX = details.focalPoint.dx;
        _lastScaleValue = _scale;
        _lastUpdateFocalPointX = details.focalPoint.dx;
      },
      onScaleUpdate: (details) {
        double newScale = (_lastScaleValue * details.scale);

        _deltaFocalPointX = (details.focalPoint.dx - _lastUpdateFocalPointX);
        _lastUpdateFocalPointX = details.focalPoint.dx;

        updateScaleAndScrolling(newScale, _focalPointX,
            extraX: _deltaFocalPointX);
      },
      onScaleEnd: (details) {},
      onLongPressMoveUpdate: (details) {
        setState(() {
          _longPressX = details.localPosition.dx - _leftOffset;
        });
      },
      onLongPressEnd: (details) {
        setState(() {
          _showTooltip = false;
        });
      },
      onLongPressStart: (details) {
        setState(() {
          _showTooltip = true;
          _longPressX = details.localPosition.dx - _leftOffset;
        });
      },
      child: CustomPaint(
        size: Size(
          widgetWidth,
          widgetHeight,
        ),
        painter: LineChartPainter(
          lineSeriesXCollection: _lineSeriesXCollection,
          longestLineSeriesX: _longestLineSeriesX,
          showTooltip: _showTooltip,
          longPressX: _longPressX,
          leftOffset: _leftOffset,
          rightOffset: _rightOffset,
          offset: _offset,
          scale: _scale,
          minValue: _minValue,
          maxValue: _maxValue,
          minDate: _minDate,
          maxDate: _maxDate,
          xRange: _xRange,
          yRange: _yRange,
        ),
      ),
    );
  }
}
