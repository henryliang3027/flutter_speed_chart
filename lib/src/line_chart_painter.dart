import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/value_pair.dart';
import 'package:flutter_speed_chart/src/speed_line_chart.dart';
import 'package:intl/intl.dart';

/// An internal [CustomPainter] responsible for rendering the line chart.
///
/// The [LineChartPainter] class handles all the drawing logic for the [SpeedLineChart],
/// including axes, grid lines, data series, and interactive elements like trackballs.
/// This painter is **not** exposed to the end-users of the `speed_chart` package
/// and is intended for internal use within the package's implementation.
class LineChartPainter extends CustomPainter {
  /// Creates an instance of [_LineChartPainter].
  ///
  /// All parameters marked as `required` must be provided and are essential
  /// for accurately rendering the chart.

  LineChartPainter({
    required this.lineSeriesXCollection,
    required this.longestLineSeriesX,
    required this.showTrackball,
    required this.longPressX,
    required this.leftOffset,
    required this.rightOffset,
    required this.offset,
    required this.scale,
    required this.minValue,
    required this.maxValue,
    required this.xRange,
    required this.yRange,
    required this.showMultipleYAxises,
    required this.minValues,
    required this.maxValues,
    required this.yRanges,
    required this.axisPaint,
    required this.verticalLinePaint,
    this.xAxisUnit = '',
  });

  /// A collection of [LineSeriesX] instances representing the data series to be plotted.
  final List<LineSeriesX> lineSeriesXCollection;

  /// The [LineSeriesX] with the most data points, used for determining the X-axis range.
  final LineSeriesX longestLineSeriesX;

  /// Indicates whether to display the trackball (interactive data point indicator).
  final bool showTrackball;

  /// The X-coordinate position of the long press (for trackball).
  final double longPressX;

  /// The left padding offset for the chart.
  final double leftOffset;

  /// The right padding offset for the chart.
  final double rightOffset;

  /// The horizontal offset for panning and scaling.
  final double offset;

  /// The scaling factor for zooming.
  final double scale;

  /// The minimum Y-axis value across all series.
  final double minValue;

  /// The maximum Y-axis value across all series.
  final double maxValue;

  /// The total range of X-axis values.
  final double xRange;

  /// The total range of Y-axis values.
  final double yRange;

  /// Indicates whether multiple Y-axes are displayed.
  final bool showMultipleYAxises;

  /// A list of minimum Y-axis values for each series (used in multiple Y-axes).
  final List<double> minValues;

  /// A list of maximum Y-axis values for each series (used in multiple Y-axes).
  final List<double> maxValues;

  /// A list of Y-axis ranges for each series (used in multiple Y-axes).
  final List<double> yRanges;

  /// The [Paint] object used for drawing axes.
  final Paint axisPaint;

  /// The [Paint] object used for drawing vertical grid lines.
  final Paint verticalLinePaint;

  /// This unit is typically used in the tooltip to display the X axis unit.
  final String xAxisUnit;

  final TextPainter _axisLabelPainter = TextPainter(
    textAlign: TextAlign.right,
    textDirection: ui.TextDirection.ltr,
  );

  final TextPainter _tipTextPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );

  final Paint _gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.4)
    ..strokeWidth = 1;

  final Paint _dividerPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  int? _findClosestIndex({
    required double x,
    required double offsetX,
    required double xStep,
  }) {
    double closestDistance = double.infinity;
    int? closestIndex;

    if (longestLineSeriesX.dataList.isNotEmpty) {
      for (int i = 0; i < longestLineSeriesX.dataList.length; i++) {
        // because sthe start point of line series is in canvas.translate(offset, 0)
        // add offsetX to adjust the i-th point
        double distance = (i * xStep + offsetX - x).abs();

        if (distance < closestDistance) {
          closestDistance = distance;
          closestIndex = i;
        }
      }

      return closestIndex;
    } else {
      return null;
    }
  }

  List<Map<int, double?>> _getYByClosetIndex(int index) {
    List<Map<int, double?>> valueMapList = [];
    for (int i = 0; i < lineSeriesXCollection.length; i++) {
      LineSeriesX lineSeriesX = lineSeriesXCollection[i];
      Map<int, double?> valueMap = {};

      if (index >= lineSeriesX.dataList.length) {
        valueMap[i] = null;
      } else {
        valueMap[i] = lineSeriesX.dataList[index].y;
      }

      valueMapList.add(valueMap);
    }
    // valueMapList = [{'name': value},{'name': value}]
    return valueMapList;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date).toString();
  }

  // Draw Y-Axis
  void _drawYAxis({required Canvas canvas, required Size size}) {
    canvas.drawLine(
      Offset(leftOffset, 0),
      Offset(leftOffset, size.height),
      axisPaint,
    );
  }

  // Draw X-Axis
  void _drawXAxis({required Canvas canvas, required Size size}) {
    canvas.drawLine(
      Offset(leftOffset, size.height),
      Offset(size.width - rightOffset, size.height), // size.width 是畫面中最右邊的位置
      axisPaint,
    );
  }

  void _drawXAxisForMultipleYAxises({
    required Canvas canvas,
    required Size size,
  }) {
    double newLeftOffset = leftOffset + 40 * (lineSeriesXCollection.length - 1);

    canvas.drawLine(
      Offset(newLeftOffset, size.height),
      Offset(size.width - rightOffset, size.height),
      axisPaint,
    );
  }

  // Draw a vertical grid line and a X-Axis label with a given point
  void _drawXLabelAndVerticalGridLine({
    required Canvas canvas,
    required Size size,
    required double scaleX,
    dynamic x,
  }) {
    String xLabel = '';
    if (x is DateTime) {
      String date = DateFormat('yyyy-MM-dd').format(x);
      String time = DateFormat('HH:mm:ss').format(x);
      xLabel = '$date\n$time';
    } else {
      xLabel = x.toString();
    }

    _axisLabelPainter.text = TextSpan(
      text: xLabel,
      style: TextStyle(fontSize: 12, color: axisPaint.color),
    );

    _axisLabelPainter.layout();

    // 如果字會超過最左邊的邊界就不畫
    if (scaleX - _axisLabelPainter.width > 0) {
      // Draw vertical grid line
      canvas.drawLine(
        Offset(scaleX, 0),
        Offset(scaleX, size.height),
        _gridPaint,
      );

      // Draw label
      _axisLabelPainter.paint(
        canvas,
        Offset(scaleX - _axisLabelPainter.width, size.height),
      );
    }
  }

  // Draw vertical grid lines and X-Axis labels
  void _drawXAxisLabelAndVerticalGridLine({
    required Canvas canvas,
    required Size size,
    required double xStep,
  }) {
    List<ValuePair> dataList = longestLineSeriesX.dataList;
    int currentLabelIndex = -1;

    for (int i = dataList.length - 1; i > 0; i--) {
      // 最後一個點優先畫出來
      if (i == dataList.length - 1) {
        currentLabelIndex = i;
        _drawXLabelAndVerticalGridLine(
          canvas: canvas,
          size: size,
          scaleX: currentLabelIndex * xStep,
          x: dataList[currentLabelIndex].x,
        );
      } else {
        double currentPointX = i * xStep;
        double previousPointX = currentLabelIndex * xStep;

        // 在畫面中每間隔 100 個單位畫一條 vertical grid line
        if (previousPointX - currentPointX > 100) {
          currentLabelIndex = i;
          _drawXLabelAndVerticalGridLine(
            canvas: canvas,
            size: size,
            scaleX: currentLabelIndex * xStep,
            x: dataList[currentLabelIndex].x,
          );
        }
      }
    }
  }

  // Draw horizontal grid lines and Y-axis labels
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
      canvas.drawLine(
        Offset(leftOffset, scaleY),
        Offset(size.width - rightOffset, scaleY),
        _gridPaint,
      );

      // Draw Y-axis label
      String label = (i * yInterval + minValue).toStringAsFixed(0);
      _axisLabelPainter.text = TextSpan(
        text: label,
        style: TextStyle(fontSize: 12, color: axisPaint.color),
      );
      _axisLabelPainter.layout();
      _axisLabelPainter.paint(
        canvas,
        Offset(
          leftOffset - _axisLabelPainter.width - 4,
          scaleY - _axisLabelPainter.height / 2,
        ),
      );
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
      canvas.drawLine(
        Offset(newLeftOffset, 0),
        Offset(newLeftOffset, size.height),
        axisPaint,
      );

      int yScalePoints = 5;
      double yInterval = yRanges[i] / yScalePoints;
      double yStep = size.height / yRanges[i];
      for (int j = 0; j <= yScalePoints; j++) {
        double scaleY = size.height - j * yInterval * yStep;

        // Draw horizontal grid line
        if (i == lineSeriesXCollection.length - 1) {
          canvas.drawLine(
            Offset(newLeftOffset, scaleY),
            Offset(size.width - rightOffset, scaleY),
            _gridPaint,
          );
        }

        // Draw Y-axis scale points
        String label = (j * yInterval + minValues[i]).toStringAsFixed(0);

        TextPainter multipleYAxisLabelPainter = TextPainter(
          textAlign: TextAlign.right,
          textDirection: ui.TextDirection.ltr,
        );

        multipleYAxisLabelPainter.text = TextSpan(
          text: label,
          style: TextStyle(fontSize: 12, color: lineSeries.color),
        );
        multipleYAxisLabelPainter.layout();
        multipleYAxisLabelPainter.paint(
          canvas,
          Offset(
            newLeftOffset - multipleYAxisLabelPainter.width - 2,
            scaleY - multipleYAxisLabelPainter.height / 2,
          ),
        );
      }
    }
  }

  // Draw vertical track line and tip
  void _drawTrackBall({
    required Canvas canvas,
    required Size size,
    required double xStep,
  }) {
    int nonNullValueIndex = longestLineSeriesX.dataList.indexWhere(
      (element) => element.y != null,
    );
    // 如果 line series value 全部都是 null,就不用畫 track ball
    // 如果 至少有 value 不是 null, 就要畫
    if (nonNullValueIndex != -1) {
      double adjustedLongPressX = 0.0;
      if (showMultipleYAxises) {
        double newLeftOffset = 40 * (lineSeriesXCollection.length - 1);
        adjustedLongPressX = longPressX - newLeftOffset;
        adjustedLongPressX = adjustedLongPressX.clamp(0.0, size.width);
      } else {
        adjustedLongPressX = longPressX.clamp(0.0, size.width);
      }

      // print('adjustedLongPressX: $adjustedLongPressX');

      int? closestIndex = _findClosestIndex(
        x: adjustedLongPressX,
        offsetX: offset,
        xStep: xStep,
      );

      if (closestIndex != null) {
        // Draw vertical line at the closest point
        canvas.drawLine(
          Offset((closestIndex * xStep), 0),
          Offset((closestIndex * xStep), size.height),
          verticalLinePaint,
        );

        String formatXLabel = '';

        if (longestLineSeriesX.dataList[closestIndex].x is DateTime) {
          DateTime closestDateTime =
              longestLineSeriesX.dataList[closestIndex].x as DateTime;
          formatXLabel = _formatDate(closestDateTime);
        } else {
          int closestX = longestLineSeriesX.dataList[closestIndex].x as int;
          formatXLabel = '${closestX.toString()} $xAxisUnit';
        }

        List<Map<int, double?>> valueMapList = _getYByClosetIndex(closestIndex);

        Map<int, String> tips = {-1: formatXLabel};

        for (Map<int, double?> valueMap in valueMapList) {
          MapEntry nameValueEntry = valueMap.entries.toList()[0];
          if (nameValueEntry.value != null) {
            tips[nameValueEntry.key] =
                '${lineSeriesXCollection[nameValueEntry.key].name} : ${nameValueEntry.value}'
                    .toString();
          }
        }

        String longestTip = tips.values.reduce(
          (value, element) => value.length >= element.length ? value : element,
        );

        _tipTextPainter.text = TextSpan(
          text: longestTip,
          style: const TextStyle(color: Colors.black),
        );

        _tipTextPainter.layout();

        double rectWidth = _tipTextPainter.width;

        double textX = (closestIndex * xStep) + 10;
        double textY = size.height / 2 - (14.0 * (tips.length + 1) + 4) / 2;

        // 折線圖的左邊 offset
        double lineSeriesLeftOffset = 0.0;
        if (showMultipleYAxises) {
          lineSeriesLeftOffset = 40.0 * (lineSeriesXCollection.length);
        } else {
          lineSeriesLeftOffset = leftOffset;
        }

        double outOfBoundWidth =
            (textX - 4) +
            (rectWidth + 16) -
            (size.width - lineSeriesLeftOffset - rightOffset) +
            offset;
        // print('offset: $offset');
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
          style: const TextStyle(color: Colors.black),
        );
        _tipTextPainter.layout();

        _tipTextPainter.paint(canvas, Offset(textX - adjustedTextX, textY));

        canvas.drawLine(
          Offset(textX - adjustedTextX, textY + 18),
          Offset(textX - adjustedTextX - 8 + rectWidth + 16, textY + 18),
          _dividerPaint,
        );

        textY = textY + 13;

        int tipRowCount = 1;
        for (MapEntry entry in tips.entries) {
          if (entry.key != -1) {
            Paint circlePaint = Paint()
              ..color = lineSeriesXCollection[entry.key].color;
            Offset center = Offset(
              textX + 4 - adjustedTextX,
              textY + 14 * tipRowCount,
            );
            double radius = 4;
            canvas.drawCircle(center, radius, circlePaint);

            _tipTextPainter.text = TextSpan(
              text: entry.value,
              style: const TextStyle(color: Colors.black),
            );
            _tipTextPainter.layout();

            _tipTextPainter.paint(
              canvas,
              Offset(
                textX - adjustedTextX + 10,
                (textY + 14 * tipRowCount) - _tipTextPainter.height / 2,
              ),
            );

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
      List<ValuePair> data = lineSeriesX.dataList;
      List<int> startIndex = lineSeriesX.startIndexes;
      Path linePath = Path();

      Paint linePaint = Paint()
        ..color = lineSeriesX.color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // find the first non null value
      int firstIndex = data.indexWhere((element) => element.y != null);
      if (firstIndex != -1) {
        for (int i = firstIndex; i < data.length; i++) {
          double currentScaleX = (i * xStep);
          double? currentScaleY = data[i].y == null
              ? null
              : (maxValue - data[i].y!) * yStep;

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
      List<ValuePair> data = lineSeriesXCollection[i].dataList;
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
        int firstIndex = data.indexWhere((element) => element.y != null);
        if (firstIndex != -1) {
          // line series value 不是全部都是 null, 至少有一個 value 不是null
          for (int j = firstIndex; j < data.length; j++) {
            double currentScaleX = (j * xStep);
            double? currentScaleY = data[j].y == null
                ? null
                : (maxValues[i] - data[j].y!) * yStep;

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
    _drawYAxis(canvas: canvas, size: size);

    // Draw X-axis line
    if (showMultipleYAxises) {
      _drawXAxisForMultipleYAxises(canvas: canvas, size: size);
    } else {
      _drawXAxis(canvas: canvas, size: size);
    }

    // current (left,top) => (0,0)
    canvas.save();

    double xStep = 0.0;

    if (showMultipleYAxises) {
      double newLeftOffset =
          leftOffset + 40 * (lineSeriesXCollection.length - 1);
      canvas.clipRect(
        Rect.fromPoints(
          Offset(newLeftOffset, 0),
          Offset(size.width - rightOffset, size.height + 40),
        ),
      );
      canvas.translate(newLeftOffset + offset, 0);

      // 如果沒有資料點, xRange = 0
      if (xRange == 0) {
        xStep = (size.width * scale - newLeftOffset - rightOffset - 0.5) / 1;
      } else {
        xStep =
            (size.width * scale - newLeftOffset - rightOffset - 0.5) /
            (xRange - 1);
      }
    } else {
      canvas.clipRect(
        Rect.fromPoints(
          Offset(leftOffset, 0),
          Offset(size.width - rightOffset, size.height + 40),
        ),
      );
      canvas.translate(leftOffset + offset, 0);

      // 如果沒有資料點, xRange = 0
      if (xRange == 0) {
        xStep = (size.width * scale - leftOffset - rightOffset - 0.5) / 1;
      } else {
        xStep =
            (size.width * scale - leftOffset - rightOffset - 0.5) /
            (xRange - 1);
      }
    }

    if (xRange != 0) {
      _drawXAxisLabelAndVerticalGridLine(
        canvas: canvas,
        size: size,
        xStep: xStep,
      );
    }

    canvas.restore();

    canvas.save();
    if (showMultipleYAxises) {
      double newLeftOffset =
          leftOffset + 40 * (lineSeriesXCollection.length - 1);
      canvas.clipRect(
        Rect.fromPoints(
          Offset(newLeftOffset, 0),
          Offset(size.width - rightOffset, size.height),
        ),
      );
      canvas.translate(newLeftOffset + offset, 0);
    } else {
      canvas.clipRect(
        Rect.fromPoints(
          Offset(leftOffset, 0),
          Offset(size.width - rightOffset, size.height),
        ),
      );
      canvas.translate(leftOffset + offset, 0);
    }

    // Draw line series
    if (showMultipleYAxises) {
      _drawLineSeriesForMultipleYAxises(
        canvas: canvas,
        size: size,
        xStep: xStep,
      );
    } else {
      _drawLineSeries(canvas: canvas, xStep: xStep, yStep: yStep);
    }

    if (showTrackball) {
      _drawTrackBall(canvas: canvas, size: size, xStep: xStep);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.showTrackball != showTrackball ||
        oldDelegate.longPressX != longPressX ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }
}
