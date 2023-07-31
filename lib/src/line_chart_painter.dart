import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/date_value_pair.dart';
import 'package:flutter_speed_chart/src/speed_line_chart.dart';
import 'package:intl/intl.dart';

class LineChartPainter extends CustomPainter {
  LineChartPainter({
    required this.lineSeriesXCollection,
    required this.longestLineSeriesX,
    required this.showTooltip,
    required this.longPressX,
    required this.leftOffset,
    required this.rightOffset,
    required this.offset,
    required this.scale,
    required this.minValue,
    required this.maxValue,
    required this.minDate,
    required this.maxDate,
    required this.xRange,
    required this.yRange,
    required this.showMultipleYAxises,
    required this.minValues,
    required this.maxValues,
    required this.yRanges,
  });

  final List<LineSeriesX> lineSeriesXCollection;
  final LineSeriesX longestLineSeriesX;
  final bool showTooltip;
  final double longPressX;
  final double leftOffset;
  final double rightOffset;
  final double offset;
  final double scale;
  final double minValue;
  final double maxValue;
  final DateTime? minDate;
  final DateTime? maxDate;
  final double xRange;
  final double yRange;
  final bool showMultipleYAxises;
  final List<double> minValues;
  final List<double> maxValues;
  final List<double> yRanges;

  final TextPainter _axisLabelPainter = TextPainter(
    textAlign: TextAlign.left,
    textDirection: ui.TextDirection.ltr,
  );

  final TextPainter _tipTextPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );

  final Paint _gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.4)
    ..strokeWidth = 1;

  final Paint _axisPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1;

  final Paint _verticalLinePaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final Paint _dividerPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  DateTime? _findClosestPoint({
    required double x,
    required double offsetX,
    required double xStep,
  }) {
    double closestDistance = double.infinity;
    DateTime? closestDateTime;

    if (longestLineSeriesX.dataMap.isNotEmpty) {
      for (DateTime dateTime in longestLineSeriesX.dataMap.keys) {
        // because sthe start point of line series is in canvas.translate(leftOffset + offset, 0);
        // add offsetX to adjust the difference between target datetime and min datetime
        double distance =
            (dateTime.difference(minDate!).inSeconds.toDouble() * xStep +
                    offsetX -
                    x)
                .abs();

        if (distance < closestDistance) {
          closestDistance = distance;
          closestDateTime = dateTime;
        }
      }
      return closestDateTime;
    } else {
      return null;
    }
  }

  List<Map<int, double?>> _getValueByDateTime(DateTime dateTime) {
    List<Map<int, double?>> valueMapList = [];
    for (int i = 0; i < lineSeriesXCollection.length; i++) {
      LineSeriesX lineSeriesX = lineSeriesXCollection[i];
      Map<int, double?> valueMap = {};
      valueMap[i] = lineSeriesX.dataMap[dateTime];
      valueMapList.add(valueMap);
    }
    // valueMapList = [{'name': value},{'name': value}]
    return valueMapList;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date).toString();
  }

  // Draw Y-Axis
  void _drawYAxis({
    required Canvas canvas,
    required Size size,
  }) {
    canvas.drawLine(
        Offset(leftOffset, 0), Offset(leftOffset, size.height), _axisPaint);
  }

  // Draw X-Axis
  void _drawXAxis({
    required Canvas canvas,
    required Size size,
  }) {
    canvas.drawLine(Offset(leftOffset, size.height),
        Offset(size.width + leftOffset - rightOffset, size.height), _axisPaint);
  }

  void _drawXAxisForMultipleYAxises({
    required Canvas canvas,
    required Size size,
  }) {
    double newLeftOffset = leftOffset + 40 * (lineSeriesXCollection.length - 1);

    canvas.drawLine(
        Offset(newLeftOffset, size.height),
        Offset(size.width + newLeftOffset - rightOffset, size.height),
        _axisPaint);
  }

  // Draw vertical grid line and X-Axis scale points
  void _drawXAxisLabelAndVerticalGridLine({
    required Canvas canvas,
    required Size size,
    required double xStep,
  }) {
    int xScalePoints = size.width * scale ~/ 100;
    // longestLineSeriesX.dataList.length - 1 is to avoid (i * xInterval).round() is equal to longestLineSeriesX.dataList.length
    int xInterval =
        (maxDate!.millisecondsSinceEpoch - minDate!.millisecondsSinceEpoch) ~/
            1000 ~/
            xScalePoints;
    for (int i = 0; i < xScalePoints; i++) {
      DateTime dateTimeScalePoint = DateTime.fromMillisecondsSinceEpoch(
          minDate!.millisecondsSinceEpoch + xInterval * 1000 * i);

      double scaleX =
          dateTimeScalePoint.difference(minDate!).inSeconds.toDouble() * xStep;

      // double scaleX = (longestLineSeriesX
      //         .dataList[(i * xInterval).round()].dateTime
      //         .difference(minDate)
      //         .inSeconds
      //         .toDouble() *
      //     xStep);

      // Draw vertical grid line
      canvas.drawLine(
          Offset(scaleX, 0), Offset(scaleX, size.height), _gridPaint);

      // Draw X-Axis scale points
      // DateTime dateTime =
      //     longestLineSeriesX.dataList[(i * xInterval).round()].dateTime;
      // String date = DateFormat('yy-MM-dd').format(dateTime);

      // String time = DateFormat('HH:mm:ss').format(dateTime);

      String date = DateFormat('yy-MM-dd').format(dateTimeScalePoint);

      String time = DateFormat('HH:mm:ss').format(dateTimeScalePoint);

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
  }

  // Draw horizontal grid line and Y-axis scale points
  void _drawYAxisLabelAndHorizontalGridLine({
    required Canvas canvas,
    required Size size,
    required double yStep,
  }) {
    int yScalePoints = 5;
    double yInterval = yRange / yScalePoints;
    for (int i = 0; i <= yScalePoints; i++) {
      double scaleY = size.height - i * yInterval * yStep;

      // Draw horizontal grid line
      canvas.drawLine(Offset(leftOffset, scaleY),
          Offset(size.width - rightOffset + leftOffset, scaleY), _gridPaint);

      // Draw Y-axis scale points
      String label = (i * yInterval + minValue).toStringAsFixed(0);
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
  }

  void _drawYAxisLabelAndHorizontalGridLineForMultipleYAxises({
    required Canvas canvas,
    required Size size,
  }) {
    for (int i = 0; i < lineSeriesXCollection.length; i++) {
      LineSeriesX lineSeries = lineSeriesXCollection[i];
      double newLeftOffset = leftOffset + 40 * i;

      // Draw Y-Axis
      canvas.drawLine(Offset(newLeftOffset, 0),
          Offset(newLeftOffset, size.height), _axisPaint);

      int yScalePoints = 5;
      double yInterval = yRanges[i] / yScalePoints;
      double yStep = size.height / yRanges[i];
      for (int j = 0; j <= yScalePoints; j++) {
        double scaleY = size.height - j * yInterval * yStep;

        // Draw horizontal grid line
        if (i == lineSeriesXCollection.length - 1) {
          canvas.drawLine(
              Offset(newLeftOffset, scaleY),
              Offset(size.width - rightOffset + newLeftOffset, scaleY),
              _gridPaint);
        }

        // Draw Y-axis scale points
        String label = (j * yInterval + minValues[i]).toStringAsFixed(0);
        _axisLabelPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 12,
            color: lineSeries.color,
          ),
        );
        _axisLabelPainter.layout();
        _axisLabelPainter.paint(
            canvas,
            Offset(newLeftOffset - _axisLabelPainter.width - 2,
                scaleY - _axisLabelPainter.height / 2));
      }
    }
  }

  // Draw vertical track line and tip
  void _drawTrackBall({
    required Canvas canvas,
    required Size size,
    required double xStep,
  }) {
    int nonNullValueIndex = longestLineSeriesX.dataList
        .indexWhere((element) => element.value != null);
    // 如果 line series value 全部都是 null,就不用畫 track ball
    // 如果 至少有 value 不是 null, 就要畫
    if (nonNullValueIndex != -1) {
      double adjustedLongPressX = 0.0;
      if (showMultipleYAxises) {
        double newLeftOffset = 40 * (lineSeriesXCollection.length - 1);
        adjustedLongPressX = longPressX - newLeftOffset;
        adjustedLongPressX =
            adjustedLongPressX.clamp(0.0, size.width - rightOffset);
      } else {
        adjustedLongPressX = longPressX.clamp(0.0, size.width - rightOffset);
      }

      DateTime? closestDateTime = _findClosestPoint(
        x: adjustedLongPressX,
        offsetX: offset,
        xStep: xStep,
      );

      if (closestDateTime != null) {
        // Draw vertical line at the closest point
        canvas.drawLine(
          Offset(
              (closestDateTime.difference(minDate!).inSeconds.toDouble() *
                  xStep),
              0),
          Offset(
              (closestDateTime.difference(minDate!).inSeconds.toDouble() *
                  xStep),
              size.height),
          _verticalLinePaint,
        );

        String formatDateTime = _formatDate(closestDateTime);
        List<Map<int, double?>> valueMapList =
            _getValueByDateTime(closestDateTime);

        Map<int, String> tips = {-1: formatDateTime};

        for (Map<int, double?> valueMap in valueMapList) {
          MapEntry nameValueEntry = valueMap.entries.toList()[0];
          if (nameValueEntry.value != null) {
            tips[nameValueEntry.key] =
                '${lineSeriesXCollection[nameValueEntry.key].name} : ${nameValueEntry.value}'
                    .toString();
          }
        }

        String longestTip = tips.values.reduce((value, element) =>
            value.length >= element.length ? value : element);

        _tipTextPainter.text = TextSpan(
          text: longestTip,
          style: const TextStyle(
            color: Colors.black,
          ),
        );

        _tipTextPainter.layout();

        double rectWidth = _tipTextPainter.width;

        double textX =
            (closestDateTime.difference(minDate!).inSeconds.toDouble() *
                    xStep) +
                10;
        double textY = size.height / 2 - (14.0 * (tips.length + 1) + 4) / 2;

        double outOfBoundWidth = (textX - 4) +
            (rectWidth + 16) -
            (size.width - rightOffset) +
            offset;
        double adjustedTextX = outOfBoundWidth > 0 ? outOfBoundWidth : 0;
        Rect rect1 = Rect.fromLTWH(
          textX - 4 - adjustedTextX,
          textY,
          rectWidth + 16,
          12.0 * (tips.length + 1) +
              4, // +1 for the date time string at the first row
        );
        Paint rectPaint = Paint()..color = Colors.white;
        RRect rRect = RRect.fromRectAndRadius(rect1, const Radius.circular(4));
        canvas.drawRRect(rRect, rectPaint);

        _tipTextPainter.text = TextSpan(
          text: tips[-1], // draw datetime
          style: const TextStyle(
            color: Colors.black,
          ),
        );
        _tipTextPainter.layout();

        _tipTextPainter.paint(canvas, Offset(textX - adjustedTextX, textY));

        canvas.drawLine(
            Offset(textX - adjustedTextX, textY + 18),
            Offset(textX - adjustedTextX - 8 + rectWidth + 16, textY + 18),
            _dividerPaint);

        textY = textY + 13;

        int tipRowCount = 1;
        for (MapEntry entry in tips.entries) {
          if (entry.key != -1) {
            Paint circlePaint = Paint()
              ..color = lineSeriesXCollection[entry.key].color;
            Offset center =
                Offset(textX + 4 - adjustedTextX, textY + 14 * tipRowCount);
            double radius = 4;
            canvas.drawCircle(center, radius, circlePaint);

            _tipTextPainter.text = TextSpan(
              text: entry.value,
              style: const TextStyle(
                color: Colors.black,
              ),
            );
            _tipTextPainter.layout();

            _tipTextPainter.paint(
                canvas,
                Offset(textX - adjustedTextX + 10,
                    (textY + 14 * tipRowCount) - _tipTextPainter.height / 2));

            tipRowCount += 1;
          }
        }
      }
    }
  }

  void _drawLineSeries({
    required Canvas canvas,
    required double xStep,
    required double yStep,
  }) {
    for (LineSeriesX lineSeriesX in lineSeriesXCollection) {
      List<DateValuePair> data = lineSeriesX.dataList;
      List<int> startIndex = lineSeriesX.startIndexes;
      Path linePath = Path();

      Paint linePaint = Paint()
        ..color = lineSeriesX.color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // find the first non null value
      int firstIndex = data.indexWhere((element) => element.value != null);
      if (firstIndex != -1) {
        for (int i = firstIndex; i < data.length; i++) {
          double currentScaleX =
              (data[i].dateTime.difference(minDate!).inSeconds * xStep);
          double? currentScaleY = data[i].value == null
              ? null
              : (maxValue - data[i].value!) * yStep;

          if (currentScaleY != null) {
            if (i == firstIndex) {
              linePath.moveTo(currentScaleX, currentScaleY);
            }

            // if previous index of value is null, Do not draw line near the point
            if (startIndex.contains(i)) {
              linePath.moveTo(currentScaleX, currentScaleY);
            } else {
              linePath.lineTo(currentScaleX, currentScaleY);
            }
          }
        }

        canvas.drawPath(linePath, linePaint);
      }
    }
  }

  void _drawLineSeriesForMultipleYAxises({
    required Canvas canvas,
    required Size size,
    required double xStep,
  }) {
    for (int i = 0; i < lineSeriesXCollection.length; i++) {
      List<DateValuePair> data = lineSeriesXCollection[i].dataList;
      if (data.isNotEmpty) {
        List<int> startIndex = lineSeriesXCollection[i].startIndexes;
        double yStep = size.height / yRanges[i];
        Path linePath = Path();

        Paint linePaint = Paint()
          ..color = lineSeriesXCollection[i].color
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // 找到第一個 value 不是 null 的 index
        int firstIndex = data.indexWhere((element) => element.value != null);
        if (firstIndex != -1) {
          // line series value 不是全部都是 null, 至少有一個 value 不是null
          for (int j = firstIndex; j < data.length; j++) {
            double currentScaleX =
                (data[j].dateTime.difference(minDate!).inSeconds * xStep);
            double? currentScaleY = data[j].value == null
                ? null
                : (maxValues[i] - data[j].value!) * yStep;

            if (currentScaleY != null) {
              if (j == firstIndex) {
                linePath.moveTo(currentScaleX, currentScaleY);
              }

              // if previous index of value is null, Do not draw line near the point
              if (startIndex.contains(j)) {
                linePath.moveTo(currentScaleX, currentScaleY);
              } else {
                linePath.lineTo(currentScaleX, currentScaleY);
              }
            }
          }

          canvas.drawPath(linePath, linePaint);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double yStep = size.height / yRange;

    if (showMultipleYAxises) {
      _drawYAxisLabelAndHorizontalGridLineForMultipleYAxises(
        canvas: canvas,
        size: size,
      );
    } else {
      _drawYAxisLabelAndHorizontalGridLine(
        canvas: canvas,
        size: size,
        yStep: yStep,
      );
    }

    // Draw Y-axis line
    _drawYAxis(
      canvas: canvas,
      size: size,
    );

    // Draw X-axis line
    if (showMultipleYAxises) {
      _drawXAxisForMultipleYAxises(
        canvas: canvas,
        size: size,
      );
    } else {
      _drawXAxis(
        canvas: canvas,
        size: size,
      );
    }

    // current (left,top) => (0,0)
    // canvas.save();

    if (showMultipleYAxises) {
      double newLeftOffset =
          leftOffset + 40 * (lineSeriesXCollection.length - 1);
      canvas.clipRect(Rect.fromPoints(
          Offset(newLeftOffset, 0),
          Offset(
              size.width + newLeftOffset - rightOffset + 1, size.height + 40)));
      canvas.translate(newLeftOffset + offset, 0);
    } else {
      canvas.clipRect(Rect.fromPoints(Offset(leftOffset, 0),
          Offset(size.width + leftOffset - rightOffset + 1, size.height + 40)));
      canvas.translate(leftOffset + offset, 0);
    }

    double xStep = 0.0;

    // 如果沒有資料點, xRange = 0
    if (xRange == 0) {
      xStep = (size.width * scale - rightOffset) / 1;
    } else {
      xStep = (size.width * scale - rightOffset) / xRange;
    }

    if (xRange != 0) {
      _drawXAxisLabelAndVerticalGridLine(
        canvas: canvas,
        size: size,
        xStep: xStep,
      );
    }

    // Draw line series
    if (showMultipleYAxises) {
      _drawLineSeriesForMultipleYAxises(
        canvas: canvas,
        size: size,
        xStep: xStep,
      );
    } else {
      _drawLineSeries(
        canvas: canvas,
        xStep: xStep,
        yStep: yStep,
      );
    }

    if (showTooltip) {
      _drawTrackBall(
        canvas: canvas,
        size: size,
        xStep: xStep,
      );
    }

    // canvas.restore();
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.showTooltip != showTooltip ||
        oldDelegate.longPressX != longPressX ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }
}
