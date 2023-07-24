import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/date_value_pair.dart';
import 'package:flutter_speed_chart/src/legend.dart';
import 'package:flutter_speed_chart/src/line_chart_painter.dart';
import 'package:flutter_speed_chart/src/line_series.dart';
import 'package:intl/intl.dart';

class LineSeriesX {
  const LineSeriesX({
    required this.name,
    required this.color,
    required this.dataList,
    required this.dataMap,
    required this.startIndexes,
  });

  final String name;
  final Color color;
  final List<DateValuePair> dataList;
  final Map<DateTime, double?> dataMap;
  final List<int> startIndexes;
}

class SpeedLineChart extends StatefulWidget {
  final List<LineSeries> lineSeriesCollection;
  final String title;
  final bool showLegend;
  final bool showMultipleYAxises;

  const SpeedLineChart({
    Key? key,
    required this.lineSeriesCollection,
    this.title = '',
    this.showLegend = true,
    this.showMultipleYAxises = false,
  }) : super(key: key);

  @override
  _SpeedLineChartState createState() => _SpeedLineChartState();
}

class _SpeedLineChartState extends State<SpeedLineChart> {
  bool _showTooltip = false;

  double _longPressX = 0.0;
  final double _leftOffset = 50;
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

  // multiple Y-axis
  final List<double> _yRanges = [];
  final List<double> _minValues = [];
  final List<double> _maxValues = [];

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
        name: lineSeries.name,
        color: lineSeries.color,
        dataList: lineSeries.dataList, // reference
        dataMap: dataMap,
        startIndexes: startIndexes,
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

    if (allValues.isNotEmpty) {
      allValues.removeWhere((element) => element == null);

      List<double?> allNonNullValues = [];
      allNonNullValues.addAll(allValues);

      double tempMinValue = 0.0;
      double tempMaxValue = 0.0;

      if (allNonNullValues.isNotEmpty) {
        tempMinValue = allNonNullValues
            .map((value) => value)
            .reduce((value, element) => value! < element! ? value : element)!;

        tempMaxValue = allNonNullValues
            .map((value) => value)
            .reduce((value, element) => value! > element! ? value : element)!;
      }

      _minValue = getMinimumYAxisValue(
        tempMaxValue: tempMaxValue,
        tempMinValue: tempMinValue,
      );
      _maxValue = getMaximumYAxisValue(
        tempMaxValue: tempMaxValue,
        tempMinValue: tempMinValue,
      );
    } else {
      _minValue = 0.0;
      _maxValue = 10.0;
    }
  }

  void setMinValueAndMaxValueForMultipleYAxis() {
    List<double?> allValues = _lineSeriesXCollection
        .expand((lineSeries) => lineSeries.dataMap.values)
        .toList();

    if (allValues.isNotEmpty) {
      for (LineSeriesX lineSeries in _lineSeriesXCollection) {
        List<double?> allValues = lineSeries.dataMap.values.toList();

        allValues.removeWhere((element) => element == null);

        double tempMinValue = 0.0;
        double tempMaxValue = 0.0;

        tempMinValue = allValues
            .map((value) => value)
            .reduce((value, element) => value! < element! ? value : element)!;

        tempMaxValue = allValues
            .map((value) => value)
            .reduce((value, element) => value! > element! ? value : element)!;

        double minValue = getMinimumYAxisValue(
          tempMaxValue: tempMaxValue,
          tempMinValue: tempMinValue,
        );
        double maxValue = getMaximumYAxisValue(
          tempMaxValue: tempMaxValue,
          tempMinValue: tempMinValue,
        );

        _minValues.add(minValue);
        _maxValues.add(maxValue);
      }
    } else {
      for (LineSeriesX lineSeries in _lineSeriesXCollection) {
        _minValues.add(0.0);
        _maxValues.add(10.0);
      }
    }
  }

  void setMinDateAndMaxDate() {
    List<DateTime> allDateTimes = _lineSeriesXCollection
        .expand((lineSeries) => lineSeries.dataMap.keys)
        .toList();

    if (allDateTimes.isNotEmpty) {
      _minDate = allDateTimes.map((dateTime) => dateTime).reduce(
          (value, element) => value.isBefore(element) ? value : element);
      _maxDate = allDateTimes
          .map((dateTime) => dateTime)
          .reduce((value, element) => value.isAfter(element) ? value : element);
    } else {
      _minDate = DateTime.parse('1911-01-01 11:11');
      _maxDate = DateTime.parse('1911-01-02 11:11');
    }
  }

  void setXRangeAndYRange() {
    _xRange = _maxDate.difference(_minDate).inSeconds.toDouble();
    _yRange = _maxValue - _minValue;
  }

  void setXRangeAndYRangeForMultipleYAxis() {
    _xRange = _maxDate.difference(_minDate).inSeconds.toDouble();

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
      setMinDateAndMaxDate();
      setXRangeAndYRangeForMultipleYAxis();
    } else {
      setMinValueAndMaxValue();
      setMinDateAndMaxDate();
      setXRangeAndYRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    double widgetWidth = MediaQuery.of(context).size.width;
    double widgetHeight = 200;

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
      var widgetWidth = context.size!.width;

      newScale = newScale.clamp(1.0, 30.0);

      // 根據縮放焦點算出圖的起始點
      double left = calculateOffsetX(newScale, focusX);
      print('left: $left');

      // 加上額外的水平偏移量
      left += extraX;

      // 將範圍限制在圖表寬度內
      double newOffsetX = left.clamp((newScale - 1) * -widgetWidth, 0.0);

      setState(() {
        _scale = newScale;
        _offset = newOffsetX;
      });
    }

    return GestureDetector(
      onScaleStart: (details) {
        // 紀錄按下去的點
        _focalPointX = details.focalPoint.dx;

        // 紀錄目前的scale
        _lastScaleValue = _scale;

        // 紀錄按下去的點, 用在計算縮放時焦點的偏移量
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
      child: Column(
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
          CustomPaint(
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
              rightOffset: widget.showMultipleYAxises
                  ? _rightOffset +
                      (widget.lineSeriesCollection.length - 1) *
                          40 //根據y-axis軸的數量調整右邊的邊界
                  : _rightOffset,
              offset: _offset,
              scale: _scale,
              minValue: _minValue,
              maxValue: _maxValue,
              minDate: _minDate,
              maxDate: _maxDate,
              xRange: _xRange,
              yRange: _yRange,
              showMultipleYAxises: widget.showMultipleYAxises,
              minValues: _minValues,
              maxValues: _maxValues,
              yRanges: _yRanges,
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
      ),
    );
  }
}
