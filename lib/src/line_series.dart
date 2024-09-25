import 'package:flutter/material.dart';
import 'package:speed_chart/src/value_pair.dart';

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
